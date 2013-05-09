# 
# Copyright (C) 2013 freetz.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=xdelta
PKG_VERSION:=30q

PKG_SOURCE:=$(PKG-NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://PKG.googlecode.com/files
PKG_MD5SUM:=633717fb1b3fa77374dc1f3549cc7b59

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)($(PKG_NAME)$(PKG_VERSION)

HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk

define Host/Compile
	$(MAKE) -C $(HOST_BUILD_DIR) xdelta3
endef

define Host/Install
        $(INSTALL_BIN) $(HOST_BUILD_DIR)/xdelta3 $(STAGING_DIR_HOST)/bin/
endef

define Host/Clean
        rm -f $(STAGING_DIR_HOST)/bin/xdelta3
endef

$(eval $(call HostBuild))
