#!/bin/sh

# ==========================================
# 1. 动态创建 /tmp 下的 Nginx 缓存目录
# ==========================================
mkdir -p /tmp/nginx/client_body \
         /tmp/nginx/proxy \
         /tmp/nginx/fastcgi \
         /tmp/nginx/uwsgi \
         /tmp/nginx/scgi

# ==========================================
# 2. 动态生成 Nginx 主配置文件到 /tmp
# ==========================================
# 因为云平台的 /tmp 启动时是空的，所以我们用代码直接把它写出来
cat << 'NGINX_CONF' > /tmp/my_nginx.conf
worker_processes auto;
error_log /dev/stderr notice;
pid /tmp/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    client_body_temp_path /tmp/nginx/client_body;
    proxy_temp_path /tmp/nginx/proxy;
    fastcgi_temp_path /tmp/nginx/fastcgi;
    uwsgi_temp_path /tmp/nginx/uwsgi;
    scgi_temp_path /tmp/nginx/scgi;

    # 引入你的 server 配置
    include /etc/nginx/conf.d/default.conf;
}
NGINX_CONF

# ==========================================
# 3. 启动 Nginx
# ==========================================
# 使用 -c 指定我们刚刚动态生成的配置文件
exec nginx -c /tmp/my_nginx.conf -g "daemon off;"