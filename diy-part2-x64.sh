#!/bin/bash
#=============================================================
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#=============================================================

# 修改默认 IP
sed -i 's/lan) ipad=${ipaddr:-"192.168.1.1"}/lan) ipad=${ipaddr:-"192.168.3.1"}/g' package/base-files/files/bin/config_generate

# 更精确地替换 PPPoE 的用户名和密码
sed -i "/proto='pppoe'/,/password=/ s/username='username'/username='27110912915'/g" package/base-files/files/bin/config_generate
sed -i "/proto='pppoe'/,/password=/ s/password='password'/password='288446'/g" package/base-files/files/bin/config_generate

# 更加精确的替换，包含完整的函数名和上下文
sed -i '/ucidef_set_interface "wan" device/,+5 s/protocol "${2:-dhcp}"/protocol "${2:-pppoe}"/g' package/base-files/files/lib/functions/uci-defaults.sh
# 如果需要，还可以添加其他修改
