#
# Copyright (C) 2006-2012 OpenWrt.org
# Copyright (C) 2006-2013 Freetz.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=binutils
PKG_VERSION:=$(call qstrip,$(FREETZ_TARGET_BINUTILS_VERSION))
BIN_VERSION:=$(PKG_VERSION)

PKG_SOURCE_URL:=@GNU/binutils/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2

ifeq ($(PKG_VERSION),2.22)
  PKG_MD5SUM:=ee0f10756c84979622b992a4a61ea3f5
endif
ifeq ($(PKG_VERSION),2.23.2)
  PKG_MD5SUM:=4f8fa651e35ef262edc01d60fb45702e
endif

HOST_BUILD_PARALLEL:=1

PATCH_DIR:=./patches/$(PKG_VERSION)

REAL_STAGING_DIR_HOST:=$(STAGING_DIR_HOST)

include $(INCLUDE_DIR)/toolchain-build.mk

BINUTILS_CONFIGURE:= \
	./configure \
		--prefix=$(TARGET_TOOLCHAIN_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--with-sysroot=$(TARGET_TOOLCHAIN_DIR) \
		--disable-multilib \
		--disable-werror \
		--disable-nls \
		--disable-libssp \
		$(SOFT_FLOAT_CONFIG_OPTION) \
		$(call qstrip,$(FREETZ_EXTRA_BINUTILS_CONFIG_OPTIONS)) 


define Host/Prepare
	$(call Host/Prepare/Default)
	ln -snf $(PKG_NAME)-$(PKG_VERSION) $(TARGET_BUILD_DIR_TOOLCHAIN)/$(PKG_NAME)
	$(CP) $(SCRIPT_DIR)/config.{guess,sub} $(HOST_BUILD_DIR)/
	# fool zlib test in all configure scripts so it doesn't find zlib and thus no zlib gets linked in
	sed -i -r -e 's,(zlibVersion)([ \t]*[(][)]),\1WeDontWantZlib\2,g' $$$$(find $(HOST_BUILD_DIR) -name "configure" -type f)
endef

define Host/Configure
	(cd $(HOST_BUILD_DIR); \
		$(BINUTILS_CONFIGURE) \
	);
endef

define Host/Compile
	+$(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR) \
		$(BINUTILS_EXTRA_MAKE_OPTIONS) \
		all
endef

define Host/Install
	mkdir -p $(TARGET_TOOLCHAIN_DIR)/initial
	$(MAKE) -C $(HOST_BUILD_DIR) \
		prefix=$(TARGET_TOOLCHAIN_DIR)/initial \
		install
	$(call FixupLibdir,$(TARGET_TOOLCHAIN_DIR)/initial)
	$(CP) $(TARGET_TOOLCHAIN_DIR)/initial/. $(TARGET_TOOLCHAIN_DIR)/
	$(CP) $(TARGET_TOOLCHAIN_DIR)/bin/$(REAL_GNU_TARGET_NAME)-readelf $(REAL_STAGING_DIR_HOST)/bin/readelf
endef

define Host/Clean
	rm -rf \
		$(HOST_BUILD_DIR) \
		$(TARGET_BUILD_DIR_TOOLCHAIN)/$(PKG_NAME)
endef

$(eval $(call HostBuild))
