import net from 'node:net';

export function normalizeBaseUrl(value) {
  return String(value || '').trim().replace(/\/+$/, '');
}

export function buildRuntimeConfig(input = {}) {
  const host = input.host || '127.0.0.1';
  const apiBaseUrl = normalizeBaseUrl(input.apiBaseUrl || `http://${host}:8080`);
  const wsProtocol = apiBaseUrl.startsWith('https://') ? 'wss' : 'ws';
  const apiHost = apiBaseUrl.replace(/^https?:\/\//, '');

  return {
    host,
    apiBaseUrl,
    buyerPcUrl: normalizeBaseUrl(input.buyerPcUrl || `http://${host}:10000`),
    uniappH5Url: normalizeBaseUrl(input.uniappH5Url || `http://${host}:10001`),
    sellerUrl: normalizeBaseUrl(input.sellerUrl || `http://${host}:10002`),
    managerUrl: normalizeBaseUrl(input.managerUrl || `http://${host}:10003`),
    imWebUrl: normalizeBaseUrl(input.imWebUrl || `http://${host}:8000`),
    imWsUrl: normalizeBaseUrl(input.imWsUrl || `${wsProtocol}://${apiHost}/lili/webSocket`),
  };
}

export function renderPcConfig({ apiBaseUrl, buyerPcUrl, uniappH5Url, prefix = '' }) {
  const prefixLine = prefix ? `,\n  PREFIX: ${JSON.stringify(prefix)}` : '';
  const apiBase = JSON.stringify(normalizeBaseUrl(apiBaseUrl));

  return `var BASE = {
  API_DEV: {
    common: ${apiBase},
    buyer: ${apiBase},
    seller: ${apiBase},
    manager: ${apiBase}
  },
  API_PROD: {
    common: ${apiBase},
    buyer: ${apiBase},
    seller: ${apiBase},
    manager: ${apiBase}
  },
  PC_URL: ${JSON.stringify(normalizeBaseUrl(buyerPcUrl))},
  WAP_URL: ${JSON.stringify(normalizeBaseUrl(uniappH5Url))}${prefixLine}
};
`;
}

export function renderImEnv(config) {
  return [
    'NODE_ENV=development',
    'VUE_APP_PREVIEW=false',
    `VUE_APP_API_BASE_URL=${config.apiBaseUrl}`,
    `VUE_APP_WEB_SOCKET_URL=${config.imWsUrl}`,
    `VUE_APP_COMMON=${config.apiBaseUrl}`,
    `VUE_APP_BUYER=${config.apiBaseUrl}`,
    `VUE_APP_SELLER=${config.apiBaseUrl}`,
    'VUE_APP_WEBSITE_NAME="LiLi IM"',
    `VUE_APP_PC_URL=${config.buyerPcUrl}/`,
    `VUE_APP_PC_STORE=${config.sellerUrl}/`,
    '',
  ].join('\n');
}

export function renderUniappEnv(config) {
  return [
    'NODE_ENV=development',
    `VUE_APP_API_BASE_URL=${config.apiBaseUrl}`,
    `VUE_APP_WAP_URL=${config.uniappH5Url}`,
    `VUE_APP_IM_WEB_URL=${config.imWebUrl}`,
    `VUE_APP_IM_WS_URL=${config.imWsUrl}`,
    '',
  ].join('\n');
}

export function renderBackendOverride() {
  return `spring:
  data:
    redis:
      host: 127.0.0.1
      port: 6379
      password: lilishop
  datasource:
    url: jdbc:mysql://127.0.0.1:3306/lilishop?useUnicode=true&characterEncoding=utf-8&useSSL=false&rewriteBatchedStatements=true&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai
    username: root
    password: lilishop

lili:
  data:
    elasticsearch:
      enabled: false
      cluster-nodes: 127.0.0.1:9200
      schema: http
    logstash:
      server: 127.0.0.1:4560

rocketmq:
  name-server: 127.0.0.1:9876

xxl:
  job:
    admin:
      addresses: http://127.0.0.1:9001/xxl-job-admin
`;
}

export function parseUrlPort(urlValue) {
  const url = new URL(urlValue);
  return Number(url.port || (url.protocol === 'https:' ? 443 : 80));
}

export function waitForPort(port, host = '127.0.0.1', timeoutMs = 120000) {
  const started = Date.now();

  return new Promise((resolve, reject) => {
    const tryConnect = () => {
      const socket = net.connect({ port, host });
      socket.setTimeout(2000);
      socket.once('connect', () => {
        socket.destroy();
        resolve();
      });
      socket.once('timeout', () => socket.destroy());
      socket.once('error', () => {});
      socket.once('close', () => {
        if (Date.now() - started >= timeoutMs) {
          reject(new Error(`等待端口 ${host}:${port} 超时`));
          return;
        }
        setTimeout(tryConnect, 1000);
      });
    };
    tryConnect();
  });
}
