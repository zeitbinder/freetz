# 
# Copyright (C) 2006 OpenWrt.org
# Copyright (C) 2013 Freetz.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=kconfig
PKG_VERSION:=v3.8

# TODO
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
#PKG_SOURCE_URL:=git://repo.or.cz/linux-2.6.git
#PKG_SOURCE_PROTO:=git
#PKG_SOURCE_SUBDIR:=$(PKG_NAME)
#PKG_SOURCE_VERSION:=d333fc232d7e5ae3370080d5d6f7d88ea9c6b3a1
PKG_SOURCE_URL:=http://freetz.magenbrot.net
PKG_MD5SUM:=8b5e1da6c14065dc074caef9e514818b

HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk

define Host/Configure
endef

# FIXME
define Host/Compile
#	$(MAKE) -C $(HOST_BUILD_DIR)
endef

define Host/Install
endef


define Host/Clean
# FIXME
#	rm -r $(STAGING_DIR_HOST)/conf
#	rm -r $(STAGING_DIR_HOST)/mconf
endef

$(eval $(call HostBuild))