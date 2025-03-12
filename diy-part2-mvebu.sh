#!/bin/bash

# 更精确地替换 PPPoE 的用户名和密码
sed -i "/proto='pppoe'/,/password=/ s/username='username'/username='$PPPOE_USERNAME1'/g" package/base-files/files/bin/config_generate
sed -i "/proto='pppoe'/,/password=/ s/password='password'/password='$PPPOE_PASSWORD1'/g" package/base-files/files/bin/config_generate

# 更加精确的替换，包含完整的函数名和上下文
sed -i '/ucidef_set_interface "wan" device/,+5 s/protocol "${2:-dhcp}"/protocol "${2:-pppoe}"/g' package/base-files/files/lib/functions/uci-defaults.sh

#修改默认时区
sed -i "s/timezone='GMT0'/timezone='Asia\/Shanghai'/" package/base-files/files/bin/config_generate

#修改默认shell为bash
sed -i 's|root:x:0:0:root:/root:/bin/ash|root:x:0:0:root:/root:/bin/bash|' package/base-files/files/etc/passwd
        
# 如果需要，还可以添加其他修改
