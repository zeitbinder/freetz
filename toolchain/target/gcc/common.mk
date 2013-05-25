#
# Copyright (C) 2002-2003 Erik Andersen <andersen@uclibc.org>
# Copyright (C) 2004 Manuel Novoa III <mjn3@uclibc.org>
# Copyright (C) 2005-2006 Felix Fietkau <nbd@openwrt.org>
# Copyright (C) 2006-2012 OpenWrt.org
# Copyright (C) 2013 Freetz.org
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

include $(TOPDIR)/rules.mk

PKG_NAME:=gcc
GCC_VERSION:=$(call qstrip,$(FREETZ_TARGET_GCC_VERSION))
PKG_VERSION:=$(firstword $(subst +, ,$(GCC_VERSION)))
GCC_DIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_SOURCE_URL:=@GNU/gcc/gcc-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2

ifeq ($(PKG_VERSION),4.6.4)
  PKG_MD5SUM:=b407a3d1480c11667f293bfb1f17d1a4
endif
ifeq ($(PKG_VERSION),4.7.3)
  PKG_MD5SUM:=86f428a30379bdee0224e353ee2f999e
endif
ifeq ($(PKG_VERSION),4.8.0)
  PKG_MD5SUM:=e6040024eb9e761c3bea348d1fa5abb0
endif

PATCH_DIR=../patches/$(GCC_VERSION)

BUGURL=http://freetz.org/

HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/toolchain-build.mk

HOST_SOURCE_DIR:=$(HOST_BUILD_DIR)
ifeq ($(GCC_VARIANT),minimal)
  GCC_BUILD_DIR:=$(HOST_BUILD_DIR)-$(GCC_VARIANT)
else
  HOST_BUILD_DIR:=$(HOST_BUILD_DIR)-$(GCC_VARIANT)
  GCC_BUILD_DIR:=$(HOST_BUILD_DIR)
endif

HOST_STAMP_PREPARED:=$(HOST_BUILD_DIR)/.prepared
HOST_STAMP_BUILT:=$(GCC_BUILD_DIR)/.built
HOST_STAMP_CONFIGURED:=$(GCC_BUILD_DIR)/.configured
HOST_STAMP_INSTALLED:=$(STAGING_DIR_HOST)/stamp/.gcc_target_$(GCC_VARIANT)_installed

TARGET_LANGUAGES:="c,c++"

export libgcc_cv_fixed_point=no
export glibcxx_cv_c99_math_tr1=no

GCC_BUILD_TARGET_LIBGCC:=y

TOOLCHAIN_TARGET_CFLAGS:=$(TARGET_CFLAGS) -msoft-float

GCC_CONFIGURE:= \
	SHELL="$(BASH)" \
	CFLAGS="$(HOST_CFLAGS)" \
	CFLAGS_FOR_TARGET="$(TOOLCHAIN_TARGET_CFLAGS)" \
	CXXFLAGS_FOR_TARGET="$(TOOLCHAIN_TARGET_CFLAGS)" \
	$(HOST_SOURCE_DIR)/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--with-gnu-ld \
		--with-host-libstdcxx=-lstdc++ \
		--disable-libgomp \
		--disable-libmudflap \
		--disable-multilib \
		$(if $(FREETZ_AVM_UCLIBC_NPTL_ENABLED),--enable-tls,--disable-tls) \
		--disable-fixed-point \
		--disable-nls \
		$(if $(FREETZ_TARGET_ARCH_LE),--with-march=4kc) \
		$(if $(FREETZ_TARGET_ARCH_BE),--with-march=24kc) \
		$(DISABLE_LARGEFILE) \
		--with-float=soft --enable-cxx-flags=-msoft-float \
		$(call qstrip,$(FREETZ_EXTRA_GCC_CONFIG_OPTIONS))

# Dont' use --enable-target-optspace, it overwrites the cflags
# http://gcc.gnu.org/bugzilla/show_bug.cgi?id=2222

ifneq ($(strip $(FREETZ_TARGET_TOOLCHAIN_AVM_COMPATIBLE)),y)
  # enable non-PIC for mips* targets
  GCC_CONFIGURE += --with-mips-plt
endif

ifndef TARGET_TOOLCHAIN_NO_MPFR
  GCC_CONFIGURE += \
		--disable-decimal-float \
		--with-gmp=$(TOPDIR)/staging_dir/host \
		--with-mpfr=$(TOPDIR)/staging_dir/host \
		--with-mpc=$(TOPDIR)/staging_dir/host
endif

ifneq ($(FREETZ_SSP_SUPPORT),)
  GCC_CONFIGURE+= \
	--enable-libssp
else
  GCC_CONFIGURE+= \
	--disable-libssp
endif

ifeq ($(LIBC),uClibc)
  GCC_CONFIGURE+= \
	--disable-__cxa_atexit
else
  GCC_CONFIGURE+= \
	--enable-__cxa_atexit
endif

GCC_MAKE:= \
	export SHELL="$(BASH)"; \
	$(MAKE) 

GCC_EXTRA_MAKE_OPTIONS := MAKEINFO=true

define Host/Prepare
	mkdir -p $(GCC_BUILD_DIR)
# FIXME: Do we still need this?
#	for f in $$$$(find $(HOST_SOURCE_DIR) \( -name "configure" -o -name "config.rpath" \)); do \
#		$(call PKG_PREVENT_RPATH_HARDCODING1,$$f) done
endef

define Host/Configure
	(cd $(GCC_BUILD_DIR) && rm -f config.cache; \
		$(GCC_CONFIGURE) \
	);
endef

define Host/Clean
	rm -rf \
		$(STAGING_DIR_HOST)/stamp/.gcc_target_* \
		$(STAGING_DIR_HOST)/stamp/.binutils_target_* \
		$(GCC_BUILD_DIR) \
		$(TARGET_BUILD_DIR_TOOLCHAIN)/$(PKG_NAME) \
		$(TARGET_TOOLCHAIN_DIR)/$(REAL_GNU_TARGET_NAME) \
		$(TARGET_TOOLCHAIN_DIR)/bin/$(REAL_GNU_TARGET_NAME)-gc* \
		$(TARGET_TOOLCHAIN_DIR)/bin/$(REAL_GNU_TARGET_NAME)-c*
endef
