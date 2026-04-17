#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt for Amlogic s9xxx tv box
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/coolsnowwolf/lede / Branch: master
#========================================================================================================================

# ------------------------------- Main source started -------------------------------
#
# Modify default theme（FROM uci-theme-bootstrap CHANGE TO luci-theme-material）
# sed -i 's/luci-theme-bootstrap/luci-theme-material/g' ./feeds/luci/collections/luci/Makefile

# Add autocore support for armvirt
sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_armvirt/g' package/lean/autocore/Makefile

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/lean/default-settings/files/zzz-default-settings
echo "DISTRIB_SOURCECODE='lede'" >>package/base-files/files/etc/openwrt_release

# Modify default IP（FROM 192.168.1.1 CHANGE TO 192.168.31.4）
sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# Replace the default software source
# sed -i 's#openwrt.proxy.ustclug.org#mirrors.bfsu.edu.cn\\/openwrt#' package/lean/default-settings/files/zzz-default-settings
#
# 开启无线功能
#cp -f $GITHUB_WORKSPACE/config/lede-master/opwifi package/base-files/files/etc/init.d/opwifi
#chmod 755 package/base-files/files/etc/init.d/opwifi
#sed -i "s/wireless.radio\${devidx}.disabled=1/wireless.radio\${devidx}.disabled=0/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh
#
# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------
#
# Add luci-app-amlogic
rm -rf package/luci-app-amlogic
git clone https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic
#
# Add linkease-istore
git clone https://github.com/linkease/istore.git package/istore
# Add nas-packages-luci
git clone https://github.com/linkease/nas-packages.git package/nas
git clone https://github.com/linkease/nas-packages-luci.git package/nas_luci
#
# Apply patch
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Other ends -------------------------------


# 集成wifi
cp -a $GITHUB_WORKSPACE/config/immortalwrt-master/packages/* package/firmware/
cp -f $GITHUB_WORKSPACE/config/immortalwrt-master/opwifi package/base-files/files/etc/init.d/opwifi
chmod 755 package/base-files/files/etc/init.d/opwifi
sed -i "s/wireless.radio\${devidx}.disabled=1/wireless.radio\${devidx}.disabled=0/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh
echo "
CONFIG_PACKAGE_brcmfmac-firmware-fine3399=y
" >> .config

# add luci-app-fancontrol
#echo "src-git fancontrol https://github.com/DHDAXCW/luci-app-fancontrol.git" >> feeds.conf.default
git clone https://github.com/DHDAXCW/luci-app-fancontrol.git package/luci-app-fancontrol
#./scripts/feeds update fancontrol && ./scripts/feeds install -a -f -p fancontrol
echo "
CONFIG_PACKAGE_luci-app-fancontrol=y
" >> .config
#sed -i "s/hwmon9/hwmon2/g" package/luci-app-fancontrol/luci-app-fancontrol/htdocs/luci-static/resources/view/fancontrol.js
sed -i "s/hwmon9/hwmon2/g" package/luci-app-fancontrol/fancontrol/files/fancontrol.config

# add qmodem
echo 'src-git qmodem https://github.com/FUjr/QModem.git;main' >> feeds.conf.default
./scripts/feeds update qmodem
./scripts/feeds install -a -f -p qmodem
# git clone -b v3.0.0 --depth=1 https://github.com/FUjr/QModem.git package/qmodem
#sed -i "s/CONFIG_PACKAGE_sms-tool/#CONFIG_PACKAGE_sms-tool/g" .config  
#sed -i "s/CONFIG_PACKAGE_luci-app-modem/#CONFIG_PACKAGE_luci-app-modem/g" .config  
#sed -i "s/CONFIG_PACKAGE_luci-app-sms-tool/#CONFIG_PACKAGE_luci-app-sms-tool/g" .config
echo "
CONFIG_PACKAGE_luci-i18n-qmodem-zh-cn=y
# CONFIG_PACKAGE_luci-i18n-qmodem-hc-zh-cn=y
# CONFIG_PACKAGE_luci-i18n-qmodem-mwan-zh-cn=y
# CONFIG_PACKAGE_luci-i18n-qmodem-ru is not set
CONFIG_PACKAGE_luci-i18n-qmodem-sms-zh-cn=y
CONFIG_PACKAGE_luci-app-qmodem=y
CONFIG_PACKAGE_luci-app-modem=n
CONFIG_PACKAGE_luci-app-qmodem_INCLUDE_vendor-qmi-wwan=y
# CONFIG_PACKAGE_luci-app-qmodem_INCLUDE_generic-qmi-wwan is not set
CONFIG_PACKAGE_luci-app-qmodem_USE_TOM_CUSTOMIZED_QUECTEL_CM=y
# CONFIG_PACKAGE_luci-app-qmodem_USING_QWRT_QUECTEL_CM_5G is not set
# CONFIG_PACKAGE_luci-app-qmodem_USING_NORMAL_QUECTEL_CM is not set
# CONFIG_PACKAGE_luci-app-qmodem_INCLUDE_ADD_PCI_SUPPORT=y
# CONFIG_PACKAGE_luci-app-qmodem_INCLUDE_ADD_QFIREHOSE_SUPPORT is not set
#CONFIG_PACKAGE_luci-app-qmodem-hc=y
#CONFIG_PACKAGE_luci-app-qmodem-mwan=y
CONFIG_PACKAGE_luci-app-qmodem-sms=y
#CONFIG_PACKAGE_luci-app-qmodem-ttl=y
CONFIG_PACKAGE_qmodem=y
CONFIG_PACKAGE_quectel-CM-5G=y
CONFIG_PACKAGE_quectel-CM-5G-M=y
" >> .config