FROM nginx:alpine

# 复制你的 server 配置到默认目录
COPY ng.conf /etc/nginx/conf.d/default.conf

# 【核心】复制我们自定义的完整主配置到 /tmp 目录下
COPY my_nginx.conf /tmp/my_nginx.conf

# 复制启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh && sed -i 's/\r$//g' /start.sh

ENTRYPOINT ["/start.sh"]