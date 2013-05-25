# 
# Copyright (C) 2009 OpenWrt.org
# Copyright (C) 2013 Freetz.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

override CONFIG_AUTOREBUILD=

REAL_STAGING_DIR_HOST:=$(STAGING_DIR_HOST)
STAGING_DIR_HOST:=$(KERNEL_TOOLCHAIN_DIR)
BUILD_DIR_HOST:=$(KERNEL_BUILD_DIR_TOOLCHAIN)

include $(INCLUDE_DIR)/host-build.mk

HOST_STAMP_PREPARED=$(HOST_BUILD_DIR)/.prepared

define FixupLibdir
	if [ -d $(1)/lib64 -a \! -L $(1)/lib64 ]; then \
		mkdir -p $(1)/lib; \
		mv $(1)/lib64/* $(1)/lib/; \
		rm -rf $(1)/lib64; \
	fi
	ln -sf lib $(1)/lib64
endef

include $(INCLUDE_DIR)/toolchain-common.mk

#$(stamp/toolchain-install): $(stamp/toolchain-kernel-install) $(stamp/toolchain-target-install)