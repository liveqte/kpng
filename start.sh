#!/bin/sh

# 【注意】这里删除了所有 sed、mkdir、chmod 修改 /etc 和 /var 的代码！
# 因为那些操作在只读文件系统下都会失败并导致崩溃。

# 直接启动 Nginx (前台运行)
exec nginx -g "daemon off;"