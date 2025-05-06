#!/bin/bash

# 更精确地替换 PPPoE 的用户名和密码
sed -i "/proto='pppoe'/,/password=/ s/username='username'/username='$PPPOE_USERNAME1'/g" package/base-files/files/bin/config_generate
sed -i "/proto='pppoe'/,/password=/ s/password='password'/password='$PPPOE_PASSWORD1'/g" package/base-files/files/bin/config_generate

# 更加精确的替换，包含完整的函数名和上下文
sed -i '/ucidef_set_interface "wan" device/,+5 s/protocol "${2:-dhcp}"/protocol "${2:-pppoe}"/g' package/base-files/files/lib/functions/uci-defaults.sh

#修改默认shell为bash
#sed -i 's|root:x:0:0:root:/root:/bin/ash|root:x:0:0:root:/root:/bin/bash|' package/base-files/files/etc/passwd

# 将 LAN 口从 eth0 修改为 10g-2
sed -i 's/ucidef_set_interface_lan '\''eth0'\''/ucidef_set_interface_lan '\''10g-2'\''/' package/base-files/files/etc/board.d/99-default_network

# 将 WAN 口从 eth1 修改为 10g-1
sed -i 's/ucidef_set_interface_wan '\''eth1'\''/ucidef_set_interface_wan '\''10g-1'\''/' package/base-files/files/etc/board.d/99-default_network

# 创建自定义网络配置文件目录
echo 'Creating custom network config files...'
mkdir -p files/etc/config/

# 写入自定义网络配置
if [ -n "$NETWORK_CONFIG_301W" ]; then
  echo "$NETWORK_CONFIG_301W" > files/etc/config/network
  echo "Custom network config created."
else
  echo "Warning: NETWORK_CONFIG_MVEBU is not set."
fi

# 写入自定义防火墙配置
if [ -n "$FIREWALL_CONFIG_301W" ]; then
  echo "$FIREWALL_CONFIG_301W" > files/etc/config/firewall
  echo "Custom firewall config created."
else
  echo "Warning: FIREWALL_CONFIG_MVEBU is not set."
fi

# 写入自定义DHCP配置
if [ -n "$DHCP_CONFIG_301W" ]; then
  echo "$DHCP_CONFIG_301W" > files/etc/config/dhcp
  echo "Custom DHCP config created."
else
  echo "Warning: DHCP_CONFIG_MVEBU is not set."
fi

# 写入自定义路由更新脚本到hotplug.d目录
if [ -n "$UPDATE_ROUTE" ]; then
  # 先创建必要的目录结构
  mkdir -p files/etc/hotplug.d/iface
  
  # 然后写入文件
  echo "$UPDATE_ROUTE" > files/etc/hotplug.d/iface/99-update-route
  chmod 755 files/etc/hotplug.d/iface/99-update-route  # 设置为可执行权限
  echo "Custom route update script created."
else
  echo "Warning: UPDATE_ROUTE is not set."
fi

# 设置配置文件权限
chmod 644 files/etc/config/network
chmod 644 files/etc/config/firewall
chmod 644 files/etc/config/dhcp

echo 'Custom configurations have been created!'

# 创建或修改 ddns-go 配置文件
mkdir -p files/etc/config
cat > files/etc/config/ddns-go << EOF
config ddns-go 'config'
	option enabled '1'
	option listen '[::]:9876'
	option ttl '300'
EOF
echo "已创建 ddns-go 自定义配置文件，并设置为自动启动"

# 创建 ddns-go 配置目录
mkdir -p files/etc/ddns-go

# 创建 uci-defaults 目录
mkdir -p files/etc/uci-defaults

# 从环境变量获取配置并写入 config.yaml
if [ -n "$DDNS_301W" ]; then
    echo "$DDNS_301W" > files/etc/ddns-go/config.yaml
    # 确保文件权限正确
    cat > files/etc/uci-defaults/99-ddns-go-config << EOF
#!/bin/sh
chmod 644 /etc/ddns-go/config.yaml
chown ddns-go:ddns-go /etc/ddns-go/config.yaml 2>/dev/null || true
exit 0
EOF
    chmod 755 files/etc/uci-defaults/99-ddns-go-config
    echo "创建 ddns-go 配置文件成功"
else
    echo "警告: 未找到 DDNS_M902 环境变量，无法创建 ddns-go 配置文件"
fi
