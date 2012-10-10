upstream backend {
  server 127.0.0.1:2341;
}

server {
  server_name urbantou.ch;
  index index.html;

  root /home/bmishra/source/nodestore/public;

  access_log /var/log/nginx/urbantou.ch.access.log;
  error_log  /var/log/nginx/urbantou.ch.error.log;

  location ~ ^/(js|css|images|media|system)/ {
    autoindex off;
    add_header Cache-Control public;
    expires 4w;
  }

  location / {
    proxy_pass http://backend;
  }
}

server {
  server_name www.urbantou.ch;
  rewrite ^(.*) http://urbantou.ch$1 permanent;
}

server {
  listen 443 ssl;
  server_name urbantou.ch;
  index index.html index.htm;

  root /home/bmishra/source/nodestore/public;

  access_log /var/log/nginx/https.access.log;
  error_log  /var/log/nginx/https.error.log;

  ssl on;
  ssl_certificate /home/bmishra/local/nginx/conf/server.crt;
  ssl_certificate_key /home/bmishra/local/nginx/conf/server.key;

  ssl_session_timeout  5m;
  keepalive_timeout 70;
  proxy_set_header X-Forwarded-Proto https;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;

  # location = / {
  #   rewrite ^ http://$server_name$request_uri? permanent;
  # }

  location / {
    try_files $uri $uri/index.html @proxy;
  }

  location @proxy {
    proxy_pass   http://backend;
  }
}
