#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=binutils
PKG_VERSION:=$(call qstrip,$(FREETZ_KERNEL_BINUTILS_VERSION))
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
BINUTILS_BINARIES_BIN := addr2line ar as c++filt elfedit gprof ld nm objcopy objdump ranlib readelf size strings strip

ifeq ($(strip $(FREETZ_TOOLCHAIN_32BIT)),y)
TOOLCHAIN_HOST_CFLAGS+=-m32
endif

include $(INCLUDE_DIR)/toolchain-build-kernel.mk

HOST_STAMP_INSTALLED:=$(STAGING_DIR_HOST)/stamp/.binutils_kernel_installed

BINUTILS_CONFIGURE:= \
	./configure \
		--prefix=$(KERNEL_TOOLCHAIN_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--disable-multilib \
		--disable-werror \
		--disable-nls \
		--disable-libssp \
		--without-headers \
		$(SOFT_FLOAT_CONFIG_OPTION) \

BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS := MAKEINFO=true

define Host/Prepare
	$(call Host/Prepare/Default)
	ln -snf $(PKG_NAME)-$(PKG_VERSION) $(KERNEL_BUILD_DIR_TOOLCHAIN)/$(PKG_NAME)
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
		$(BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS) \
		configure-host
	+$(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR) \
		$(BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS) \
		all
endef

define Host/Install
	mkdir -p $(KERNEL_TOOLCHAIN_DIR)
	$(MAKE) -C $(HOST_BUILD_DIR) \
		$(BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS) \
		prefix=$(KERNEL_TOOLCHAIN_DIR) \
		install
	$(RM) $(KERNEL_TOOLCHAIN_DIR)/$(REAL_GNU_KERNEL_NAME)/bin/ld.bfd $(KERNEL_TOOLCHAIN_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-ld.bfd
	$(call STRIP_TOOLCHAIN_BINARIES,$(KERNEL_TOOLCHAIN_DIR),$(BINUTILS_BINARIES_BIN),$(REAL_GNU_KERNEL_NAME),$(HOST_STRIP))
	$(call REMOVE_DOC_NLS_DIRS,$(KERNEL_TOOLCHAIN_STAGING_DIR))
endef

define Host/Clean
	rm -rf \
		$(HOST_BUILD_DIR) \
		$(KERNEL_BUILD_DIR_TOOLCHAIN)/$(PKG_NAME)
endef

$(eval $(call HostBuild))
