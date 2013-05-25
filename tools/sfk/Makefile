# 
# Copyright (C) 2013 Freetz.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=sfk
PKG_VERSION:=1.6.5
PKG_VERSION_SHORT:=165

PKG_SOURCE:=sfk$(PKG_VERSION_SHORT).zip
PKG_SOURCE_URL:=@SF/swissfileknife/1-swissfileknife/$(PKG_VERSION)
PKG_MD5SUM:=8694d73033dde496c023258f08daa918

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_NAME)$(PKG_VERSION_SHORT)

HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk

ifeq ($(shell uname), Darwin)
HOST_CFLAGS += -DMAC_OS_X
endif 

define Host/Configure
endef

define Host/Compile
	(cd $(HOST_BUILD_DIR); \
		$(CXX) $(HOST_CFLAGS) sfk.cpp sfknet.cpp patch.cpp inst.cpp -o $(HOST_BUILD_DIR)/sfk; \
	)
endef

define Host/Install
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/sfk $(STAGING_DIR_HOST)/bin/
endef

define Host/Clean
	rm -f $(STAGING_DIR_HOST)/bin/sfk
endef

$(eval $(call HostBuild))