# Makefile for Freetz, Kernel 2.6 series
#
# Copyright (C) 1999-2004 by Erik Andersen <andersen@codepoet.org>
# Copyright (C) 2005-2006 by Daniel Eiband <eiband@online.de>
# Copyright (C) 2006-2011 by the Freetz developers (http://freetz.org)
#
# Licensed under the GPL v2, see the file COPYING in this tarball.

#--------------------------------------------------------------
# Just run 'make menuconfig', configure stuff, then run 'make'.
# You shouldn't need to mess with anything beyond this point...
#--------------------------------------------------------------
TOPDIR:=${CURDIR}
LC_ALL:=C
LANG:=C
export TOPDIR LC_ALL LANG

empty:=
space:= $(empty) $(empty)
$(if $(findstring $(space),$(TOPDIR)),$(error ERROR: The path to the Freetz directory must not include any spaces))

world:

include $(TOPDIR)/include/host.mk

ifneq ($(OPENWRT_BUILD),1)
  # XXX: these three lines are normally defined by rules.mk
  # but we can't include that file in this context
  empty:=
  space:= $(empty) $(empty)
  _SINGLE=export MAKEFLAGS=$(space);

  override OPENWRT_BUILD=1
  export OPENWRT_BUILD
  GREP_OPTIONS=
  export GREP_OPTIONS
  include $(TOPDIR)/include/debug.mk
  include $(TOPDIR)/include/depends.mk
  include $(TOPDIR)/include/toplevel.mk
else
  include rules.mk
  include $(INCLUDE_DIR)/depends.mk
  include $(INCLUDE_DIR)/subdir.mk
  include tools/Makefile
#  include target/Makefile
#  include package/Makefile
#  include tools/Makefile
#  include toolchain/Makefile

$(toolchain/stamp-install): $(tools/stamp-install)

printdb:
	@true

prepare: .config $(tools/stamp-install) #$(toolchain/stamp-install)

world: prepare image firmware FORCE

DL_TOOL:=$(SCRIPT_DIR)/freetz_download
PATCH_TOOL:=$(SCRIPT_DIR)/freetz_patch
CHECK_PREREQ_TOOL:=$(SCRIPT_DIR)/check_prerequisites
CHECK_BUILD_DIR_VERSION:=
CHECK_UCLIBC_VERSION:=$(SCRIPT_DIR)/check_uclibc

