# 
# Copyright (C) 2007-2009 OpenWrt.org
# Copyright (C) 2007-2013 Freetz.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Main makefile for the kernel toolchain
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

curdir:=toolchain/kernel

# subdirectories to descend into
$(curdir)/builddirs := binutils gcc
$(curdir)/builddirs-compile:=$($(curdir)/builddirs-prepare)
$(curdir)/builddirs-install:=$($(curdir)/builddirs-compile)

# builddir dependencies
$(curdir)/gcc/compile:=$(curdir)/binutils/install

ifndef DUMP_TARGET_DB
ifneq ($(ARCH),)
  $(KERNEL_TOOLCHAIN_DIR)/info.mk: .config
	for dir in $(KERNEL_TOOLCHAIN_DIR); do ( \
		$(if $(QUIET),,set -x;) \
		mkdir -p "$$dir"; \
		cd "$$dir"; \
		ln -sf lib lib64; \
		mkdir -p stamp lib usr/include usr/lib ; \
	); done
	@grep GCC_VERSION $@ >/dev/null 2>&1 || $(INSTALL_DATA) $(TOPDIR)/toolchain/info.mk $@
	@touch $@
endif
endif

# prerequisites for the individual targets
$(curdir)/ := .config prereq
$(curdir)//prepare = $(STAGING_DIR)/.prepared $(KERNEL_TOOLCHAIN_DIR)/info.mk
$(curdir)//compile = $(1)/prepare
$(curdir)//install = $(1)/compile

ifndef DUMP_TARGET_DB
$(KERNEL_TOOLCHAIN_DIR)/stamp/.gcc-kernel_installed:
endif

$(eval $(call stampfile,$(curdir),toolchain,install,$(KERNEL_TOOLCHAIN_DIR)/stamp/.gcc-kernel_installed,,$(KERNEL_TOOLCHAIN_DIR)))
$(eval $(call subdir,$(curdir)))
