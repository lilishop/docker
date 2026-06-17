export const DEFAULT_IMAGE = 'ccr.ccs.tencentyun.com/lilishop/lilishop-all-in-one:lite';

export function normalizeImageName(value) {
  const image = String(value || '').trim();
  if (!image) {
    return DEFAULT_IMAGE;
  }
  const lastSegment = image.split('/').pop();
  return lastSegment.includes(':') ? image : `${image}:dev`;
}

export function detectImagePlatform(arch = process.arch) {
  if (arch === 'arm64') {
    return 'linux/arm64';
  }
  if (arch === 'x64' || arch === 'ia32') {
    return 'linux/amd64';
  }
  return `linux/${arch}`;
}

export function buildInstallerConfig(input = {}) {
  const host = String(input.host || '127.0.0.1').trim();

  return {
    image: normalizeImageName(input.image),
    platform: input.platform || detectImagePlatform(input.arch),
    containerName: input.containerName || 'lilishop-all',
    host,
    httpPort: String(input.httpPort || '80'),
    mysqlPort: String(input.mysqlPort || '3306'),
    redisPort: String(input.redisPort || '6379'),
    dataDir: input.dataDir || './lilishop-data',
    mysqlPassword: input.mysqlPassword || 'lilishop',
    redisPassword: input.redisPassword || 'lilishop',
    adminUsername: input.adminUsername || 'admin',
    adminPassword: input.adminPassword || '123456',
    storeUsername: input.storeUsername || '13011111111',
    storePassword: input.storePassword || '111111',
    enableElasticsearch: boolString(input.enableElasticsearch, true),
    enableKibana: boolString(input.enableKibana, false),
    enableLogstash: boolString(input.enableLogstash, false),
    enableRocketmqDashboard: boolString(input.enableRocketmqDashboard, false),
    javaOpts: input.javaOpts || '-Xms512m -Xmx1024m',
    esJavaOpts: input.esJavaOpts || '-Xms512m -Xmx512m',
  };
}

export function buildDockerRunArgs(config) {
  const env = {
    LILI_HOST: config.host,
    LILI_HTTP_PORT: config.httpPort,
    MYSQL_ROOT_PASSWORD: config.mysqlPassword,
    REDIS_PASSWORD: config.redisPassword,
    LILI_ADMIN_USERNAME: config.adminUsername,
    LILI_ADMIN_PASSWORD: config.adminPassword,
    LILI_STORE_USERNAME: config.storeUsername,
    LILI_STORE_PASSWORD: config.storePassword,
    ENABLE_ELASTICSEARCH: config.enableElasticsearch,
    ENABLE_KIBANA: config.enableKibana,
    ENABLE_LOGSTASH: config.enableLogstash,
    ENABLE_ROCKETMQ_DASHBOARD: config.enableRocketmqDashboard,
    JAVA_OPTS: config.javaOpts,
    ES_JAVA_OPTS: config.esJavaOpts,
  };

  const args = [
    'run',
    '-d',
    '--name',
    config.containerName,
    '--restart',
    'unless-stopped',
    '--platform',
    config.platform,
    '-p',
    `${config.httpPort}:80`,
    '-p',
    `${config.mysqlPort}:3306`,
    '-p',
    `${config.redisPort}:6379`,
    '-v',
    `${config.dataDir}:/data`,
  ];

  for (const [key, value] of Object.entries(env)) {
    args.push('-e', `${key}=${value}`);
  }

  args.push(config.image);
  return args;
}

function boolString(value, defaultValue) {
  if (value === undefined || value === null || value === '') {
    return defaultValue ? 'true' : 'false';
  }
  if (typeof value === 'boolean') {
    return value ? 'true' : 'false';
  }
  const normalized = String(value).trim().toLowerCase();
  return ['1', 'true', 'yes', 'y', 'on'].includes(normalized) ? 'true' : 'false';
}
