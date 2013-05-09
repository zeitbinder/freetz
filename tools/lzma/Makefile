# 
# Copyright (C) 2006 OpenWrt.org
# Copyright (C) 2013 Freetz.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=lzma
PKG_VERSION:=4.43

PKG_SOURCE:=lzma-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/sevenzip
PKG_MD5SUM:=c4e1b467184c7cffd4371c74df2baf0f

HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk

LIB_DIR=$(HOST_BUILD_DIR)/C/7zip/Compress/LZMA_Lib
ALONE_DIR=$(HOST_BUILD_DIR)/C/7zip/Compress/LZMA_Alone

define Host/Compile
	$(MAKE) -C $(LIB_DIR)
	$(MAKE) -f makefile.gcc -C $(ALONE_DIR)
endef

define Host/Install
	$(INSTALL_BIN) $(ALONE_DIR)/lzma $(STAGING_DIR_HOST)/bin
	$(INSTALL_DATA) $(LIB_DIR)/liblzma.a $(STAGING_DIR_HOST)/lib/liblzma.a
endef

define Host/Clean
	rm -f $(STAGING_DIR_HOST)/bin/lzma
	rm -f $(STAGING_DIR_HOST)/lib/liblzma.a
endef

$(eval $(call HostBuild))
