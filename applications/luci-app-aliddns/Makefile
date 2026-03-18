#
# Copyright (C) 2017-2019
#
# This is free software, licensed under the MIT License.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Support for AliDdns
LUCI_DEPENDS:=+bash +curl +wget-ssl +openssl-util
PKG_NAME:=luci-app-aliddns

define Package/$(PKG_NAME)/conffiles
/etc/config/aliddns
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
    /etc/init.d/aliddns disable
    /etc/init.d/aliddns stop
fi
exit 0
endef

define Package/$(PKG_NAME)/postrm
#!/bin/sh
if [ -z "${IPKG_INSTROOT}" ]; then
    rm -rf /usr/ddns
    rm -f /usr/bin/aliddns
fi
exit 0
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DATA) ./root/etc/init.d/aliddns $(1)/etc/init.d/aliddns
	$(INSTALL_DIR) $(1)/usr/ddns
	$(INSTALL_DATA) ./root/usr/ddns/*.sh $(1)/usr/ddns/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/aliddns $(1)/etc/config/aliddns
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
    chmod +x /etc/init.d/aliddns
    chmod +x /usr/ddns/*.sh
    
    # 如果配置文件不存在，创建默认配置
    if [ ! -f /etc/config/aliddns ]; then
        cat > /etc/config/aliddns <<'EOF'
config global 'settings'
    option AccessKeyId 'your_access_key_id'
    option AccessKeySecret 'your_access_key_secret'
    option TTL '600'
    option DnsServer 'dns23.hichina.com'
    option UrlName ':45678/sv/mail'

config domain 'domain1'
    option Subdomain '404'
    option Domain 'svsoft.fun'
    option Iptype 'A'
EOF
    fi
fi
exit 0
endef

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
