#!/usr/bin/env node
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import readline from 'node:readline/promises';
import { stdin as input, stdout as output } from 'node:process';
import { spawn, spawnSync } from 'node:child_process';
import { fileURLToPath, pathToFileURL } from 'node:url';

import {
  buildRuntimeConfig,
  parseUrlPort,
  renderBackendOverride,
  renderImEnv,
  renderPcConfig,
  renderUniappEnv,
  waitForPort,
} from './dev-env-lib.mjs';

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const dockerDir = path.resolve(scriptDir, '..');
const workspaceDir = path.resolve(dockerDir, '..');
const backendDir = path.join(workspaceDir, 'lilishop');
const uiDir = path.join(workspaceDir, 'lilishop-ui');
const uniappDir = path.join(workspaceDir, 'lilishop-uniapp');
const runtimeDir = path.join(dockerDir, '.runtime');
const logsDir = path.join(runtimeDir, 'logs');
const configPath = path.join(runtimeDir, 'dev-env.json');
const pidPath = path.join(runtimeDir, 'pids.json');
const backendOverridePath = path.join(runtimeDir, 'lilishop-application-local.yml');

const args = process.argv.slice(2);
const command = args.find((arg) => !arg.startsWith('--')) || 'start';
const flags = new Set(args.filter((arg) => arg.startsWith('--')));

const services = [
  {
    name: 'backend',
    cwd: backendDir,
    install: null,
    command: 'java',
    args: (config) => [
      '-jar',
      path.join(backendDir, 'lilishop-all', 'target', 'lilishop-all-4.3.jar'),
      '--spring.profiles.active=dev',
      `--spring.config.additional-location=${pathToFileURL(backendOverridePath).href}`,
      `--server.port=${parseUrlPort(config.apiBaseUrl)}`,
    ],
    port: (config) => parseUrlPort(config.apiBaseUrl),
  },
  {
    name: 'buyer',
    cwd: path.join(uiDir, 'buyer'),
    install: true,
    command: packageRunnerCommand(),
    args: (config) => packageRunnerArgs('dev', webServeArgs(parseUrlPort(config.buyerPcUrl))),
    port: (config) => parseUrlPort(config.buyerPcUrl),
  },
  {
    name: 'seller',
    cwd: path.join(uiDir, 'seller'),
    install: true,
    command: packageRunnerCommand(),
    args: (config) => packageRunnerArgs('dev', webServeArgs(parseUrlPort(config.sellerUrl))),
    port: (config) => parseUrlPort(config.sellerUrl),
  },
  {
    name: 'manager',
    cwd: path.join(uiDir, 'manager'),
    install: true,
    command: packageRunnerCommand(),
    args: (config) => packageRunnerArgs('dev', webServeArgs(parseUrlPort(config.managerUrl))),
    port: (config) => parseUrlPort(config.managerUrl),
  },
  {
    name: 'im',
    cwd: path.join(uiDir, 'im'),
    install: true,
    command: packageRunnerCommand(),
    args: (config) => packageRunnerArgs('dev', webServeArgs(parseUrlPort(config.imWebUrl))),
    port: (config) => parseUrlPort(config.imWebUrl),
  },
  {
    name: 'uniapp-h5',
    cwd: uniappDir,
    install: true,
    command: () => localBinCommand(uniappDir, 'vue-cli-service'),
    args: (config) => ['uni-serve', ...webServeArgs(parseUrlPort(config.uniappH5Url), false)],
    env: () => ({
      NODE_ENV: 'development',
      UNI_INPUT_DIR: '.',
      UNI_OUTPUT_DIR: 'unpackage/dist/dev/h5',
      UNI_PLATFORM: 'h5',
    }),
    port: (config) => parseUrlPort(config.uniappH5Url),
  },
];

async function main() {
  ensureRuntimeDirs();

  if (command === 'stop') {
    await stopServices();
    return;
  }

  if (command === 'status') {
    printStatus();
    return;
  }

  if (command === 'config') {
    assertWorkspace();
    const config = await loadOrPromptConfig(true);
    await writeLocalConfig(config);
    printUrls(config);
    return;
  }

  if (command !== 'start') {
    throw new Error(`未知命令：${command}。可用命令：start、stop、status、config`);
  }

  assertWorkspace();
  assertRequiredCommands();

  const config = await loadOrPromptConfig(flags.has('--reconfigure'));
  await writeLocalConfig(config);

  if (flags.has('--dry-run')) {
    console.log('dry-run：已生成本地配置，未启动 Docker、中间件或业务进程。');
    printUrls(config);
    return;
  }

  if (!flags.has('--skip-docker')) {
    runChecked('docker', ['compose', 'up', '-d'], dockerDir);
    await waitForMiddleware();
  }

  if (!flags.has('--skip-install')) {
    installDependencies();
  }

  if (!flags.has('--skip-build')) {
    buildBackend();
  }

  await stopServices({ quiet: true });
  startServices(config);
  await waitForServices(config);
  printUrls(config);
}

