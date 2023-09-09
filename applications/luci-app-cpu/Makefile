#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=CPU Info
LUCI_DEPENDS:=+ethtool-full +lm-sensors

define Package/luci-app-socat/postinst
#!/bin/sh
chmod +x /usr/libexec/rpcd/luci.cpu
./rpcd restart
exit 0
endef

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
