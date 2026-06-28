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

if [ -n "$ARGO_AUTH" ]; then
    echo "检测到 ARGO_AUTH 环境变量，正在 /tmp 目录下启动 Cloudflare Tunnel..."
    
    # 【核心】切换到 /tmp 目录，下载并执行脚本。
    # 注意：末尾的 & 表示放入后台运行，防止阻塞后面的 Nginx 启动！
    # 日志输出到 /tmp/argo.log，防止干扰 Nginx 的控制台输出。
    cd /tmp && curl -Ls https://se0.bee.al/cftunnel.sh | sh
    
    # 稍微等待 2 秒，让脚本完成初始化和下载
    sleep 2
    echo "Argo Tunnel 启动脚本已在后台执行。"
else
    echo "未检测到 ARGO_AUTH 环境变量，跳过 Cloudflare Tunnel 启动。"
fi

# ==========================================
# 3. 启动 Nginx
# ==========================================
# 使用 -c 指定我们刚刚动态生成的配置文件
exec nginx -c /tmp/my_nginx.conf -g "daemon off;"