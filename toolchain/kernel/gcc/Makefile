#
# Copyright (C) 2002-2003 Erik Andersen <andersen@uclibc.org>
# Copyright (C) 2004 Manuel Novoa III <mjn3@uclibc.org>
# Copyright (C) 2005-2006 Felix Fietkau <nbd@openwrt.org>
# Copyright (C) 2006-2012 OpenWrt.org
# Copyright (C) 2006-2013 Freetz.org
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
GCC_VERSION:=$(call qstrip,$(FREETZ_KERNEL_GCC_VERSION))
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

include $(INCLUDE_DIR)/toolchain-build-kernel.mk

HOST_SOURCE_DIR:=$(HOST_BUILD_DIR)
GCC_BUILD_DIR:=$(HOST_BUILD_DIR)

#HOST_STAMP_PREPARED:=$(HOST_BUILD_DIR)/.prepared
#HOST_STAMP_BUILT:=$(GCC_BUILD_DIR)/.built
#HOST_STAMP_CONFIGURED:=$(GCC_BUILD_DIR)/.configured
HOST_STAMP_INSTALLED:=$(STAGING_DIR_HOST)/stamp/.gcc_kernel_installed

export libgcc_cv_fixed_point=no
export glibcxx_cv_c99_math_tr1=no

GCC_CONFIGURE:= \
	SHELL="$(BASH)" \
	$(HOST_SOURCE_DIR)/configure \
		--prefix=$(KERNEL_TOOLCHAIN_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--enable-languages=c \
		--disable-shared \
		--with-newlib \
		--disable-libssp \
		--with-gnu-ld \
		--with-gnu-as \
		--without-headers \
		--without-threads \
		--disable-nls \
		$(if $(FREETZ_TARGET_ARCH_LE),--with-march=4kc) \
		$(if $(FREETZ_TARGET_ARCH_BE),--with-march=24kc) \
		$(DISABLE_LARGEFILE) \
		$(call qstrip,$(FREETZ_EXTRA_GCC_CONFIG_OPTIONS))

# FIXME: KERNEL_TOOLCHAIN_NO_MPFR
ifndef KERNEL_TOOLCHAIN_NO_MPFR
  GCC_CONFIGURE += \
		--disable-decimal-float \
		--with-gmp=$(TOPDIR)/staging_dir/host \
		--with-mpfr=$(TOPDIR)/staging_dir/host \
		--with-mpc=$(TOPDIR)/staging_dir/host
endif

GCC_MAKE:= \
	export SHELL="$(BASH)"; \
	$(MAKE) 

GCC_EXTRA_MAKE_OPTIONS := MAKEINFO=true

define Host/SetToolchainInfo
	$(SED) -i -e 's,TARGET_CROSS=.*,TARGET_CROSS=$(REAL_GNU_TARGET_NAME)-,' $(KERNEL_TOOLCHAIN_DIR)/info.mk
	$(SED) -i -e 's,GCC_VERSION=.*,GCC_VERSION=$(GCC_VERSION),' $(KERNEL_TOOLCHAIN_DIR)/info.mk
endef

define Host/Prepare
	$(call Host/Prepare/Default)
	ln -snf $(GCC_DIR) $(KERNEL_BUILD_DIR_TOOLCHAIN)/$(PKG_NAME)
	$(CP) $(SCRIPT_DIR)/config.{guess,sub} $(HOST_BUILD_DIR)/
	$(SED) -i -e 's,^MULTILIB_OSDIRNAMES,# MULTILIB_OSDIRNAMES,' $(HOST_BUILD_DIR)/gcc/config/*/t-*
	$(SED) -i -e 's,\(version_string.. = "[0-9\.]*\).*\(";\),\1 (Freetz-2.0)\2,' $(HOST_BUILD_DIR)/gcc/version.c
	$(SED) -i -e 's,\(bug_report_url.. = "\).*\(";\),\1<URL:$(BUGURL)>\2,' $(HOST_BUILD_DIR)/gcc/version.c
	$(SED) -i -e 's,http://gcc.gnu.org/bugs.html,$(BUGURL),' $(HOST_BUILD_DIR)/gcc/configure
	#(cd $(HOST_BUILD_DIR)/libstdc++-v3; autoconf;);
	$(SED) -i -e 's,gcc_no_link=yes,gcc_no_link=no,' $(HOST_BUILD_DIR)/libstdc++-v3/configure
	mkdir -p $(GCC_BUILD_DIR)
endef


define Host/Configure
	(cd $(GCC_BUILD_DIR) && rm -f config.cache; \
		$(GCC_CONFIGURE) \
	);
endef

define Host/Compile
	+$(GCC_MAKE) $(HOST_JOBS) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR) \
		all-gcc
endef

define Host/Install
	$(call Host/SetToolchainInfo)
	$(GCC_MAKE) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR) \
		prefix="$(KERNEL_TOOLCHAIN_DIR)" \
		install-gcc
	$(call GCC_INSTALL_COMMON,$(KERNEL_TOOLCHAIN_DIR)/usr,$(GCC_VERSION),$(REAL_GNU_TARGET_NAME),$(HOST_STRIP))
	$(call REMOVE_DOC_NLS_DIRS,$(KERNEL_TOOLCHAIN_DIR))
endef

define Host/Clean
	rm -rf \
		$(STAGING_DIR_HOST)/stamp/.gcc_kernel_* \
		$(STAGING_DIR_HOST)/stamp/.binutils_* \
		$(GCC_BUILD_DIR) \
		$(KERNEL_BUILD_DIR_TOOLCHAIN)/$(PKG_NAME) \
		$(KERNEL_TOOLCHAIN_DIR)/$(REAL_GNU_TARGET_NAME) \
		$(KERNEL_TOOLCHAIN_DIR)/bin/$(REAL_GNU_TARGET_NAME)-gc* \
		$(KERNEL_TOOLCHAIN_DIR)/bin/$(REAL_GNU_TARGET_NAME)-c*
endef


$(eval $(call HostBuild))
