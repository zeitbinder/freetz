#
# Copyright (C) 2006-2010 OpenWrt.org
# Copyright (C) 2013 freetz.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Main makefile for the host tools
#
curdir:=tools

# subdirectories to descend into
tools-y :=
ifeq ($(FREETZ_EXTERNAL_TOOLCHAIN),)
tools-y += gmp mpfr mpc libelf
endif
tools-y += m4 libtool autoconf automake sed pkg-config
tools-y += kconfig busybox fakeroot find-squashfs sstrip lzma
tools-y += lzma2eva sfk squashfs squashfs3 tichksum
tools-$(FREETZ_STRIP_LIBRARIES) += mklibs
#tools-y += tar xdelta

#builddir dependencies
$(curdir)/autoconf/compile := $(curdir)/m4/install $(curdir)/libtool/install
$(curdir)/automake/compile := $(curdir)/m4/install $(curdir)/autoconf/install #$(curdir)/pkg-config/install $(curdir)/xz/install
$(curdir)/libtool/compile := $(curdir)/sed/install
$(curdir)/gmp/compile := $(curdir)/automake/install
$(curdir)/mpc/compile := $(curdir)/mpfr/install $(curdir)/gmp/install
$(curdir)/mpfr/compile := $(curdir)/gmp/install
$(curdir)/pkg-config/compile := $(curdir)/sed/install
$(curdir)/squashfs/compile := $(curdir)/lzma/install
$(curdir)/squashfs3/compile := $(curdir)/lzma/install
$(curdir)/libelf/compile := $(curdir)/automake/install

$(curdir)/builddirs := $(tools-y) $(tools-dep) $(tools-)
$(curdir)/builddirs-default := $(tools-y)

ifndef DUMP_TARGET_DB
define PrepareStaging
	@for dir in $(1); do ( \
		$(if $(QUIET),,set -x;) \
		mkdir -p "$$dir"; \
		cd "$$dir"; \
		mkdir -p bin lib include stamp; \
	); done
endef

# preparatory work
$(STAGING_DIR)/.prepared: $(TMP_DIR)/.build
	$(call PrepareStaging,$(STAGING_DIR))
	mkdir -p $(BUILD_DIR)/stamp
	touch $@

$(STAGING_DIR_HOST)/.prepared: $(TMP_DIR)/.build
	$(call PrepareStaging,$(STAGING_DIR_HOST))
	mkdir -p $(BUILD_DIR_HOST)/stamp $(STAGING_DIR_HOST)/include/sys
	$(INSTALL_DATA) $(TOPDIR)/tools/include/*.h $(STAGING_DIR_HOST)/include/
	$(INSTALL_DATA) $(TOPDIR)/tools/include/sys/*.h $(STAGING_DIR_HOST)/include/sys/
	ln -sf lib $(STAGING_DIR_HOST)/lib64
	touch $@


define PrepareCommand
$(STAGING_DIR_HOST)/bin/$(1): $(STAGING_DIR)/.prepared
	@mkdir -p "$$(dir $$@)"; rm -f "$$@"
	@export FILE="$$$$(which $(2) 2>/dev/null | grep -v 'not found' | head -n1)"; [ -n "$$$$FILE" ] || { \
		echo "Command $(1) not found."; false; \
	}; ln -s "$$$$FILE" "$$@"

endef
endif

$(STAGING_DIR_HOST)/bin/stat: $(STAGING_DIR)/.prepared
	@rm -f $@
	@if stat --version > /dev/null 2>&1; then \
		ln -s `which stat` $@; \
	elif gstat --version > /dev/null 2>&1; then \
		ln -s `which gstat` $@; \
	elif gnustat --version > /dev/null 2>&1; then \
		ln -s `which gnustat` $@; \
	else \
		echo "GNU stat not found"; \
		false; \
	fi

$(eval $(call PrepareCommand,find,gfind find))
$(eval $(call PrepareCommand,md5sum,gmd5sum md5sum $(SCRIPT_DIR)/md5sum))
$(eval $(call PrepareCommand,cp,gcp cp))
$(eval $(call PrepareCommand,seq,gseq seq))
$(eval $(call PrepareCommand,python,python2 python2.7 python))
$(eval $(call PrepareCommand,awk,gawk awk))
$(eval $(call PrepareCommand,getopt,gnugetopt /usr/local/bin/getopt getopt))
$(eval $(call PrepareCommand,grep,ggrep grep))
$(eval $(call PrepareCommand,host_tar,/bin/tar))
$(eval $(call PrepareCommand,diff,gdiff diff))

$(curdir)/cmddeps = $(patsubst %,$(STAGING_DIR_HOST)/bin/%,find md5sum cp stat seq python awk getopt grep diff host_tar)
$(curdir)//prepare = $(STAGING_DIR)/.prepared $(STAGING_DIR_HOST)/.prepared $($(curdir)/cmddeps)
$(curdir)//compile = $(STAGING_DIR)/.prepared $(STAGING_DIR_HOST)/.prepared $($(curdir)/cmddeps)

# prerequisites for the individual targets
$(curdir)/ := .config prereq
$(curdir)//install = $(1)/compile

$(eval $(call stampfile,$(curdir),tools,install,,))
$(eval $(call subdir,$(curdir)))
