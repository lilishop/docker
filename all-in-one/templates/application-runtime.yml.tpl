server:
  port: ${LILI_API_PORT}
  servlet:
    context-path: /

spring:
  data:
    redis:
      host: 127.0.0.1
      port: 6379
      password: ${REDIS_PASSWORD}
  datasource:
    url: jdbc:mysql://127.0.0.1:3306/lilishop?useUnicode=true&characterEncoding=utf-8&useSSL=false&rewriteBatchedStatements=true&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai
    username: root
    password: ${MYSQL_ROOT_PASSWORD}

lili:
  system:
    # all-in-one 是本地完整体验环境，默认关闭演示站拦截；需要只读演示时可传 LILI_DEMO_SITE=true。
    isDemoSite: ${LILI_DEMO_SITE}
  data:
    elasticsearch:
      enabled: ${ENABLE_ELASTICSEARCH}
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
    executor:
      appname: xxl-job-executor-lilishop
      logpath: ${LILI_DATA}/xxl-job/executor
      logretentiondays: 7
