# 
# Copyright (C) 2013 Freetz.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=fakeroot
PKG_VERSION:=1.18.4

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).orig.tar.bz2
PKG_SOURCE_URL:=http://ftp.debian.org/debian/pool/main/f/fakeroot
PKG_MD5SUM:=706171d8d520b1ca1576ac73f2ceb4f3

HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk

MAINARCH_DIR:=$(HOST_BUILD_DIR)/build/arch
BIARCH_DIR:=$(HOST_BUILD_DIR)/build/biarch

MAINARCH_LD_PRELOAD_PATH:=$(STAGING_DIR_HOST)/lib
BIARCH_LD_PRELOAD_PATH:=$(STAGING_DIR_HOST)/lib32

TARGET_SCRIPT:=$(STAGING_DIR_HOST)/bin/fakeroot
TARGET_BIARCH_LIB:=$(BIARCH_LD_PRELOAD_PATH)/libfakeroot-0.so

# BIARCH means 32-bit libraries on 64-bit hosts
# We need 32-bit fakeroot support if we use the 32-bit mips*-linux-strip during fwmod on a 64-bit host
# This doesn't affect sstrip because we build it on the host.
# The correct condition here would be:
# (using 32-bit toolchain) AND (any of the STRIP-options is selected) AND (host i 64-bit)
BIARCH_BUILD_SYSTEM:=$(and \
	$(or $(FREETZ_DOWNLOAD_TOOLCHAIN),$(FREETZ_TOOLCHAIN_32BIT)), \
	$(findstring $(shell uname -m),x86_64))

define Host/Configure
	(mkdir -p $(MAINARCH_DIR); cd $(MAINARCH_DIR); $(RM) config.cache; \
		CFLAGS="-O3 -Wall" \
		CC="$(HOSTCC)" \
		../../$(HOST_CONFIGURE_CMD) \
		--prefix=$(STAGING_DIR_HOST) \
		--enable-shared \
		$(DISABLE_NLS) \
	)
	(mkdir -p $(BIARCH_DIR); cd $(BIARCH_DIR); $(RM) config.cache; \
		CFLAGS="-m32 -O3 -Wall" \
		CC="$(HOSTCC)" \
		../../$(HOST_CONFIGURE_CMD) \
		--prefix=$(STAGING_DIR_HOST) \
		--enable-shared \
		$(DISABLE_NLS) \
	);
endef

define Host/Compile
	$(MAKE) -C $(MAINARCH_DIR) all
	$(MAKE) -C $(BIARCH_DIR) libdir="$(BIARCH_LD_PRELOAD_PATH)" install-libLTLIBRARIES
endef

define Host/Install
	$(MAKE) -C $(MAINARCH_DIR) install
	$(SED) -i -e 's,^PATHS=.*,PATHS=$(MAINARCH_LD_PRELOAD_PATH)$(if $(BIARCH_BUILD_SYSTEM),:$(BIARCH_LD_PRELOAD_PATH)),g' \
		$(STAGING_DIR_HOST)/bin/fakeroot
endef

# TODO
define Host/Clean
endef

$(eval $(call HostBuild))
