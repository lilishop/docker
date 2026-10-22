import net from 'node:net';

export function normalizeBaseUrl(value) {
  return String(value || '').trim().replace(/\/+$/, '');
}

export function buildRuntimeConfig(input = {}) {
  const host = input.host || '127.0.0.1';
  const apiBaseUrl = normalizeBaseUrl(input.apiBaseUrl || `http://${host}:8080`);
  const buyerApiUrl = normalizeBaseUrl(input.buyerApiUrl || `http://${host}:8888`);
  const managerApiUrl = normalizeBaseUrl(input.managerApiUrl || `http://${host}:8887`);
  const imApiUrl = normalizeBaseUrl(input.imApiUrl || `http://${host}:8885`);
  const wsProtocol = apiBaseUrl.startsWith('https://') ? 'wss' : 'ws';
  const apiHost = apiBaseUrl.replace(/^https?:\/\//, '');

  return {
    host,
    apiBaseUrl,
    buyerApiUrl,
    managerApiUrl,
    imApiUrl,
    buyerPcUrl: normalizeBaseUrl(input.buyerPcUrl || `http://${host}:10000`),
    uniappH5Url: normalizeBaseUrl(input.uniappH5Url || `http://${host}:10001`),
    sellerUrl: normalizeBaseUrl(input.sellerUrl || `http://${host}:10002`),
    managerUrl: normalizeBaseUrl(input.managerUrl || `http://${host}:10003`),
    imWebUrl: normalizeBaseUrl(input.imWebUrl || `http://${host}:8000`),
    imWsUrl: normalizeBaseUrl(input.imWsUrl || `${wsProtocol}://${apiHost}/lili/webSocket`),
  };
}

export function renderPcConfig({ apiBaseUrl, buyerApiUrl, managerApiUrl, buyerPcUrl, uniappH5Url, prefix = '' }) {
  const prefixLine = prefix ? `,\n  PREFIX: ${JSON.stringify(prefix)}` : '';
  const buyerBase = JSON.stringify(normalizeBaseUrl(buyerApiUrl || apiBaseUrl));
  const managerBase = JSON.stringify(normalizeBaseUrl(managerApiUrl || apiBaseUrl));

  return `var BASE = {
  API_DEV: {
    common: ${buyerBase},
    buyer: ${buyerBase},
    seller: ${managerBase},
    manager: ${managerBase}
  },
  API_PROD: {
    common: ${buyerBase},
    buyer: ${buyerBase},
    seller: ${managerBase},
    manager: ${managerBase}
  },
  PC_URL: ${JSON.stringify(normalizeBaseUrl(buyerPcUrl))},
  WAP_URL: ${JSON.stringify(normalizeBaseUrl(uniappH5Url))}${prefixLine}
};
`;
}

export function renderImEnv(config) {
  const imApi = config.imApiUrl || config.apiBaseUrl;
  const buyerApi = config.buyerApiUrl || config.apiBaseUrl;
  const managerApi = config.managerApiUrl || config.apiBaseUrl;

  return [
    'NODE_ENV=development',
    'VUE_APP_PREVIEW=false',
    `VUE_APP_API_BASE_URL=${imApi}`,
    `VUE_APP_WEB_SOCKET_URL=${config.imWsUrl}`,
    `VUE_APP_COMMON=${imApi}`,
    `VUE_APP_BUYER=${buyerApi}`,
    `VUE_APP_SELLER=${managerApi}`,
    'VUE_APP_WEBSITE_NAME="LiLi IM"',
    `VUE_APP_PC_URL=${config.buyerPcUrl}/`,
    `VUE_APP_PC_STORE=${config.sellerUrl}/`,
    '',
  ].join('\n');
}

export function renderUniappEnv(config) {
  const buyerApi = config.buyerApiUrl || config.apiBaseUrl;

  return [
    'NODE_ENV=development',
    `VUE_APP_API_BASE_URL=${buyerApi}`,
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
