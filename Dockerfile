# 使用官方的 nginx alpine 轻量级镜像
FROM nginx:alpine

# 将本地的 ng.conf 复制为容器内的 default.conf
COPY ng.conf /etc/nginx/conf.d/default.conf

# 【核心修改】在构建阶段，提前创建 /tmp 下的缓存目录，并赋予 777 权限
# 这样无论云平台以什么用户运行，都能往 /tmp 里写临时文件
RUN mkdir -p /tmp/nginx/client_body \
             /tmp/nginx/proxy \
             /tmp/nginx/fastcgi \
             /tmp/nginx/uwsgi \
             /tmp/nginx/scgi \
    && chmod -R 777 /tmp/nginx

# 将启动脚本复制到容器根目录
COPY start.sh /start.sh

# 赋予 start.sh 可执行权限，并修复 Windows 换行符问题
RUN chmod +x /start.sh && sed -i 's/\r$//g' /start.sh

# 设置容器启动时的入口点为 start.sh
ENTRYPOINT ["/start.sh"]