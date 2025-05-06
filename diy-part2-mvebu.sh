#!/bin/bash

# 更精确地替换 PPPoE 的用户名和密码
sed -i "/proto='pppoe'/,/password=/ s/username='username'/username='$PPPOE_USERNAME1'/g" package/base-files/files/bin/config_generate
sed -i "/proto='pppoe'/,/password=/ s/password='password'/password='$PPPOE_PASSWORD1'/g" package/base-files/files/bin/config_generate

# 更加精确的替换，包含完整的函数名和上下文
sed -i '/ucidef_set_interface "wan" device/,+5 s/protocol "${2:-dhcp}"/protocol "${2:-pppoe}"/g' package/base-files/files/lib/functions/uci-defaults.sh

#修改默认时区
#sed -i "s/timezone='GMT0'/timezone='Asia\/Shanghai'/" package/base-files/files/bin/config_generate

#修改默认shell为bash
#sed -i 's|root:x:0:0:root:/root:/bin/ash|root:x:0:0:root:/root:/bin/bash|' package/base-files/files/etc/passwd

# 将 LAN 口从 eth0 修改为 10g-2
#sed -i 's/ucidef_set_interface_lan '\''eth0'\''/ucidef_set_interface_lan '\''10g-2'\''/' package/base-files/files/etc/board.d/99-default_network

# 将 WAN 口从 eth1 修改为 10g-1
sed -i 's/ucidef_set_interface_wan '\''eth1'\''/ucidef_set_interface_wan '\''eth2'\''/' package/base-files/files/etc/board.d/99-default_network

# 创建自定义网络配置文件目录
echo 'Creating custom network config files...'
mkdir -p files/etc/config/

# 写入自定义网络配置
if [ -n "$NETWORK_CONFIG_MVEBU" ]; then
  echo "$NETWORK_CONFIG_MVEBU" > files/etc/config/network
  echo "Custom network config created."
else
  echo "Warning: NETWORK_CONFIG_MVEBU is not set."
fi

# 写入自定义防火墙配置
if [ -n "$FIREWALL_CONFIG_MVEBU" ]; then
  echo "$FIREWALL_CONFIG_MVEBU" > files/etc/config/firewall
  echo "Custom firewall config created."
else
  echo "Warning: FIREWALL_CONFIG_MVEBU is not set."
fi

# 写入自定义DHCP配置
if [ -n "$DHCP_CONFIG_MVEBU" ]; then
  echo "$DHCP_CONFIG_MVEBU" > files/etc/config/dhcp
  echo "Custom DHCP config created."
else
  echo "Warning: DHCP_CONFIG_MVEBU is not set."
fi

# 设置配置文件权限
chmod 644 files/etc/config/network
chmod 644 files/etc/config/firewall
chmod 644 files/etc/config/dhcp

echo 'Custom configurations have been created!'
# 如果需要，还可以添加其他修改
