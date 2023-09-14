# Copyright (C) 2020 Lienol <lawlienol@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-socatui


LUCI_TITLE:=LuCI UI support for Socat
LUCI_DEPENDS:=+socat
LUCI_PKGARCH:=all

define Package/$(PKG_NAME)/conffiles
/etc/config/socatui
endef

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature