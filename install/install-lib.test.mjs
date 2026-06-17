import assert from 'node:assert/strict';
import test from 'node:test';

import {
  buildDockerRunArgs,
  buildInstallerConfig,
  detectImagePlatform,
  normalizeImageName,
} from './install-lib.mjs';

test('buildInstallerConfig fills safe local defaults from host', () => {
  const config = buildInstallerConfig({ host: '192.168.1.10' });

  assert.equal(config.host, '192.168.1.10');
  assert.equal(config.httpPort, '80');
  assert.equal(config.image, 'ccr.ccs.tencentyun.com/lilishop/lilishop-all-in-one:lite');
  assert.equal(config.containerName, 'lilishop-all');
  assert.equal(config.storeUsername, '13011111111');
  assert.equal(config.storePassword, '111111');
  assert.equal(config.enableElasticsearch, 'true');
  assert.equal(config.enableRocketmqDashboard, 'false');
});

test('buildDockerRunArgs emits one-container env and volume contract', () => {
  const config = buildInstallerConfig({
    host: 'shop.example.com',
    dataDir: '/tmp/lilishop-data',
    mysqlPassword: 'mysql-pass',
    redisPassword: 'redis-pass',
  });
  const args = buildDockerRunArgs(config);

  assert.deepEqual(args.slice(0, 5), ['run', '-d', '--name', 'lilishop-all', '--restart']);
  assert.ok(args.includes('unless-stopped'));
  assert.ok(args.includes('-p'));
  assert.ok(args.includes('80:80'));
  assert.ok(args.includes('/tmp/lilishop-data:/data'));
  assert.ok(args.includes('LILI_HOST=shop.example.com'));
  assert.ok(args.includes('MYSQL_ROOT_PASSWORD=mysql-pass'));
  assert.ok(args.includes('REDIS_PASSWORD=redis-pass'));
});

test('buildDockerRunArgs passes default store credentials into the container', () => {
  const config = buildInstallerConfig({
    storeUsername: '13900000000',
    storePassword: 'store-pass',
  });
  const args = buildDockerRunArgs(config);

  assert.ok(args.includes('LILI_STORE_USERNAME=13900000000'));
  assert.ok(args.includes('LILI_STORE_PASSWORD=store-pass'));
});

test('buildDockerRunArgs exposes backend only through the unified HTTP entrypoint', () => {
  const config = buildInstallerConfig({ httpPort: '18080' });
  const args = buildDockerRunArgs(config);

  assert.ok(args.includes('18080:80'));
  assert.equal(args.includes('8080:8080'), false);
  assert.equal(args.some((arg) => arg.startsWith('LILI_API_PORT=')), false);
});

test('detectImagePlatform maps common host architectures to docker platforms', () => {
  assert.equal(detectImagePlatform('x64'), 'linux/amd64');
  assert.equal(detectImagePlatform('arm64'), 'linux/arm64');
  assert.equal(detectImagePlatform('ia32'), 'linux/amd64');
});

test('normalizeImageName keeps explicit tags and applies published default', () => {
  assert.equal(normalizeImageName('repo/lili:v1'), 'repo/lili:v1');
  assert.equal(normalizeImageName('repo/lili'), 'repo/lili:dev');
  assert.equal(normalizeImageName(''), 'ccr.ccs.tencentyun.com/lilishop/lilishop-all-in-one:lite');
});
