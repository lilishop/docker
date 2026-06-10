# syntax=docker/dockerfile:1.7

FROM --platform=$TARGETPLATFORM node:20-bookworm-slim AS frontend-builder
WORKDIR /workspace
ENV NPM_CONFIG_LEGACY_PEER_DEPS=true \
    NPM_CONFIG_OMIT=peer \
    NPM_CONFIG_AUDIT=false \
    NPM_CONFIG_FUND=false \
    NODE_OPTIONS=--openssl-legacy-provider

COPY lilishop-ui ./lilishop-ui
COPY lilishop-uniapp ./lilishop-uniapp

RUN set -eux; \
  npm install -g --force yarn@1.22.22; \
  for app in buyer seller manager im; do \
    cd /workspace/lilishop-ui/$app; \
    rm -f package-lock.json npm-shrinkwrap.json yarn.lock; \
    yarn install --ignore-engines --non-interactive --network-timeout 600000; \
    case "$app" in \
      buyer) export VUE_APP_PUBLIC_PATH="/" ;; \
      seller) export VUE_APP_PUBLIC_PATH="/seller/" ;; \
      manager) export VUE_APP_PUBLIC_PATH="/manager/" ;; \
      im) export VUE_APP_PUBLIC_PATH="/im/" ;; \
    esac; \
    yarn build; \
    unset VUE_APP_PUBLIC_PATH; \
  done; \
  cd /workspace/lilishop-uniapp; \
  npm install; \
  npm run build:h5

FROM --platform=$BUILDPLATFORM maven:3.9.9-eclipse-temurin-21 AS backend-builder
WORKDIR /workspace/lilishop
COPY lilishop .
RUN mvn -pl lilishop-all -am -DskipTests package

FROM eclipse-temurin:21-jre-jammy AS runtime

ARG TARGETARCH
ARG ES_VERSION=7.17.19
ARG KIBANA_VERSION=7.17.19
ARG LOGSTASH_VERSION=7.17.19
ARG INCLUDE_KIBANA=false
ARG INCLUDE_LOGSTASH=false
ARG ROCKETMQ_VERSION=4.9.6

