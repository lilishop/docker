var BASE = {
  API_DEV: {
    common: "http://${LILI_HOST}:${LILI_HTTP_PORT}/api",
    buyer: "http://${LILI_HOST}:${LILI_HTTP_PORT}/api",
    seller: "http://${LILI_HOST}:${LILI_HTTP_PORT}/api",
    manager: "http://${LILI_HOST}:${LILI_HTTP_PORT}/api"
  },
  API_PROD: {
    common: "http://${LILI_HOST}:${LILI_HTTP_PORT}/api",
    buyer: "http://${LILI_HOST}:${LILI_HTTP_PORT}/api",
    seller: "http://${LILI_HOST}:${LILI_HTTP_PORT}/api",
    manager: "http://${LILI_HOST}:${LILI_HTTP_PORT}/api"
  },
  PC_URL: "http://${LILI_HOST}:${LILI_HTTP_PORT}",
  WAP_URL: "http://${LILI_HOST}:${LILI_HTTP_PORT}/h5",
  IM_URL: "http://${LILI_HOST}:${LILI_HTTP_PORT}/im",
  IM_WS_URL: "ws://${LILI_HOST}:${LILI_HTTP_PORT}/lili/webSocket",
  PREFIX: "${LILI_API_PREFIX}"
};
