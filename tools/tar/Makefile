# 
# Copyright (C) 2013 Freetz.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=tar
PKG_VERSION:=1.15.1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://ftp.gnu.org/gnu/tar
PKG_MD5SUM:=57da3c38f8e06589699548a34d5a5d07

HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk

define Host/Install
	strip $(HOST_BUILD_DIR)/tar
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/tar $(STAGING_DIR_HOST)/bin
endef

$(eval $(call HostBuild))
