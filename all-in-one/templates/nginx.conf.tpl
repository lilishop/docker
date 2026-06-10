worker_processes auto;
pid /run/nginx.pid;

events {
  worker_connections 1024;
}

http {
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  sendfile on;
  keepalive_timeout 65;

  server {
    listen 80;
    server_name _;

    location / {
      root /opt/lilishop/www/buyer;
      try_files $uri $uri/ /index.html;
    }

    location /seller/ {
      alias /opt/lilishop/www/seller/;
      try_files $uri $uri/ /seller/index.html;
    }

    location /manager/ {
      alias /opt/lilishop/www/manager/;
      try_files $uri $uri/ /manager/index.html;
    }

    location /im/ {
      alias /opt/lilishop/www/im/;
      try_files $uri $uri/ /im/index.html;
    }

    location /h5/ {
      proxy_pass http://127.0.0.1:${LILI_H5_PORT}/h5/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /sockjs-node/ {
      proxy_pass http://127.0.0.1:${LILI_H5_PORT}/sockjs-node/;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Host $host;
    }

    location /static/ {
      root /opt/lilishop/www/buyer;
      try_files $uri =404;
    }

    location /api/api/ {
      proxy_pass http://127.0.0.1:${LILI_API_PORT}/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api/ {
      proxy_pass http://127.0.0.1:${LILI_API_PORT}/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /lili/webSocket {
      proxy_pass http://127.0.0.1:${LILI_API_PORT}/lili/webSocket;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Host $host;
    }
  }
}
