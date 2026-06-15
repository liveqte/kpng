#!/bin/sh

# 检查 PORT 环境变量是否已定义且不为空
if [ -n "$PORT" ]; then
    echo "检测到 PORT 变量，正在将 Nginx 端口修改为: $PORT"
    # 使用 sed 替换 default.conf 中的 listen 80; 为 listen ${PORT};
    # [[:space:]]* 用于兼容不同数量的空格，提高健壮性
    sed -i "s/listen[[:space:]]*80;/listen ${PORT};/g" /etc/nginx/conf.d/default.conf
else
    echo "未检测到 PORT 变量，保持默认端口 80 不变"
fi

# 启动 Nginx 并保持前台运行 (daemon off)
# 使用 exec 可以让 nginx 进程替换当前 shell 进程，从而正确接收 Docker 的 SIGTERM 信号
exec nginx -g "daemon off;"