# do not use sorted-wildcard here, it's first defined in files included here
include $(sort $(wildcard include/make/*.mk))

$(DL_DIR) \
$(DL_FW_DIR) \
$(MIRROR_DIR) \
$(BUILD_DIR) \
$(PACKAGES_DIR_ROOT) \
$(SOURCE_DIR_ROOT) \
$(TOOLCHAIN_BUILD_DIR) \
$(TOOLS_BUILD_DIR) \
$(FW_IMAGES_DIR):
	@mkdir -p $@

-include .config.cmd

include toolchain/Makefile
include $(MAKE_DIR)/Makefile.in
include $(call sorted-wildcard,$(MAKE_DIR)/libs/*/Makefile.in)
include $(call sorted-wildcard,$(MAKE_DIR)/*/Makefile.in)

ALL_PACKAGES:=
LOCALSOURCE_PACKAGES:=
include $(call sorted-wildcard,$(MAKE_DIR)/libs/*/*.mk)
include $(call sorted-wildcard,$(MAKE_DIR)/*/*.mk)
NON_LOCALSOURCE_PACKAGES:=$(filter-out $(LOCALSOURCE_PACKAGES),$(ALL_PACKAGES))
PACKAGES_CHECK_DOWNLOADS:=$(patsubst %,%-check-download,$(NON_LOCALSOURCE_PACKAGES))
PACKAGES_MIRROR:=$(patsubst %,%-download-mirror,$(NON_LOCALSOURCE_PACKAGES))

TARGETS_CLEAN:=$(patsubst %,%-clean,$(TARGETS))
TARGETS_DIRCLEAN:=$(patsubst %,%-dirclean,$(TARGETS))
TARGETS_SOURCE:=$(patsubst %,%-source,$(TARGETS))
TARGETS_PRECOMPILED:=$(patsubst %,%-precompiled,$(TARGETS))

PACKAGES_BUILD:=$(patsubst %,%-package,$(PACKAGES))
PACKAGES_CLEAN:=$(patsubst %,%-clean,$(PACKAGES))
PACKAGES_DIRCLEAN:=$(patsubst %,%-dirclean,$(PACKAGES))
PACKAGES_LIST:=$(patsubst %,%-list,$(PACKAGES))
PACKAGES_SOURCE:=$(patsubst %,%-source,$(PACKAGES))
PACKAGES_PRECOMPILED:=$(patsubst %,%-precompiled,$(PACKAGES))

LIBS_CLEAN:=$(patsubst %,%-clean,$(LIBS))
LIBS_DIRCLEAN:=$(patsubst %,%-dirclean,$(LIBS))
LIBS_SOURCE:=$(patsubst %,%-source,$(LIBS))
LIBS_PRECOMPILED:=$(patsubst %,%-precompiled,$(LIBS))

TOOLCHAIN_CLEAN:=$(patsubst %,%-clean,$(TOOLCHAIN))
TOOLCHAIN_DIRCLEAN:=$(patsubst %,%-dirclean,$(TOOLCHAIN))
TOOLCHAIN_DISTCLEAN:=$(patsubst %,%-distclean,$(TOOLCHAIN))
TOOLCHAIN_SOURCE:=$(patsubst %,%-source,$(TOOLCHAIN))

ifeq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
include $(TOOLCHAIN_DIR)/make/kernel-toolchain.mk
include $(TOOLCHAIN_DIR)/make/target-toolchain.mk
else
include $(TOOLCHAIN_DIR)/make/download-toolchain.mk
endif

DL_IMAGE:=
image:

# Download Firmware Image
#  $(1) Suffix
define DOWNLOAD_FIRMWARE
ifneq ($(strip $(DL_SOURCE$(1))),)
IMAGE$(1):=$(DL_FW_DIR)/$(DL_SOURCE$(1))
DL_IMAGE+=$$(IMAGE$(1))
image: $$(IMAGE$(1))
$$(DL_FW_DIR)/$$(DL_SOURCE$(1)): | $(DL_FW_DIR)
ifeq ($$(strip $$(DL_SITE$(1))),)
	@echo
	@echo "Please copy the following file into the '$$(DL_FW_DIR)' sub-directory manually:"
	@echo "$$(DL_SOURCE$(1))"
	@echo
	@exit 3
else
	@if [ -n "$$(DL_SOURCE$(1)_CONTAINER)" ]; then \
		if [ ! -r $$(DL_FW_DIR)/$$(DL_SOURCE$(1)_CONTAINER) ]; then \
			if ! $$(DL_TOOL) --no-append-servers $$(DL_FW_DIR) "$$(DL_SOURCE$(1)_CONTAINER)" "$$(DL_SITE$(1))" $$(DL_SOURCE$(1)_CONTAINER_MD5) $$(SILENT); then \
				$$(call ERROR_MESSAGE,Could not download firmware image. See http://trac.freetz.org/wiki/FAQ#Couldnotdownloadfirmwareimage for details.); exit 3; \
			fi; \
		fi; \
		case "$$(DL_SOURCE$(1)_CONTAINER_SUFFIX)" in \
			.zip) \
				if ! unzip $$(QUIETSHORT) $$(DL_FW_DIR)/$$(DL_SOURCE$(1)_CONTAINER) $$(DL_SOURCE$(1)) -d $$(DL_FW_DIR); then \
					$$(call ERROR_MESSAGE,Could not unzip firmware image.);exit 3; \
				fi \
				;; \
			*) \
				$$(call ERROR_MESSAGE,Could not extract firmware image.); exit 3; \
				;; \
		esac \
	elif ! $$(DL_TOOL) --no-append-servers $$(DL_FW_DIR) "$$(DL_SOURCE$(1))" "$$(DL_SITE$(1))" $$(DL_SOURCE$(1)_MD5) $$(SILENT); then \
		$$(call ERROR_MESSAGE,Could not download firmware image. See http://trac.freetz.org/wiki/FAQ#Couldnotdownloadfirmwareimage for details.); exit 3; \
	fi
endif
endif
endef

$(eval $(call DOWNLOAD_FIRMWARE))
$(eval $(call DOWNLOAD_FIRMWARE,2))

package-list: package-list-clean $(PACKAGES_LIST)
	@touch .static
	@( echo "# Automatically generated - DO NOT EDIT!"; cat .static ) > .static.tmp
	@mv .static.tmp .static
	@touch .dynamic
	@( echo "# Automatically generated - DO NOT EDIT!"; cat .dynamic ) > .dynamic.tmp
	@mv .dynamic.tmp .dynamic

package-list-clean:
	@$(RM) .static .dynamic

# compat: TODO remove
ifdef FWMOD_NOPACK
$(error FWMOD_NOPACK is obsolete, please use FREETZ_FWMOD_SKIP_PACK=y or the corresponding menuconfig option instead)
endif

# compat: TODO remove
ifdef FWMOD_OPTS
$(error FWMOD_OPTS is obsolete, please use FREETZ_FWMOD_* or the corresponding menuconfig options instead)
endif

ifeq ($(strip $(PACKAGES)),)
firmware-nocompile: tools $(DL_IMAGE) package-list
	@echo
	@echo "WARNING: There are no packages selected. To install packages type"
	@echo "         'make menuconfig' and change to the 'Package selection' submenu."
	@echo
else
firmware-nocompile: tools $(DL_IMAGE) $(PACKAGES) package-list
endif
ifneq ($(findstring firmware-nocompile,$(MAKECMDGOALS)),firmware-nocompile)
	@./fwmod -d $(BUILD_DIR_FIRMWARE) $(DL_IMAGE)
else
	@./fwmod -n -d $(BUILD_DIR_FIRMWARE) $(DL_IMAGE)
endif

firmware: precompiled firmware-nocompile

test: $(FIRMWARE_BUILD_DIR)/modified
	@echo "no tests defined"

toolchain-depend: | $(TOOLCHAIN)
# Use KTV and TTV variables to provide new toolchain versions, i.e.
#   make KTV=freetz-0.4 TTV=freetz-0.5 toolchain
toolchain: $(DL_DIR) $(SOURCE_DIR_ROOT) $(TOOLCHAIN) tools
	@echo
	@echo "Creating toolchain tarballs ... "
	@$(call TOOLCHAIN_CREATE_TARBALL,$(KERNEL_TOOLCHAIN_STAGING_DIR),$(KTV))
	@$(call TOOLCHAIN_CREATE_TARBALL,$(TARGET_TOOLCHAIN_STAGING_DIR),$(TTV))
	@echo
	@echo "FINISHED: new download toolchains can be found in $(DL_DIR)/"

libs: $(DL_DIR) $(SOURCE_DIR_ROOT) $(LIBS_PRECOMPILED)

sources: $(DL_DIR) $(FW_IMAGES_DIR) $(SOURCE_DIR_ROOT) $(PACKAGES_DIR_ROOT) $(DL_IMAGE) \
	$(TARGETS_SOURCE) $(PACKAGES_SOURCE) $(LIBS_SOURCE) $(TOOLCHAIN_SOURCE) 

precompiled: $(DL_DIR) $(FW_IMAGES_DIR) $(SOURCE_DIR_ROOT) $(PACKAGES_DIR_ROOT) toolchain-depend \
	$(LIBS_PRECOMPILED) $(TARGETS_PRECOMPILED) $(PACKAGES_PRECOMPILED)

check-downloads: $(PACKAGES_CHECK_DOWNLOADS)

mirror: $(MIRROR_DIR) $(PACKAGES_MIRROR)

clean: $(TARGETS_CLEAN) $(PACKAGES_CLEAN) $(LIBS_CLEAN) $(TOOLCHAIN_CLEAN) common-clean
dirclean: $(TOOLCHAIN_DIRCLEAN) common-dirclean
distclean: $(TOOLCHAIN_DISTCLEAN) common-distclean

.PHONY: firmware package-list package-list-clean sources precompiled toolchain toolchain-depend libs mirror check-downloads \
	$(TARGETS) $(TARGETS_CLEAN) $(TARGETS_DIRCLEAN) $(TARGETS_SOURCE) $(TARGETS_PRECOMPILED) \
	$(PACKAGES) $(PACKAGES_BUILD) $(PACKAGES_CLEAN) $(PACKAGES_DIRCLEAN) $(PACKAGES_LIST) $(PACKAGES_SOURCE) $(PACKAGES_PRECOMPILED) \
	$(LIBS) $(LIBS_CLEAN) $(LIBS_DIRCLEAN) $(LIBS_SOURCE) $(LIBS_PRECOMPILED) \
	$(TOOLCHAIN) $(TOOLCHAIN_CLEAN) $(TOOLCHAIN_DIRCLEAN) $(TOOLCHAIN_DISTCLEAN) $(TOOLCHAIN_SOURCE)

push-firmware:
	@if [ ! -f "build/modified/firmware/var/tmp/kernel.image" ]; then \
		echo "Please run 'make' first."; \
	else \
		$(SCRIPT_DIR)/push_firmware build/modified/firmware/var/tmp/kernel.image ; \
	fi

recover:
	@if [ -z "$(IMAGE)" ]; then \
		echo "Specify an image to recover." 1>&2; \
		echo "e.g. make recover IMAGE=some.image" 1>&2; \
	elif [ -z "$(RECOVER)" ]; then \
		echo "Specify recover script." 1>&2; \
		echo "make recover RECOVER=[adam|eva|ds]" 1>&2; \
		echo "  adam - old boxes like ATA (kernel 2.4)" 1>&2; \
		echo "  eva  - all boxes with kernel 2.6" 1>&2; \
		echo "  ds   - modified adam script from freetz" 1>&2; \
	elif [ ! -r "$(IMAGE)" ]; then \
		echo "Cannot read $(IMAGE)." 1>&2; \
	else \
		echo "This can help if your box is not booting any more"; \
		echo "(Power LED on and flashing of all LEDs every 5 secs)."; \
		echo; \
		echo "Make sure that there is only one box in your subnet."; \
		echo; \
		while true; do \
			echo "Are you sure you want to recover filesystem and kernel"; \
			echo -n "from $(IMAGE)? (y/n) "; \
			read yn; \
			case "$$yn" in \
				[yY]*) \
					echo; \
					if [ -z "$(LOCALIP)" ]; then \
						echo "If this fails try to specify a local IP adress. Your"; \
						echo "local IP has to be in the 192.168.178.0/24 subnet."; \
						echo "e.g. make recover LOCALIP=192.168.178.20"; \
						echo; \
						$(SCRIPT_DIR)/recover-$(RECOVER) -f "$(IMAGE)"; \
					else \
						$(SCRIPT_DIR)/recover-$(RECOVER) -l $(LOCALIP) -f "$(IMAGE)"; \
					fi; break ;; \
				[nN]*) \
					break ;; \
			esac; \
		done; \
	fi

# Macro to clean up config dependencies
#   $(1) = target name to be defined
#   $(2) = info text to be printed
#   $(3) = sub-regex for removing symbols from .config
#
# Note: We could also deactivate options which are on by default, but not
# selected by any packages, e.g. FREETZ_BUSYBOX_ETHER_WAKE or almost 20 default
# FREETZ_SHARE_terminfo_*. At the moment those options will be reactivated. To
# deactivate them as well, the 'sed' command for step 1 can be replaced by:
#   $$(SED) -i -r 's/^(FREETZ_($(3))_.+)=.+/\1=n/' .config; \
#
define CONFIG_CLEAN_DEPS
$(1):
	@{ \
	cp .config .config_tmp; \
	echo -n "Step 1: temporarily deactivate all $(2) ... "; \
	$$(SED) -i -r 's/^(FREETZ_($(3))_)/# \1/' .config; \
	echo "DONE"; \
	echo -n "Step 2: reactivate only elements required by selected packages or active by default ... "; \
	make oldnoconfig > /dev/null; \
	echo "DONE"; \
	echo "The following elements have been deactivated:"; \
	diff -U 0 .config_tmp .config | $$(SED) -rn 's/^\+# ([^ ]+) is not set$$$$/  \1/p'; \
	$$(RM) .config_tmp; \
	}
endef

# Decactivate optional stuff by category
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps-modules,kernel modules,MODULE))
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps-libs,shared libraries,LIB))
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps-busybox,BusyBox applets,BUSYBOX))
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps-terminfo,terminfos,SHARE_terminfo))
# Deactivate all optional stuff
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps,kernel modules$(_comma) shared libraries$(_comma) BusyBox applets and terminfos,MODULE|LIB|BUSYBOX|SHARE_terminfo))
# Deactivate all optional stuff except for Busybox applets
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps-keep-busybox,kernel modules$(_comma) shared libraries and terminfos,MODULE|LIB|SHARE_terminfo))

common-clean:
	./fwmod_custom clean
	$(RM) .static .dynamic .exclude-dist-tmp $(CONFIG_IN_CACHE)
	$(RM) -r $(BUILD_DIR)
	$(RM) -r $(FAKEROOT_CACHE_DIR)

common-dirclean: common-clean $(if $(FREETZ_HAVE_DOT_CONFIG),kernel-dirclean)
	$(RM) -r $(BUILD_DIR) $(PACKAGES_DIR_ROOT) $(SOURCE_DIR_ROOT)
	-cp .defstatic $(ADDON_DIR)/static.pkg
	-cp .defdynamic $(ADDON_DIR)/dynamic.pkg

common-distclean: common-dirclean $(if $(FREETZ_HAVE_DOT_CONFIG),kernel-distclean)
	$(RM) -r .config .config_compressed .config.old .config.cmd .tmpconfig.h include/config include/generated
	$(RM) -r $(FW_IMAGES_DIR)
	$(RM) -r $(SOURCE_DIR_ROOT)
	$(RM) -r $(TOOLCHAIN_BUILD_DIR)
	$(RM) -r $(TOOLS_BUILD_DIR)
	@echo "Use 'make download-clean' to remove the download directory"

download-clean:
	$(RM) -r $(DL_DIR)

dist: distclean download-clean
	version="$$(cat .version)"; \
	curdir="$$(basename $$(pwd))"; \
	dir="$$(cat .version | $(SED) -e 's#^\(ds-[0-9\.]*\).*$$#\1#')"; \
	( \
		cd ../; \
		[ "$$curdir" == "$$dir" ] || mv "$$curdir" "$$dir"; \
		( \
			find "$$dir" -type d -name .svn -prune; \
			$(SED) -e "s/\(.*\)/$$dir\/\1/" "$$dir/.exclude-dist"; \
			echo "$${dir}/.exclude-dist"; \
			echo "$${dir}/.exclude-dist-tmp"; \
		) > "$$dir/.exclude-dist-tmp"; \
		tar --exclude-from="$${dir}/.exclude-dist-tmp" -cvjf "$${version}.tar.bz2" "$$dir"; \
		[ "$$curdir" == "$$dir" ] || mv "$$dir" "$$curdir"; \
		cd "$$curdir"; \
	)
	$(RM) .exclude-dist-tmp

### OpenWRT ###
ifndef DUMP_TARGET_DB
$(BUILD_DIR)/.prepared: Makefile
	@mkdir -p $$(dirname $@)
	@touch $@

tmp/.prereq_packages: .config
	unset ERROR; \
	for package in $(sort $(prereq-y) $(prereq-m)); do \
		$(_SINGLE)$(NO_TRACE_MAKE) -s -r -C package/$$package prereq || ERROR=1; \
	done; \
	if [ -n "$$ERROR" ]; then \
		$(call ERROR_MESSAGE,Package prerequisite check failed.); \
		false; \
	fi
	touch $@
endif

# check prerequisites before starting to build
prereq: $(target/stamp-prereq) tmp/.prereq_packages
	@if [ ! -f "$(INCLUDE_DIR)/site/$(REAL_GNU_TARGET_NAME)" ]; then \
		echo 'ERROR: Missing site config for target "$(REAL_GNU_TARGET_NAME)" !'; \
		echo '       The missing file will cause configure scripts to fail during compilation.'; \
		echo '       Please provide a "$(INCLUDE_DIR)/site/$(REAL_GNU_TARGET_NAME)" file and restart the build.'; \
		exit 1; \
	fi
### OpenWRT ###

.PHONY: all world step $(KCONFIG_TARGETS) config-cache tools recover prepare \
	config-clean-deps-modules config-clean-deps-libs config-clean-deps-busybox config-clean-deps-terminfo config-clean-deps config-clean-deps-keep-busybox \
	clean dirclean distclean common-clean common-dirclean common-distclean dist \
	$(CHECK_BUILD_DIR_VERSION)

endif
