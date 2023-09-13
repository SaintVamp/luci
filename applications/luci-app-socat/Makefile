# Copyright (C) 2023 沉默の金 <cmzj11@gmail.com>
# Copyright (C) 2020 Lienol <lawlienol@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-socat

PKG_MAINTAINER:=chenmozhijin <cmzj11@gmail.com>

LUCI_TITLE:=LuCI support for Socat
LUCI_DEPENDS:=+socat

define Package/$(PKG_NAME)/conffiles
/etc/config/socatui
endef

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
