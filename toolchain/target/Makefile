# 
# Copyright (C) 2007-2009 OpenWrt.org
# Copyright (C) 2007-2013 Freetz.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Main makefile for the toolchain
#
# Steps:
# 1) toolchain/binutils/install
#    build & install binutils
# 2) toolchain/gcc/prepare
#    build & install a minimal gcc, needed for steps 3 & 4
# 3) toolchain/kernel-headers/install
#    install kernel headers, needed for step 4
# 4) toolchain/libc/prepare
#    build & install libc headers & support files, needed for step 5
# 5) toolchain/gcc/compile
#    build & install an initial gcc, needed for step 6
# 6) toolchain/libc/compile
#    build & install the final libc
# 7) toolchain/gcc/install
#    build & install the final gcc
# 8) toolchain/libc/install
#    build & install libc utilities
#

curdir:=toolchain/target

# subdirectories to descend into
$(curdir)/builddirs := kernel-headers binutils gcc/minimal gcc/initial gcc/final uClibc/headers uClibc uClibc/utils
$(curdir)/builddirs-compile:=$($(curdir)/builddirs-prepare)
$(curdir)/builddirs-install:=$($(curdir)/builddirs-compile)

# builddir dependencies
$(curdir)/gcc/minimal/compile:=$(curdir)/binutils/install
$(curdir)/kernel-headers/install:=$(curdir)/gcc/minimal/install
$(curdir)/gcc/initial/prepare:=$(curdir)/gcc/minimal/prepare
$(curdir)/gcc/final/prepare:=$(curdir)/gcc/initial/prepare

$(curdir)/uClibc/headers/compile:=$(curdir)/kernel-headers/install
$(curdir)/gcc/initial/compile:=$(curdir)/uClibc/headers/install
$(curdir)/uClibc/compile:=$(curdir)/gcc/initial/install
$(curdir)/gcc/final/compile:=$(curdir)/uClibc/install
$(curdir)/uClibc/utils/compile:=$(curdir)/gcc/final/install
$(curdir)/uClibc/prepare:=$(curdir)/uClibc/headers/prepare
$(curdir)/uClibc/utils/prepare:=$(curdir)/uClibc/headers/prepare

ifndef DUMP_TARGET_DB
ifneq ($(ARCH),)
  $(TARGET_TOOLCHAIN_DIR)/info.mk: .config
	@for dir in $(TARGET_TOOLCHAIN_DIR); do ( \
		$(if $(QUIET),,set -x;) \
		mkdir -p "$$dir"; \
		cd "$$dir"; \
		ln -sf . usr; \
		mkdir -p stamp lib include; \
	); done
	@grep GCC_VERSION $@ >/dev/null 2>&1 || $(INSTALL_DATA) $(TOPDIR)/toolchain/info.mk $@
	@touch $@
endif
endif

# prerequisites for the individual targets
$(curdir)/ := .config prereq
$(curdir)//prepare = $(STAGING_DIR)/.prepared $(TARGET_TOOLCHAIN_DIR)/info.mk
$(curdir)//compile = $(1)/prepare
$(curdir)//install = $(1)/compile

ifndef DUMP_TARGET_DB
$(TARGET_TOOLCHAIN_DIR)/stamp/.gcc-initial_installed:
endif

$(eval $(call stampfile,$(curdir),toolchain,install,$(TARGET_TOOLCHAIN_DIR)/stamp/.gcc_target_initial_installed,,$(TARGET_TOOLCHAIN_DIR)))
$(eval $(call subdir,$(curdir)))
