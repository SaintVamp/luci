# Copyright (C) 2023 sv <sv@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-socat

LUCI_TITLE:=LuCI support for Socat
LUCI_DEPENDS:=+socat +luci-compat

define Package/$(PKG_NAME)/conffiles
/etc/config/socatui
endef

define Package/$(PKG_NAME)/install
#!/bin/sh
chmod +x /etc/inin.t/socatui
exit 0
endef

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
