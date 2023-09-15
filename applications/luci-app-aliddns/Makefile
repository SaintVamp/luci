#
# Copyright (C) 2017-2019
#
# This is free software, licensed under the MIT License.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Support for AliDdns
LUCI_DEPENDS:=+bash +curl +wget-ssl
PKG_NAME:=luci-app-aliddns

define Package/$(PKG_NAME)/postinst
#!/bin/sh
chmod +x /etc/init.d/aliddns
exit 0
endef

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
