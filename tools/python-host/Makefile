# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=python
PKG_VERSION:=2.7.4

PKG_SOURCE:=Python-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.python.org/ftp/python/$(PKG_VERSION)
PKG_MD5SUM:=62704ea0f125923208d84ff0568f7d50

HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk

define Host/Compile
	$(MAKE) -C $(HOST_BUILD_DIR) \
		all Parser/pgen
endef

define Host/Install
	$(MAKE) -C $(HOST_BUILD_DIR) DESTDIR="$(STAGING_DIR_HOST)
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/Parser/pgen $(STAGING_DIR_HOST)/usr/bin/
endef

define Host/Clean
        rm -f $(STAGING_DIR_HOST)/usr/bin/python2.7
        rm -f $(STAGING_DIR_HOST)/usr/bin/pgen
# TODO
endef

$(eval $(call HostBuild))
