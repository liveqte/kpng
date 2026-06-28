#!/bin/sh

# 1. 动态创建 /tmp 下的 Nginx 缓存目录 (因为 /tmp 每次启动会被清空)
mkdir -p /tmp/nginx/client_body \
         /tmp/nginx/proxy \
         /tmp/nginx/fastcgi \
         /tmp/nginx/uwsgi \
         /tmp/nginx/scgi

# 2. 启动 Nginx
# -c /tmp/my_nginx.conf : 使用我们自定义的主配置，彻底绕过官方默认配置的限制
# -g "daemon off;" : 保持前台运行
exec nginx -c /tmp/my_nginx.conf -g "daemon off;"