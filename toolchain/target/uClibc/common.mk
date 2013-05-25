#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/target.mk

PKG_NAME:=uClibc
PKG_VERSION:=$(call qstrip,$(FREETZ_TARGET_UCLIBC))
PKG_SOURCE_URL:=http://www.uclibc.org/downloads$(if $(or $(FREETZ_TARGET_UCLIBC_0_9_28),$(FREETZ_TARGET_UCLIBC_0_9_29)),/old-releases)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
LIBC_SO_VERSION:=$(PKG_VERSION)
PATCH_DIR:=$(PATH_PREFIX)/patches-$(PKG_VERSION)
CONFIG_DIR:=$(PATH_PREFIX)/config


PKG_MD5SUM_0.9.28   = 1ada58d919a82561061e4741fb6abd29
PKG_MD5SUM_0.9.29   = 61dc55f43b17a38a074f347e74095b20
PKG_MD5SUM_0.9.32.1 = ade6e441242be5cdd735fec97954a54a
PKG_MD5SUM_0.9.33.2 = a338aaffc56f0f5040e6d9fa8a12eda1
PKG_MD5SUM=$(PKG_MD5SUM_$(PKG_VERSION))

HOST_BUILD_DIR:=$(TARGET_BUILD_DIR_TOOLCHAIN)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/toolchain-build.mk

UCLIBC_TARGET_ARCH:=$(shell echo $(ARCH) | sed -e s'/-.*//' \
		-e 's/i.86/i386/' \
		-e 's/sparc.*/sparc/' \
		-e 's/arm.*/arm/g' \
		-e 's/avr32.*/avr32/g' \
		-e 's/m68k.*/m68k/' \
		-e 's/ppc/powerpc/g' \
		-e 's/v850.*/v850/g' \
		-e 's/sh64/sh/' \
		-e 's/sh[234].*/sh/' \
		-e 's/mips.*/mips/' \
		-e 's/mipsel.*/mips/' \
		-e 's/cris.*/cris/' \
)

UCLIBC_KERNEL_HEADERS_DIR:=$(TARGET_BUILD_DIR_TOOLCHAIN)/$(LIBC)-dev/

#GEN_CONFIG=$(SCRIPT_DIR)/kconfig.pl -n \
#	$(if $(wildcard $(CONFIG_DIR)/common),'+' $(CONFIG_DIR)/common) \
#	$(if $(CONFIG_UCLIBC_ENABLE_DEBUG),$(if $(wildcard $(CONFIG_DIR)/debug),'+' $(CONFIG_DIR)/debug)) \
#	$(CONFIG_DIR)/$(ARCH)$(strip \
#		$(if $(wildcard $(CONFIG_DIR)/$(ARCH).$(BOARD)),.$(BOARD), \
#			$(if $(CONFIG_HAS_SPE_FPU),$(if $(wildcard $(CONFIG_DIR)/$(ARCH).e500),.e500))))

# TODO: FREETZ_TARGET_UCLIBC_REDUCED_LOCALE_SET is a REBUILD_SUBOPT
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_REDUCED_LOCALE_SET)),y)
UCLIBC_LOCALE_DATA_FILENAME:=uClibc-locale-$(if $(FREETZ_TARGET_ARCH_BE),be,le)-32-de_DE-en_US.tar.gz
else
UCLIBC_LOCALE_DATA_FILENAME:=uClibc-locale-030818.tgz
endif
UCLIBC_COMMON_BUILD_FLAGS := LOCALE_DATA_FILENAME=$(UCLIBC_LOCALE_DATA_FILENAME)

ifeq ($(strip $(FREETZ_VERBOSITY_LEVEL)),2)
ifeq ($(or $(FREETZ_TARGET_UCLIBC_VERSION_0_9_32),$(FREETZ_TARGET_UCLIBC_VERSION_0_9_33)),y)
# Changed with uClibc-0.9.32-rc3: "V=1 is quiet plus defines. V=2 are verbatim commands."
# For more details see <http://lists.uclibc.org/pipermail/uclibc/2011-March/045005.html>
UCLIBC_COMMON_BUILD_FLAGS += V=2
else
UCLIBC_COMMON_BUILD_FLAGS += V=1
endif
endif

CPU_CFLAGS = \
	-funsigned-char -fno-builtin -fno-asm \
	--std=gnu99 -ffunction-sections -fdata-sections \
	-Wno-unused-but-set-variable \
	$(TARGET_CFLAGS)

UCLIBC_HOST_CFLAGS = \
	$(TOOLCHAIN_HOST_CFLAGS) -U_GNU_SOURCE -fno-strict-aliasing

