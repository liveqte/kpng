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
# 2. 启动 Nginx (核心修改在这里)
# ==========================================
# 通过 -g 参数动态覆盖配置：
# 1. pid /tmp/nginx.pid;  -> 解决 /run/nginx.pid 权限拒绝问题
# 2. error_log /dev/stderr; -> 顺便把错误日志输出到控制台，防止写 /var/log 报权限错误
# 3. daemon off; -> 保持前台运行
exec nginx -g "daemon off; pid /tmp/nginx.pid; error_log /dev/stderr;"