#!/bin/bash
# 添加更明显的步骤分隔和状态输出
echo "===== 开始应用自定义配置 ====="

# 更精确地替换 PPPoE 的用户名和密码
echo "正在配置 PPPoE 连接设置..."
sed -i "/proto='pppoe'/,/password=/ s/username='username'/username='$PPPOE_USERNAME2'/g" package/base-files/files/bin/config_generate
sed -i "/proto='pppoe'/,/password=/ s/password='password'/password='$PPPOE_PASSWORD2'/g" package/base-files/files/bin/config_generate
echo "✅ PPPoE 设置已配置"

# 更加精确的替换，包含完整的函数名和上下文
echo "正在设置默认WAN协议为PPPoE..."
sed -i '/ucidef_set_interface "wan" device/,+5 s/protocol "${2:-dhcp}"/protocol "${2:-pppoe}"/g' package/base-files/files/lib/functions/uci-defaults.sh
echo "✅ 默认WAN协议已设置为PPPoE"

# 修改默认网络接口
echo "正在修改默认网络接口设置..."
sed -i 's/ucidef_set_interface_lan '\''eth0'\''/ucidef_set_interface_lan '\''10g-2'\''/' package/base-files/files/etc/board.d/99-default_network
sed -i 's/ucidef_set_interface_wan '\''eth1'\''/ucidef_set_interface_wan '\''10g-1'\''/' package/base-files/files/etc/board.d/99-default_network
echo "✅ 默认网络接口已修改: LAN=10g-2, WAN=10g-1"

# 创建自定义网络配置文件目录
echo "正在创建自定义配置文件目录..."
mkdir -p files/etc/config/
echo "✅ 配置文件目录已创建"

# 写入自定义网络配置
echo "正在应用自定义网络配置..."
if [ -n "$NETWORK_CONFIG_301W" ]; then
  echo "$NETWORK_CONFIG_301W" > files/etc/config/network
  echo "✅ 自定义网络配置已应用"
else
  echo "⚠️ 警告: NETWORK_CONFIG_301W 未设置，跳过网络配置"
fi

# 写入自定义防火墙配置
echo "正在应用自定义防火墙配置..."
if [ -n "$FIREWALL_CONFIG_301W" ]; then
  echo "$FIREWALL_CONFIG_301W" > files/etc/config/firewall
  echo "✅ 自定义防火墙配置已应用"
else
  echo "⚠️ 警告: FIREWALL_CONFIG_301W 未设置，跳过防火墙配置"
fi

# 写入自定义DHCP配置
echo "正在应用自定义DHCP配置..."
if [ -n "$DHCP_CONFIG_301W" ]; then
  echo "$DHCP_CONFIG_301W" > files/etc/config/dhcp
  echo "✅ 自定义DHCP配置已应用"
else
  echo "⚠️ 警告: DHCP_CONFIG_301W 未设置，跳过DHCP配置"
fi

# 写入自定义路由更新脚本到hotplug.d目录
echo "正在设置自定义路由更新脚本..."
if [ -n "$UPDATE_ROUTE" ]; then
  # 先创建必要的目录结构
  mkdir -p files/etc/hotplug.d/iface
  
  # 然后写入文件
  echo "$UPDATE_ROUTE" > files/etc/hotplug.d/iface/99-update-route
  chmod 755 files/etc/hotplug.d/iface/99-update-route  # 设置为可执行权限
  echo "✅ 自定义路由更新脚本已创建并设置权限"
else
  echo "⚠️ 警告: UPDATE_ROUTE 未设置，跳过路由更新脚本"
fi

# 设置配置文件权限
echo "正在设置配置文件权限..."
chmod 644 files/etc/config/network 2>/dev/null || echo "⚠️ 网络配置文件不存在，跳过权限设置"
chmod 644 files/etc/config/firewall 2>/dev/null || echo "⚠️ 防火墙配置文件不存在，跳过权限设置"
chmod 644 files/etc/config/dhcp 2>/dev/null || echo "⚠️ DHCP配置文件不存在，跳过权限设置"
echo "✅ 配置文件权限已设置"

# 配置ddns-go服务
echo "正在配置 ddns-go 服务..."
mkdir -p files/etc/config
cat > files/etc/config/ddns-go << EOF
config ddns-go 'config'
	option enabled '1'
	option listen '[::]:9876'
	option ttl '300'
EOF
echo "✅ ddns-go 服务已配置为自动启动"

# 创建 ddns-go 配置目录和uci-defaults目录
echo "正在配置 ddns-go 详细设置..."
mkdir -p files/etc/ddns-go
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
    echo "✅ ddns-go 配置文件已创建并设置权限"
else
    echo "⚠️ 警告: DDNS_301W 环境变量未设置，跳过 ddns-go 详细配置"
fi

# 配置 opkg distfeeds.conf
echo "正在配置 opkg 软件源..."
mkdir -p files/etc/opkg
cat > files/etc/opkg/distfeeds.conf << EOF
src/gz immortalwrt_core https://mirrors.vsean.net/openwrt/releases/24.10-SNAPSHOT/targets/qualcommax/ipq807x/packages
src/gz immortalwrt_base https://mirrors.vsean.net/openwrt/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/base
src/gz immortalwrt_luci https://mirrors.vsean.net/openwrt/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/luci/
src/gz immortalwrt_packages https://mirrors.vsean.net/openwrt/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/packages
src/gz immortalwrt_routing https://mirrors.vsean.net/openwrt/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/routing
src/gz immortalwrt_telephony https://mirrors.vsean.net/openwrt/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/telephony
EOF
chmod 644 files/etc/opkg/distfeeds.conf
echo "✅ opkg 软件源配置已完成"

# 写入自定义IGMP Proxy配置
echo "正在应用自定义IGMP Proxy配置..."
cat > files/etc/config/igmpproxy << EOF
config igmpproxy
	option quickleave 1
	option verbose 0

config phyint
	option network 'iptv'
	option zone 'iptv'
	option direction 'upstream'
	list altnet '121.60.0.0/16'

config phyint
	option network 'lan'
	option zone 'lan'
	option direction 'downstream'
EOF
chmod 644 files/etc/config/igmpproxy
echo "✅ 自定义IGMP Proxy配置已应用"

echo "===== 自定义配置应用完成 ====="
# 输出架构信息以方便识别
echo "📌 当前编译架构: 301W"