UCLIBC_MAKE = PATH='$(TARGET_TOOLCHAIN_DIR)/initial/bin:$(TARGET_PATH)' $(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR) \
	$(TARGET_CONFIGURE_OPTS) \
	$(UCLIBC_COMMON_BUILD_FLAGS) \
	DEVEL_PREFIX=/ \
	RUNTIME_PREFIX=/ \
	HOSTCC="$(HOSTCC) $(UCLIBC_HOST_CFLAGS)" \
	CPU_CFLAGS="$(CPU_CFLAGS)" \
	ARCH="$(FREETZ_TARGET_ARCH)" \
	LIBGCC="$(subst libgcc.a,libgcc_initial.a,$(shell $(TARGET_CC) -print-libgcc-file-name))" \
	DOSTRIP=""

define Download/locale_data
  FILE:=$(UCLIBC_LOCALE_DATA_FILENAME)
  URL:=http://www.uclibc.org/downloads
endef
$(eval $(call Download,locale_data))

define Host/Prepare
	$(call Host/Prepare/Default)
	cp -dpf $(DL_DIR)/$(UCLIBC_LOCALE_DATA_FILENAME) $(HOST_BUILD_DIR)/extra/locale/
	$(if $(strip $(QUILT)), \
		cd $(HOST_BUILD_DIR); \
		if $(QUILT_CMD) next >/dev/null 2>&1; then \
			$(QUILT_CMD) push -a; \
		fi
	)
	ln -snf $(PKG_NAME)-$(PKG_VERSION) $(TARGET_BUILD_DIR_TOOLCHAIN)/$(PKG_NAME)
endef

define Host/Configure
#	$(GEN_CONFIG) > $(HOST_BUILD_DIR)/.config.new
	$(CP) $(CONFIG_DIR)/Config.$(PKG_VERSION) $(HOST_BUILD_DIR)/.config.new 
	$(call PKG_EDIT_CONFIG, \
		$(if $(FREETZ_TARGET_UCLIBC_0_9_28), \
			KERNEL_SOURCE=\"$(UCLIBC_KERNEL_HEADERS_DIR)\" \
		, \
			KERNEL_HEADERS=\"$(UCLIBC_KERNEL_HEADERS_DIR)/include\" \
			ARCH_WANTS_LITTLE_ENDIAN=$(if $(FREETZ_TARGET_ARCH_BE),n,y) \
			ARCH_WANTS_BIG_ENDIAN=$(if $(FREETZ_TARGET_ARCH_BE),y,n) \
		) \
		CONFIG_MIPS_ISA_MIPS32_4KC=$(if $(FREETZ_TARGET_ARCH_LE),y,n) \
		CONFIG_MIPS_ISA_MIPS32_24KC=$(if $(FREETZ_TARGET_ARCH_BE),y,n) \
		UCLIBC_HAS_IPV6=$(FREETZ_TARGET_IPV6_SUPPORT) \
		UCLIBC_HAS_LFS=$(FREETZ_TARGET_LFS) \
		UCLIBC_HAS_FOPEN_LARGEFILE_MODE=n \
		UCLIBC_HAS_WCHAR=y \
		\
		$(if $(or $(FREETZ_TARGET_UCLIBC_0_9_32),$(FREETZ_TARGET_UCLIBC_0_9_33)), \
			LINUXTHREADS_OLD=$(if $(FREETZ_AVM_UCLIBC_NPTL_ENABLED),n,y) \
			UCLIBC_HAS_THREADS_NATIVE=$(if $(FREETZ_AVM_UCLIBC_NPTL_ENABLED),y,n) \
		) \
	) $(HOST_BUILD_DIR)/.config.new
	cmp -s $(HOST_BUILD_DIR)/.config.new $(HOST_BUILD_DIR)/.config.last || { \
		cp $(HOST_BUILD_DIR)/.config.new $(HOST_BUILD_DIR)/.config && \
		$(MAKE) -C $(HOST_BUILD_DIR) oldconfig KBUILD_HAVE_NLS= HOSTCFLAGS="-DKBUILD_NO_NLS" && \
		$(MAKE) -C $(HOST_BUILD_DIR)/extra/config conf KBUILD_HAVE_NLS= HOSTCFLAGS="-DKBUILD_NO_NLS" && \
		cp $(HOST_BUILD_DIR)/.config.new $(HOST_BUILD_DIR)/.config.last; \
	}
endef

define Host/Clean
	rm -rf \
		$(HOST_BUILD_DIR) \
		$(TARGET_BUILD_DIR_TOOLCHAIN)/$(PKG_NAME) \
		$(TARGET_BUILD_DIR_TOOLCHAIN)/$(LIBC)-dev
endef
