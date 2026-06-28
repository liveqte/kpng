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
# 2. 获取当前运行用户的 UID (关键！)
# ==========================================
CURRENT_UID=$(id -u)

# 如果当前是 root (UID 0)，显式指定为 root；否则指定为当前 UID
# 这样 Nginx 的 master 和 worker 用户一致，就不会触发 chown 操作
if [ "$CURRENT_UID" -eq 0 ]; then
    NGINX_USER="root"
else
    NGINX_USER="$CURRENT_UID"
fi

# ==========================================
# 3. 动态生成 Nginx 主配置文件到 /tmp
# ==========================================
# 【注意】这里的 NGINX_CONF 前面【绝对不能有单引号】！
# 否则 $NGINX_USER 变量不会被解析替换！
cat << NGINX_CONF > /tmp/my_nginx.conf
worker_processes auto;
error_log /dev/stderr notice;
pid /tmp/nginx.pid;

# 【核心修改】动态设置 user，绕过 chown 权限拒绝
user $NGINX_USER;

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

    include /etc/nginx/conf.d/default.conf;
}
NGINX_CONF

# ==========================================
# 4. 检测并启动 Argo Tunnel (如果配置了 ARGO_AUTH)
# ==========================================
if [ -n "$ARGO_AUTH" ]; then
    echo "检测到 ARGO_AUTH 环境变量，正在 /tmp 目录下启动 Cloudflare Tunnel..."
    cd /tmp && curl -Ls https://gbjs.serv00.net/cftunnel.sh | bash
    sleep 2
    echo "Argo Tunnel 启动脚本已在后台执行。"
else
    echo "未检测到 ARGO_AUTH 环境变量，跳过 Cloudflare Tunnel 启动。"
fi

# ==========================================
# 5. 启动 Nginx
# ==========================================
exec nginx -c /tmp/my_nginx.conf -g "daemon off;"