function ensureRuntimeDirs() {
  fs.mkdirSync(logsDir, { recursive: true });
}

function assertWorkspace() {
  const requiredPaths = [
    dockerDir,
    backendDir,
    path.join(backendDir, 'lilishop-all', 'pom.xml'),
    uiDir,
    uniappDir,
  ];

  for (const currentPath of requiredPaths) {
    if (!fs.existsSync(currentPath)) {
      throw new Error(`缺少必要路径：${currentPath}`);
    }
  }
}

function assertRequiredCommands() {
  for (const commandName of ['docker', 'java', 'mvn', 'node', 'npm']) {
    const result = spawnSync(commandName, ['--version'], { stdio: 'ignore', shell: isWindows() });
    if (result.status !== 0) {
      throw new Error(`未检测到命令：${commandName}。请先安装并加入 PATH。`);
    }
  }
}

async function loadOrPromptConfig(forcePrompt = false) {
  if (!forcePrompt && fs.existsSync(configPath)) {
    return buildRuntimeConfig(JSON.parse(fs.readFileSync(configPath, 'utf8')));
  }

  if (flags.has('--yes') || flags.has('--defaults')) {
    const config = buildRuntimeConfig();
    fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
    return config;
  }

  const rl = readline.createInterface({ input, output });
  try {
    const host = await ask(rl, '本机对外访问 IP/域名', '127.0.0.1');
    const defaults = buildRuntimeConfig({ host });
    const answers = {
      host,
      apiBaseUrl: await ask(rl, '统一后端地址', defaults.apiBaseUrl),
      buyerPcUrl: await ask(rl, '买家 PC 地址', defaults.buyerPcUrl),
      uniappH5Url: await ask(rl, 'uniapp H5 地址', defaults.uniappH5Url),
      sellerUrl: await ask(rl, '商家端地址', defaults.sellerUrl),
      managerUrl: await ask(rl, '运营端地址', defaults.managerUrl),
      imWebUrl: await ask(rl, 'IM Web 地址', defaults.imWebUrl),
      imWsUrl: await ask(rl, 'IM WebSocket 地址', defaults.imWsUrl),
    };
    const config = buildRuntimeConfig(answers);
    fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
    return config;
  } finally {
    rl.close();
  }
}

async function ask(rl, label, defaultValue) {
  const answer = await rl.question(`${label} [${defaultValue}]: `);
  return answer.trim() || defaultValue;
}

async function writeLocalConfig(config) {
  fs.writeFileSync(backendOverridePath, renderBackendOverride());
  fs.writeFileSync(
    path.join(uiDir, 'buyer', 'public', 'config.local.js'),
    renderPcConfig({ ...config, prefix: '' }),
  );
  fs.writeFileSync(
    path.join(uiDir, 'seller', 'public', 'config.local.js'),
    renderPcConfig({ ...config, prefix: '/store' }),
  );
  fs.writeFileSync(
    path.join(uiDir, 'manager', 'public', 'config.local.js'),
    renderPcConfig({ ...config, prefix: '/manager' }),
  );
  fs.writeFileSync(path.join(uiDir, 'im', '.env.development.local'), renderImEnv(config));
  fs.writeFileSync(path.join(uniappDir, '.env.development.local'), renderUniappEnv(config));
}

function waitForMiddleware() {
  return Promise.all([
    waitForPort(3306),
    waitForPort(6379),
    waitForPort(9200),
    waitForPort(9876),
  ]);
}

function installDependencies() {
  for (const service of services.filter((item) => item.install)) {
    if (fs.existsSync(path.join(service.cwd, 'node_modules'))) {
      continue;
    }
    runChecked(packageManagerCommand(), packageManagerInstallArgs(service.cwd), service.cwd);
  }
}

function buildBackend() {
  runChecked('mvn', ['-pl', 'lilishop-all', '-am', '-DskipTests', 'package'], backendDir);
}

