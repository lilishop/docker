#!/usr/bin/env bash
set -euo pipefail

supervisor_dir="$LILI_HOME/runtime/supervisor"
mkdir -p "$supervisor_dir"
rm -f "$supervisor_dir"/*.conf

cat > "$supervisor_dir/mariadb.conf" <<EOF
[program:mariadb]
command=/usr/sbin/mariadbd --user=mysql --datadir=${LILI_DATA}/mysql --bind-address=0.0.0.0 --port=3306
autorestart=true
stdout_logfile=${LILI_DATA}/logs/mariadb.log
stderr_logfile=${LILI_DATA}/logs/mariadb.err.log
priority=10
EOF

cat > "$supervisor_dir/redis.conf" <<EOF
[program:redis]
command=/usr/bin/redis-server ${LILI_HOME}/runtime/redis.conf
autorestart=true
stdout_logfile=${LILI_DATA}/logs/redis.log
stderr_logfile=${LILI_DATA}/logs/redis.err.log
priority=20
EOF

if [ "$ENABLE_ELASTICSEARCH" = "true" ]; then
  cat > "$supervisor_dir/elasticsearch.conf" <<EOF
[program:elasticsearch]
command=gosu elasticsearch ${LILI_HOME}/elasticsearch/bin/elasticsearch
environment=ES_JAVA_OPTS="${ES_JAVA_OPTS}",ES_JAVA_HOME="${LILI_HOME}/elasticsearch/jdk"
autorestart=true
stdout_logfile=${LILI_DATA}/logs/elasticsearch.log
stderr_logfile=${LILI_DATA}/logs/elasticsearch.err.log
priority=30
EOF
fi

if [ "$ENABLE_KIBANA" = "true" ]; then
  if [ ! -x "${LILI_HOME}/kibana/bin/kibana" ]; then
    echo "ENABLE_KIBANA=true, but Kibana is not included in this image. Rebuild with --build-arg INCLUDE_KIBANA=true." >&2
    exit 1
  fi
  cat > "$supervisor_dir/kibana.conf" <<EOF
[program:kibana]
command=${LILI_HOME}/kibana/bin/kibana --host 0.0.0.0 --port 5601 --elasticsearch.hosts=http://127.0.0.1:9200
autorestart=true
stdout_logfile=${LILI_DATA}/logs/kibana.log
stderr_logfile=${LILI_DATA}/logs/kibana.err.log
priority=35
EOF
fi

if [ "$ENABLE_LOGSTASH" = "true" ]; then
  if [ ! -x "${LILI_HOME}/logstash/bin/logstash" ]; then
    echo "ENABLE_LOGSTASH=true, but Logstash is not included in this image. Rebuild with --build-arg INCLUDE_LOGSTASH=true." >&2
    exit 1
  fi
  cat > "$supervisor_dir/logstash.conf" <<EOF
[program:logstash]
command=${LILI_HOME}/logstash/bin/logstash -f ${LILI_HOME}/runtime/logstash-springboot.conf
autorestart=true
stdout_logfile=${LILI_DATA}/logs/logstash.log
stderr_logfile=${LILI_DATA}/logs/logstash.err.log
priority=36
EOF
fi

cat > "$supervisor_dir/rocketmq-namesrv.conf" <<EOF
[program:rocketmq-namesrv]
command=${LILI_HOME}/rocketmq/bin/mqnamesrv
environment=JAVA_HOME="${JAVA_HOME:-/opt/java/openjdk}",PATH="${PATH}",JAVA_OPT_EXT="-Xms128m -Xmx256m -Xmn128m"
autorestart=true
stdout_logfile=${LILI_DATA}/logs/rocketmq-namesrv.log
stderr_logfile=${LILI_DATA}/logs/rocketmq-namesrv.err.log
priority=40
EOF

cat > "$supervisor_dir/rocketmq-broker.conf" <<EOF
[program:rocketmq-broker]
command=${LILI_HOME}/rocketmq/bin/mqbroker -c ${LILI_HOME}/runtime/broker.conf
environment=JAVA_HOME="${JAVA_HOME:-/opt/java/openjdk}",PATH="${PATH}",NAMESRV_ADDR="127.0.0.1:9876",JAVA_OPT_EXT="-Xms256m -Xmx512m -Xmn128m --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-exports=java.base/jdk.internal.ref=ALL-UNNAMED"
autorestart=true
stdout_logfile=${LILI_DATA}/logs/rocketmq-broker.log
stderr_logfile=${LILI_DATA}/logs/rocketmq-broker.err.log
priority=50
EOF

if [ "$ENABLE_ROCKETMQ_DASHBOARD" = "true" ]; then
  cat > "$supervisor_dir/rocketmq-dashboard.conf" <<EOF
[program:rocketmq-dashboard]
command=java -jar ${LILI_HOME}/rocketmq-dashboard.jar --server.port=8180 --rocketmq.config.namesrvAddr=127.0.0.1:9876 --rocketmq.config.isVIPChannel=false
autorestart=true
stdout_logfile=${LILI_DATA}/logs/rocketmq-dashboard.log
stderr_logfile=${LILI_DATA}/logs/rocketmq-dashboard.err.log
priority=55
EOF
fi

cat > "$supervisor_dir/xxl-job.conf" <<EOF
[program:xxl-job]
command=java -jar ${LILI_HOME}/xxl-job-admin.jar --spring.config.location=file:${LILI_HOME}/runtime/xxl-job-application.properties
autorestart=true
stdout_logfile=${LILI_DATA}/logs/xxl-job.log
stderr_logfile=${LILI_DATA}/logs/xxl-job.err.log
priority=60
EOF

cat > "$supervisor_dir/lilishop.conf" <<EOF
[program:lilishop]
command=java ${JAVA_OPTS} -jar ${LILI_HOME}/lilishop-all.jar --spring.profiles.active=dev --spring.config.additional-location=file:${LILI_HOME}/runtime/application-runtime.yml
autorestart=true
stdout_logfile=${LILI_DATA}/logs/lilishop.log
stderr_logfile=${LILI_DATA}/logs/lilishop.err.log
priority=70
EOF

cat > "$supervisor_dir/nginx.conf" <<EOF
[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autorestart=true
stdout_logfile=${LILI_DATA}/logs/nginx.log
stderr_logfile=${LILI_DATA}/logs/nginx.err.log
priority=80
EOF

cat > "$supervisor_dir/h5.conf" <<EOF
[program:h5]
command=${LILI_HOME}/scripts/run-h5.sh
autorestart=true
stdout_logfile=${LILI_DATA}/logs/h5.log
stderr_logfile=${LILI_DATA}/logs/h5.err.log
priority=90
EOF
