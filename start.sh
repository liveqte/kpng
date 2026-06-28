#!/bin/sh

# ==========================================
# 1. 解决云平台非 root 用户运行时的权限问题
# ==========================================
# 提前创建 nginx 需要的临时目录，并赋予最高权限 (777)
# 这样无论云平台以什么用户运行，都不会报 Permission denied
mkdir -p /var/cache/nginx/client_temp \
         /var/cache/nginx/proxy_temp \
         /var/cache/nginx/fastcgi_temp \
         /var/cache/nginx/uwsgi_temp \
         /var/cache/nginx/scgi_temp \
         /var/log/nginx \
         /var/run 2>/dev/null || true

chmod -R 777 /var/cache/nginx /var/log/nginx /var/run 2>/dev/null || true

# 移除 nginx.conf 中的 user 指令，防止非 root 运行时报警告或报错
sed -i '/^user/d' /etc/nginx/nginx.conf

# ==========================================
# 2. 动态修改 Nginx 监听端口 (你的逻辑)
# ==========================================
if [ -n "$PORT" ]; then
    echo "检测到 PORT 变量，正在将 Nginx 端口修改为: $PORT"
    # 使用 sed 替换 default.conf 中的 listen 80; 为 listen ${PORT};
    # [[:space:]]* 用于兼容不同数量的空格，提高健壮性
    sed -i "s/listen[[:space:]]*80;/listen ${PORT};/g" /etc/nginx/conf.d/default.conf
else
    echo "未检测到 PORT 变量，保持默认端口 80 不变"
fi

# ==========================================
# 3. 启动 Nginx (前台运行)
# ==========================================
# 使用 exec 替换当前 shell 进程，确保 nginx 能正确接收停止信号
exec nginx -g "daemon off;"