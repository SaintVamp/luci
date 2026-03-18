#
# Copyright (C) 2017-2019
#
# This is free software, licensed under the MIT License.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Support for AliDdns
LUCI_DEPENDS:=+bash +curl +wget-ssl +openssl-util
PKG_NAME:=luci-app-aliddns

define Package/$(PKG_NAME)/install
	chmod 755 $(1)/etc/init.d/aliddns
	chmod 755 $(1)/usr/bin/ethinfo
	chmod 755 $(1)/usr/ddns/run.sh
	chmod 755 $(1)/usr/ddns/ddns.sh
	chmod 755 $(1)/usr/ddns/update.sh
endef

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
