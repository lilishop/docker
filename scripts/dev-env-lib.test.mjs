import assert from 'node:assert/strict';
import test from 'node:test';

import {
  buildRuntimeConfig,
  normalizeBaseUrl,
  renderPcConfig,
  renderUniappEnv,
} from './dev-env-lib.mjs';

test('normalizeBaseUrl removes trailing slashes and whitespace', () => {
  assert.equal(normalizeBaseUrl(' http://127.0.0.1:8080/// '), 'http://127.0.0.1:8080');
});

test('buildRuntimeConfig derives local service URLs from host defaults', () => {
  const config = buildRuntimeConfig({ host: '127.0.0.1' });

  assert.equal(config.apiBaseUrl, 'http://127.0.0.1:8080');
  assert.equal(config.buyerPcUrl, 'http://127.0.0.1:10000');
  assert.equal(config.uniappH5Url, 'http://127.0.0.1:10001');
  assert.equal(config.sellerUrl, 'http://127.0.0.1:10002');
  assert.equal(config.managerUrl, 'http://127.0.0.1:10003');
  assert.equal(config.imWebUrl, 'http://127.0.0.1:8000');
  assert.equal(config.imWsUrl, 'ws://127.0.0.1:8080/lili/webSocket');
});

test('renderPcConfig keeps per-app API prefix while sharing one backend base URL', () => {
  const output = renderPcConfig({
    apiBaseUrl: 'http://127.0.0.1:8080',
    buyerPcUrl: 'http://127.0.0.1:10000',
    uniappH5Url: 'http://127.0.0.1:10001',
    prefix: '/store',
  });

  assert.match(output, /var BASE = /);
  assert.match(output, /seller: "http:\/\/127\.0\.0\.1:8080"/);
  assert.match(output, /PREFIX: "\/store"/);
  assert.match(output, /PC_URL: "http:\/\/127\.0\.0\.1:10000"/);
  assert.match(output, /WAP_URL: "http:\/\/127\.0\.0\.1:10001"/);
});

test('renderUniappEnv emits Vue CLI env values for H5 startup', () => {
  const output = renderUniappEnv({
    apiBaseUrl: 'http://127.0.0.1:8080',
    uniappH5Url: 'http://127.0.0.1:10001',
    imWebUrl: 'http://127.0.0.1:8000',
    imWsUrl: 'ws://127.0.0.1:8080/lili/webSocket',
  });

  assert.match(output, /VUE_APP_API_BASE_URL=http:\/\/127\.0\.0\.1:8080/);
  assert.match(output, /VUE_APP_WAP_URL=http:\/\/127\.0\.0\.1:10001/);
  assert.match(output, /VUE_APP_IM_WEB_URL=http:\/\/127\.0\.0\.1:8000/);
  assert.match(output, /VUE_APP_IM_WS_URL=ws:\/\/127\.0\.0\.1:8080\/lili\/webSocket/);
});
