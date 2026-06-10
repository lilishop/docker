port 6379
bind 0.0.0.0
protected-mode no
requirepass ${REDIS_PASSWORD}
dir ${LILI_DATA}/redis
appendonly yes