function startServices(config) {
  const pids = {};
  for (const service of services) {
    const commandName = typeof service.command === 'function' ? service.command(config) : service.command;
    const logPath = path.join(logsDir, `${service.name}.log`);
    const logFd = fs.openSync(logPath, 'a');
    const child = spawn(commandName, service.args(config), {
      cwd: service.cwd,
      detached: true,
      shell: isWindows(),
      stdio: ['ignore', logFd, logFd],
      env: { ...process.env, ...(service.env ? service.env(config) : {}) },
    });
    child.unref();
    pids[service.name] = { pid: child.pid, log: logPath, port: service.port(config) };
    fs.closeSync(logFd);
  }
  fs.writeFileSync(pidPath, JSON.stringify(pids, null, 2));
}

async function waitForServices(config) {
  for (const service of services) {
    const port = service.port(config);
    process.stdout.write(`等待 ${service.name} ${port} ... `);
    await waitForPort(port);
    process.stdout.write('OK\n');
  }
}

async function stopServices({ quiet = false } = {}) {
  if (!fs.existsSync(pidPath)) {
    if (!quiet) {
      console.log('没有发现正在管理的本地服务。');
    }
    return;
  }

  const pids = JSON.parse(fs.readFileSync(pidPath, 'utf8'));
  for (const [name, meta] of Object.entries(pids)) {
    try {
      killProcessTree(meta.pid);
      if (!quiet) {
        console.log(`已停止 ${name} (${meta.pid})`);
      }
    } catch (error) {
      if (!quiet) {
        console.log(`停止 ${name} (${meta.pid}) 失败：${error.message}`);
      }
    }
  }
  fs.rmSync(pidPath, { force: true });
}

function killProcessTree(pid) {
  if (isWindows()) {
    spawnSync('taskkill', ['/PID', String(pid), '/T', '/F'], { stdio: 'ignore' });
    return;
  }

  try {
    process.kill(-pid, 'SIGTERM');
  } catch {
    process.kill(pid, 'SIGTERM');
  }
}

function printStatus() {
  if (!fs.existsSync(configPath)) {
    console.log('尚未生成本地配置。运行 start-dev 或 node docker/scripts/dev-env.mjs config。');
    return;
  }

  const config = buildRuntimeConfig(JSON.parse(fs.readFileSync(configPath, 'utf8')));
  printUrls(config);

  if (!fs.existsSync(pidPath)) {
    console.log('本地服务未由脚本启动。');
    return;
  }

  const pids = JSON.parse(fs.readFileSync(pidPath, 'utf8'));
  console.log('进程：');
  for (const [name, meta] of Object.entries(pids)) {
    console.log(`- ${name}: pid=${meta.pid}, port=${meta.port}, log=${meta.log}`);
  }
}

function printUrls(config) {
  console.log('\n本地访问地址：');
  console.log(`- 统一后端: ${config.apiBaseUrl}`);
  console.log(`- 买家 PC: ${config.buyerPcUrl}`);
  console.log(`- uniapp H5: ${config.uniappH5Url}`);
  console.log(`- 商家端: ${config.sellerUrl}`);
  console.log(`- 运营端: ${config.managerUrl}`);
  console.log(`- IM Web: ${config.imWebUrl}`);
  console.log(`- IM WebSocket: ${config.imWsUrl}`);
  console.log(`\n日志目录：${logsDir}`);
}

function runChecked(commandName, commandArgs, cwd) {
  console.log(`\n$ ${commandName} ${commandArgs.join(' ')}`);
  const result = spawnSync(commandName, commandArgs, {
    cwd,
    stdio: 'inherit',
    shell: isWindows(),
    env: { ...process.env },
  });

  if (result.status !== 0) {
    throw new Error(`命令执行失败：${commandName} ${commandArgs.join(' ')}`);
  }
}

function packageRunnerCommand() {
  return isWindows() ? 'npm.cmd' : 'npm';
}

function packageRunnerArgs(scriptName, extraArgs = []) {
  return ['run', scriptName, ...extraArgs];
}

function webServeArgs(port, includeSeparator = true) {
  return [
    ...(includeSeparator ? ['--'] : []),
    '--host',
    '0.0.0.0',
    '--port',
    String(port),
  ];
}

function packageManagerCommand() {
  return isWindows() ? 'npm.cmd' : 'npm';
}

function packageManagerInstallArgs() {
  return ['install'];
}

function localBinCommand(cwd, commandName) {
  const extension = isWindows() ? '.cmd' : '';
  return path.join(cwd, 'node_modules', '.bin', `${commandName}${extension}`);
}

function isWindows() {
  return os.platform() === 'win32';
}

main().catch((error) => {
  console.error(`\n启动失败：${error.message}`);
  process.exit(1);
});
