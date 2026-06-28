#!/bin/sh

# ==========================================
# 1. 动态创建 /tmp 下的 Nginx 缓存目录
# ==========================================
# 因为云平台的 /tmp 每次启动都会清空，所以必须在启动 Nginx 前重新创建
mkdir -p /tmp/nginx/client_body \
         /tmp/nginx/proxy \
         /tmp/nginx/fastcgi \
         /tmp/nginx/uwsgi \
         /tmp/nginx/scgi

# ==========================================
# 2. 启动 Nginx (前台运行)
# ==========================================
exec nginx -g "daemon off;"