ENV DEBIAN_FRONTEND=noninteractive \
    LILI_HOME=/opt/lilishop \
    LILI_DATA=/data \
    LILI_HTTP_PORT=80 \
    LILI_API_PORT=8080 \
    LILI_H5_PORT=10001 \
    LILI_HOST=127.0.0.1 \
    MYSQL_ROOT_PASSWORD=lilishop \
    REDIS_PASSWORD=lilishop \
    ENABLE_ELASTICSEARCH=true \
    ENABLE_KIBANA=false \
    ENABLE_LOGSTASH=false \
    ENABLE_ROCKETMQ_DASHBOARD=false \
    JAVA_OPTS="-Xms512m -Xmx1024m" \
    ES_JAVA_OPTS="-Xms512m -Xmx512m"

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    gettext-base \
    gosu \
    libaio1 \
    libncurses6 \
    mariadb-server \
    nginx \
    procps \
    python3 \
    python3-bcrypt \
    redis-server \
    supervisor \
    tar \
    tini \
    tzdata \
    unzip; \
  rm -rf /var/lib/apt/lists/*; \
  mkdir -p /opt/lilishop /opt/downloads /data /run/mysqld /var/log/supervisor /var/log/lilishop; \
  chown -R mysql:mysql /run/mysqld /var/lib/mysql

RUN set -eux; \
  download_artifact() { \
    url="$1"; \
    output="$2"; \
    echo "Downloading ${url}"; \
    curl \
      --fail \
      --location \
      --show-error \
      --retry 5 \
      --retry-delay 5 \
      --retry-all-errors \
      --connect-timeout 30 \
      --speed-time 120 \
      --speed-limit 1024 \
      --max-time 1800 \
      "$url" \
      -o "$output"; \
  }; \
  case "$TARGETARCH" in \
    amd64) elastic_arch="linux-x86_64" ;; \
    arm64) elastic_arch="linux-aarch64" ;; \
    *) echo "Unsupported TARGETARCH=$TARGETARCH" >&2; exit 1 ;; \
  esac; \
  download_artifact "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}-${elastic_arch}.tar.gz" /opt/downloads/elasticsearch.tar.gz; \
  tar -xzf /opt/downloads/elasticsearch.tar.gz -C /opt/lilishop; \
  mv "/opt/lilishop/elasticsearch-${ES_VERSION}" /opt/lilishop/elasticsearch; \
  if [ "$INCLUDE_KIBANA" = "true" ]; then \
    download_artifact "https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-${elastic_arch}.tar.gz" /opt/downloads/kibana.tar.gz; \
    tar -xzf /opt/downloads/kibana.tar.gz -C /opt/lilishop; \
    mv "/opt/lilishop/kibana-${KIBANA_VERSION}-${elastic_arch}" /opt/lilishop/kibana; \
  fi; \
  if [ "$INCLUDE_LOGSTASH" = "true" ]; then \
    download_artifact "https://artifacts.elastic.co/downloads/logstash/logstash-${LOGSTASH_VERSION}-${elastic_arch}.tar.gz" /opt/downloads/logstash.tar.gz; \
    tar -xzf /opt/downloads/logstash.tar.gz -C /opt/lilishop; \
    mv "/opt/lilishop/logstash-${LOGSTASH_VERSION}" /opt/lilishop/logstash; \
  fi; \
  rm -f /opt/downloads/elasticsearch.tar.gz /opt/downloads/kibana.tar.gz /opt/downloads/logstash.tar.gz; \
  useradd -r -s /usr/sbin/nologin elasticsearch || true; \
  chown -R elasticsearch:elasticsearch /opt/lilishop/elasticsearch

COPY docker/all-in-one/vendor/rocketmq /opt/lilishop/rocketmq
COPY docker/all-in-one/vendor/rocketmq-dashboard-1.0.0.jar /opt/lilishop/rocketmq-dashboard.jar

RUN set -eux; \
  sed -i 's/[[:space:]]*-XX:[+-]UseBiasedLocking//g' /opt/lilishop/rocketmq/bin/runserver.sh /opt/lilishop/rocketmq/bin/runbroker.sh

COPY --from=frontend-builder /usr/local /usr/local
COPY --from=backend-builder /workspace/lilishop/lilishop-all/target/lilishop-all-4.3.jar /opt/lilishop/lilishop-all.jar
COPY docker/all-in-one/vendor/xxl-job-admin-2.3.0.jar /opt/lilishop/xxl-job-admin.jar
COPY --from=frontend-builder /workspace/lilishop-ui/buyer/dist /opt/lilishop/www/buyer
COPY --from=frontend-builder /workspace/lilishop-ui/seller/dist /opt/lilishop/www/seller
COPY --from=frontend-builder /workspace/lilishop-ui/manager/dist /opt/lilishop/www/manager
COPY --from=frontend-builder /workspace/lilishop-ui/im/dist /opt/lilishop/www/im
COPY --from=frontend-builder /workspace/lilishop-uniapp/unpackage/dist/build/h5 /opt/lilishop/www/h5
COPY --from=frontend-builder /workspace/lilishop-uniapp /opt/lilishop/uniapp

COPY docker/init/mysql /opt/lilishop/init/mysql
COPY docker/config/my.cnf /etc/mysql/mariadb.conf.d/99-lilishop.cnf
COPY docker/config/broker.conf /opt/lilishop/templates/broker.conf.source
COPY docker/config/logstash-springboot.conf /opt/lilishop/templates/logstash-springboot.conf.source
COPY docker/all-in-one/templates /opt/lilishop/templates
COPY docker/all-in-one/scripts /opt/lilishop/scripts
COPY docker/all-in-one/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY docker/all-in-one/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh /opt/lilishop/scripts/*.sh; \
  rm -f /etc/nginx/sites-enabled/default; \
  mkdir -p /opt/lilishop/runtime /opt/lilishop/www/shared

EXPOSE 80 8080 3306 6379 9200 9876 10909 10911 9001 8180 10001
HEALTHCHECK --interval=30s --timeout=10s --start-period=180s --retries=5 CMD /opt/lilishop/scripts/healthcheck.sh
VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
