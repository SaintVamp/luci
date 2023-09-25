#
# Copyright (C) 2017-2019
#
# This is free software, licensed under the MIT License.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Support for syncDB
LUCI_DEPENDS:=+python3 +python3-pymongo +python3-pymysql +python3-beautifulsoup4 +python3-requests
PKG_NAME:=luci-app-syncdb

define Package/$(PKG_NAME)/install
#!/bin/sh
chmod +x /etc/init.d/syncdb
exit 0
endef

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
