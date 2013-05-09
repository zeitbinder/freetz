# 
# Copyright (C) 2013 Freetz.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=tichksum
PKG_VERSION:=0.2

include $(INCLUDE_DIR)/host-build.mk

HOST_BUILD_PARALLEL:=1

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	$(CP) ./src/* $(HOST_BUILD_DIR)/
endef

define Host/Configure
endef

define Host/Install
	$(CP) $(HOST_BUILD_DIR)/tichksum $(STAGING_DIR_HOST)/bin/tichksum
endef

define Host/Clean
	rm -f $(STAGING_DIR_HOST)/bin/tichksum
endef

$(eval $(call HostBuild))
