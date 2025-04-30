#!/bin/bash

# 添加 sirpdboy 的 luci-app-advanced 包
git clone https://github.com/sirpdboy/luci-app-advanced.git package/luci-app-advanced

# 如果需要，还可以添加其他软件包或feeds源
# git clone [仓库地址] package/[目标目录名]

# 如果需要修改feeds源，可以在这里修改feeds.conf.default文件
# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default
# sed -i 's/^#\(.*passwall\)/\1/' feeds.conf.default
