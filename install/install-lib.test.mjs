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
  assert.equal(config.apiPort, '8080');
  assert.equal(config.image, 'lilishop-all-in-one:dev');
  assert.equal(config.containerName, 'lilishop-all');
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
  assert.ok(args.includes('8080:8080'));
  assert.ok(args.includes('/tmp/lilishop-data:/data'));
  assert.ok(args.includes('LILI_HOST=shop.example.com'));
  assert.ok(args.includes('MYSQL_ROOT_PASSWORD=mysql-pass'));
  assert.ok(args.includes('REDIS_PASSWORD=redis-pass'));
});

test('buildDockerRunArgs keeps api port consistent inside and outside container', () => {
  const config = buildInstallerConfig({ apiPort: '18080' });
  const args = buildDockerRunArgs(config);

  assert.ok(args.includes('18080:18080'));
  assert.ok(args.includes('LILI_API_PORT=18080'));
});

test('detectImagePlatform maps common host architectures to docker platforms', () => {
  assert.equal(detectImagePlatform('x64'), 'linux/amd64');
  assert.equal(detectImagePlatform('arm64'), 'linux/arm64');
  assert.equal(detectImagePlatform('ia32'), 'linux/amd64');
});

test('normalizeImageName keeps explicit tags and applies dev default', () => {
  assert.equal(normalizeImageName('repo/lili:v1'), 'repo/lili:v1');
  assert.equal(normalizeImageName('repo/lili'), 'repo/lili:dev');
  assert.equal(normalizeImageName(''), 'lilishop-all-in-one:dev');
});
