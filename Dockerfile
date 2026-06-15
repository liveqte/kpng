# 使用官方的 nginx alpine 轻量级镜像
FROM nginx:alpine

# 将本地的 ng.conf 复制为容器内的 default.conf
COPY ng.conf /etc/nginx/conf.d/default.conf

# 将启动脚本复制到容器根目录
COPY start.sh /start.sh

# 赋予 start.sh 可执行权限
RUN chmod +x /start.sh

# 设置容器启动时的入口点为 start.sh
ENTRYPOINT ["/start.sh"]