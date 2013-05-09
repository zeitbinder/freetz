# 
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=squashfs3
PKG_VERSION:=3.4

PKG_SOURCE:=squashfs$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/squashfs
PKG_MD5SUM:=2a4d2995ad5aa6840c95a95ffa6b1da6

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/squashfs$(PKG_VERSION)

HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk

define Host/Compile
	$(MAKE) -C $(HOST_BUILD_DIR)/squashfs-tools \
		CC="$(HOSTCC)" \
		CXX="$(CXX) $(HOST_STATIC_LINKING)" \
		LZMA_DIR=$(STAGING_DIR_HOST)/lib \
		all
endef

define Host/Install
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/squashfs-tools/mksquashfs3 $(STAGING_DIR_HOST)/bin/mksquashfs3
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/squashfs-tools/unsquashfs3 $(STAGING_DIR_HOST)/bin/unsquashfs3
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/squashfs-tools/mksquashfs3-lzma $(STAGING_DIR_HOST)/bin/mksquashfs3-lzma
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/squashfs-tools/unsquashfs3-lzma $(STAGING_DIR_HOST)/bin/unsquashfs3-lzma
endef

define Host/Clean
	rm -f $(STAGING_DIR_HOST)/bin/mksquashfs3
	rm -f $(STAGING_DIR_HOST)/bin/unsquashfs3
	rm -f $(STAGING_DIR_HOST)/bin/mksquashfs3-lzma
	rm -f $(STAGING_DIR_HOST)/bin/unsquashfs3-lzma
endef

$(eval $(call HostBuild))
