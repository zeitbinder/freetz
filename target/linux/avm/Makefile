#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

ARCH:=mipsel
BOARD:=avm
BOARDNAME:=AVM Board
FEATURES:=squashfs jffs2 targz
SUBTARGETS=generic ar7 ar9 iks ohio ur8 vr9

LINUX_VERSION:=2.6.28
#FIXME
#include $(subtarget)/linux_version.mk

include $(INCLUDE_DIR)/target.mk

define Target/Description
        Build firmware images for AVM boards (Fritz!Box).
endef

$(eval $(call BuildTarget))

