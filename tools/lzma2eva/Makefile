# 
# Copyright (C) 2013 Freetz.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=lzma2eva
PKG_VERSION:=0.1

HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	$(CP) ./src/* $(HOST_BUILD_DIR)/
endef

define Host/Configure
endef

define Host/Compile
	$(MAKE) -C $(HOST_BUILD_DIR) 
		CFLAGS="$(HOST_CFLAGS)" \
		LDFLAGS="$(HOST_LDFLAGS) $(HOST_STATIC_LINKING)"
endef

define Host/Install
	$(CP) $(HOST_BUILD_DIR)/lzma2eva $(STAGING_DIR_HOST)/bin/
endef

define Host/Clean
	rm -f $(STAGING_DIR_HOST)/bin/lzma2eva
endef

$(eval $(call HostBuild))
