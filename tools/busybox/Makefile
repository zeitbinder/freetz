# 
# Copyright (C) 2013 Freetz.org

#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=busybox
PKG_VERSION:=1.21.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.busybox.net/downloads
PKG_MD5SUM:=d613f2e4b580305c1de8691f7b84285e

HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk

define Host/Configure
	cp ./busybox.config $(HOST_BUILD_DIR)/.config
	$(MAKE) -C $(HOST_BUILD_DIR) oldconfig
endef

define Host/Install
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/busybox $(STAGING_DIR_HOST)/bin
	find $(STAGING_DIR_HOST)/bin -lname busybox -delete
	for i in $$$$($(STAGING_DIR_HOST)/bin/busybox --list); do \
		$(LN) busybox $(STAGING_DIR_HOST)/bin/$$$$i; \
	done
endef

define Host/Clean
	find $(STAGING_DIR_HOST/bin) \( -lname busybox -o -name busybox \) -delete
endef

$(eval $(call HostBuild))
