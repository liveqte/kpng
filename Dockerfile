FROM nginx:alpine

# 1. 复制你的 server 配置 (这个放在 /etc/nginx/conf.d 下，运行时只读但不影响读取)
COPY ng.conf /etc/nginx/conf.d/default.conf

# 2. 复制启动脚本
COPY start.sh /start.sh

RUN apk update && apk add bash
# 赋予执行权限并修复换行符
RUN chmod +x /start.sh && sed -i 's/\r$//g' /start.sh

ENTRYPOINT ["/start.sh"]