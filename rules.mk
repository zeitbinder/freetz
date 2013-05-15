#
# Copyright (C) 2006-2010 OpenWrt.org
# Copyright (C) 2013 freetz.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

ifneq ($(__rules_inc),1)
__rules_inc=1

ifeq ($(DUMP),)
  -include $(TOPDIR)/.config
endif
include $(TOPDIR)/include/debug.mk
include $(TOPDIR)/include/verbose.mk

TMP_DIR:=$(TOPDIR)/tmp
export TMP_DIR:=$(TMP_DIR)

GREP_OPTIONS=
export GREP_OPTIONS

qstrip=$(strip $(subst ",,$(1)))
#"))

empty:=
space:= $(empty) $(empty)
merge=$(subst $(space),,$(1))
confvar=$(call merge,$(foreach v,$(1),$(if $($(v)),y,n)))
strip_last=$(patsubst %.$(lastword $(subst .,$(space),$(1))),%,$(1))
    
define sep
  
endef

_SINGLE=export MAKEFLAGS=$(space);
CFLAGS:=
ARCH:=$(subst i486,i386,$(subst i586,i386,$(subst i686,i386,$(call qstrip,$(FREETZ_TARGET_ARCH)))))
ARCH_PACKAGES:=$(call qstrip,$(FREETZ_TARGET_ARCH_PACKAGES))
BOARD:=$(call qstrip,$(FREETZ_TARGET_BOARD))
TARGET_OPTIMIZATION:=$(call qstrip,$(FREETZ_TARGET_OPTIMIZATION))
TARGET_SUFFIX=$(call qstrip,$(FREETZ_TARGET_SUFFIX))
BUILD_SUFFIX:=$(call qstrip,$(FREETZ_BUILD_SUFFIX))
SUBDIR:=$(patsubst $(TOPDIR)/%,%,${CURDIR})
export SHELL:=/usr/bin/env bash


# TODO: config option for download folder
DL_DIR:=$(if $(call qstrip,$(FREETZ_DOWNLOAD_FOLDER)),$(call qstrip,$(FREETZ_DOWNLOAD_FOLDER)),$(TOPDIR)/dl)
BIN_DIR:=$(TOPDIR)/bin/$(BOARD)
INCLUDE_DIR:=$(TOPDIR)/include
SCRIPT_DIR:=$(TOPDIR)/scripts
BUILD_DIR_BASE:=$(TOPDIR)/build_dir
BUILD_DIR_HOST:=$(BUILD_DIR_BASE)/host
STAGING_DIR_HOST:=$(TOPDIR)/staging_dir/host

TARGET_ARCH:=$(call qstrip,$(FREETZ_TARGET_ARCH))
FREETZ_LIBC:=uClibc

GCCV:=$(call qstrip,$(FREETZ_TARGET_GCC_VERSION))
LIBC:=$(call qstrip,$(FREETZ_LIBC))
LIBCV:=$(call qstrip,$(FREETZ_TARGET_UCLIBC_VERSION))
REAL_GNU_TARGET_NAME=$(OPTIMIZE_FOR_CPU)-freetz-linux$(if $(TARGET_SUFFIX),-$(TARGET_SUFFIX))
GNU_TARGET_NAME=$(OPTIMIZE_FOR_CPU)-freetz-linux
DIR_SUFFIX:=_$(LIBC)-$(LIBCV)$(if $(FREETZ_arm),_eabi)
REAL_GNU_KERNEL_NAME:=$(TARGET_ARCH)-unknown-linux-gnu
GNU_TARGET_NAME:=$(TARGET_ARCH)-linux
REAL_GNU_TARGET_NAME:=$(GNU_TARGET_NAME)-uclibc
BUILD_DIR:=$(BUILD_DIR_BASE)/target-$(GNU_TARGET_NAME)$(if $(BUILD_SUFFIX),_$(BUILD_SUFFIX))
STAGING_DIR:=$(TOPDIR)/staging_dir/target-$(ARCH)$(ARCH_SUFFIX)$(DIR_SUFFIX)$(if $(BUILD_SUFFIX),_$(BUILD_SUFFIX))

STAMP_DIR:=$(BUILD_DIR)/stamp
STAMP_DIR_HOST=$(BUILD_DIR_HOST)/stamp
#TARGET_ROOTFS_DIR?=$(if $(call qstrip,$(FREETZ_TARGET_ROOTFS_DIR)),$(call qstrip,$(FREETZ_TARGET_ROOTFS_DIR)),$(B
#TARGET_DIR:=$(TARGET_ROOTFS_DIR)/root-$(BOARD)
STAGING_DIR_ROOT:=$(STAGING_DIR)/root-$(BOARD)
BUILD_LOG_DIR:=$(TOPDIR)/logs

PKG_INFO_DIR := $(STAGING_DIR)/pkginfo

#TARGET_CFLAGS:=$(TARGET_OPTIMIZATION)$(if $(FREETZ_DEBUG), -g3)
#TARGET_CXXFLAGS = $(TARGET_CFLAGS)
#TARGET_CPPFLAGS:=-I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include
#TARGET_LDFLAGS:=-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib

### Freetz ###
IMAGE:=
LOCALIP:=
RECOVER:=
export FREETZ_BASE_DIR:=$(shell pwd)
ADDON_DIR:=addon
#BUILD_DIR:=build
#DL_DIR:=dl
FAKEROOT_CACHE_DIR:=$(TMP_DIR)/.fakeroot-cache
#INCLUDE_DIR:=include
MAKE_DIR:=make
PACKAGES_DIR_ROOT:=packages
SOURCE_DIR_ROOT:=source
#TOOLCHAIN_DIR:=toolchain
DL_FW_DIR:=$(DL_DIR)/fw
export FW_IMAGES_DIR:=images
MIRROR_DIR:=$(DL_DIR)/mirror
#SCRIPT_DIR:=scripts
TOOLS_DIR:=tools
BUILD_DIR_FIRMWARE:=$(BUILD_DIR_BASE)/image

HOST_TOOLS_DIR:=$(FREETZ_BASE_DIR)/$(TOOLS_BUILD_DIR)
#TOOLCHAIN_BUILD_DIR:=$(TOPDIR)/staging_dir/toolchain-$(ARCH)$(ARCH_SUFFIX)_gcc-$(GCCV)$(DIR_SUFFIX)
TOOLCHAIN_DIR:=$(TOPDIR)/staging_dir/toolchain
TOOLCHAIN_DIR_TARGET:=$(TOPDIR)/staging_dir/toolchain/$(ARCH)$(ARCH_SUFFIX)_gcc-$(GCCV)$(DIR_SUFFIX)
TOOLCHAIN_DIR_KERNEL:=$(TOPDIR)/staging_dir/toolchain/$(ARCH)$(ARCH_SUFFIX)_gcc-$(GCCV)

KERNEL_TOOLCHAIN_STAGING_DIR:=$(TOOLCHAIN_DIR_KERNEL)/$(REAL_GNU_KERNEL_NAME)
TARGET_TOOLCHAIN_STAGING_DIR:=$(TOOLCHAIN_DIR_TARGET)/$(REAL_GNU_TARGET_NAME)


### Freetz ###
             
TARGET_PATH:=$(STAGING_DIR_HOST)/bin:$(subst $(space),:,$(filter-out .,$(filter-out ./,$(subst :,$(space),$(PATH)))))

TARGET_PATH:=$(TARGET_TOOLCHAIN_STAGING_DIR)/bin:$(KERNEL_TOOLCHAIN_STAGING_DIR)/bin:$(TARGET_PATH)

export PATH:=$(TARGET_PATH)
export STAGING_DIR
export SH_FUNC:=. $(INCLUDE_DIR)/shell.sh;

PKG_CONFIG:=$(STAGING_DIR_HOST)/bin/pkg-config

export PKG_CONFIG

HOSTCC:=gcc
HOSTCC_NOCACHE:=$(HOSTCC)
HOST_CPPFLAGS:=-I$(STAGING_DIR_HOST)/include
HOST_CFLAGS:=-O2 $(HOST_CPPFLAGS)
HOST_LDFLAGS:=-L$(STAGING_DIR_HOST)/lib
HOST_STRIP:=strip --strip-all -R .note -R .comment

KPATCH:=$(SCRIPT_DIR)/patch-kernel.sh
#SED:=$(STAGING_DIR_HOST)/bin/sed -i -e
SED:=sed
CP:=cp -fpR
LN:=ln -sf

INSTALL_BIN:=install -m0755
INSTALL_DIR:=install -d -m0755
INSTALL_DATA:=install -m0644
INSTALL_CONF:=install -m0600


# TODO config tar verbosity and build log
ifeq ($(FREETZ_TAR_VERBOSITY),y)
  TAR_OPTIONS:=-xvf -
else
  TAR_OPTIONS:=-xf -
endif

ifeq ($(FREETZ_BUILD_LOG),y)
  BUILD_LOG:=1
endif

define shvar
V_$(subst .,_,$(subst -,_,$(subst /,_,$(1))))
endef

define shexport
$(call shvar,$(1))=$$(call $(1))
export $(call shvar,$(1))
endef

define include_mk
$(eval -include $(if $(DUMP),,$(STAGING_DIR)/mk/$(strip $(1))))
endef

# file extension
ext=$(word $(words $(subst ., ,$(1))),$(subst ., ,$(1)))
  
all:
FORCE: ;
.PHONY: FORCE
  
val.%:
	@$(if $(filter undefined,$(origin $*)),\
		echo "$* undefined" >&2, \
		echo '$(subst ','"'"',$($*))' \
	)
  
var.%:
	@$(if $(filter undefined,$(origin $*)),\
	echo "$* undefined" >&2, \
	echo "$*='"'$(subst ','"'\"'\"'"',$($*))'"'" \
	)

endif # __rules_inc
