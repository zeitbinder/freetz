GCC_VARIANT:=final

include ../common.mk

# NB: in order the toolchain to be relocatable this must be a subdir of the prefix
# TODO: modify gcc, so that we don't need this hack

GCC_CONFIGURE += \
	--prefix=$(TARGET_TOOLCHAIN_DIR) \
	--with-sysroot=$(TARGET_TOOLCHAIN_DIR) \
	--with-headers=$(TARGET_TOOLCHAIN_DIR)/include \
	--enable-languages=$(TARGET_LANGUAGES) \
	--enable-shared \
	--enable-threads


ifneq ($(FREETZ_TARGET_GCC_VERSION_4_5)$(FREETZ_TARGET_GCC_VERSION_4_6),)
  GCC_CONFIGURE += \
	--enable-lto \
	--with-libelf=$(TOPDIR)/staging_dir/host
endif

ifneq ($(FREETZ_TLS_SUPPORT),)
  GCC_CONFIGURE += \
	--enable-tls
else
  GCC_CONFIGURE += \
	--disable-tls
endif

ifneq ($(CONFIG_SJLJ_EXCEPTIONS),)
  GCC_CONFIGURE += \
	--enable-sjlj-exceptions
endif

define CleanupToolchain
	$(INSTALL_DIR) $(TARGET_TOOLCHAIN_DIR)/$(REAL_GNU_TARGET_NAME)
	# Important!  Required for limits.h to be fixed.
	rm -rf $(TARGET_TOOLCHAIN_DIR)/$(REAL_GNU_TARGET_NAME)/sys-include
	ln -sf ../include $(TARGET_TOOLCHAIN_DIR)/$(REAL_GNU_TARGET_NAME)/sys-include
	rm -rf $(TARGET_TOOLCHAIN_DIR)/$(REAL_GNU_TARGET_NAME)/lib
	ln -sf ../lib $(TARGET_TOOLCHAIN_DIR)/$(REAL_GNU_TARGET_NAME)/lib
endef

define Host/Configure
	$(CleanupToolchain)
	mkdir -p $(GCC_BUILD_DIR)
	(cd $(GCC_BUILD_DIR) && rm -f config.cache; \
		$(GCC_CONFIGURE) \
	);
endef

define Host/Compile
	+$(GCC_MAKE) $(HOST_JOBS) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR) all
endef

define Host/Install
	$(CleanupToolchain)
	$(_SINGLE)$(GCC_MAKE) -C $(GCC_BUILD_DIR) install
	$(call GCC_INSTALL_COMMON,$(TARGET_TOOLCHAIN_DIR)/usr,$(GCC_VERSION),$(REAL_GNU_TARGET_NAME),$(HOST_STRIP))
	$(call GCC_SET_HEADERS_TIMESTAMP,$(TARGET_TOOLCHAIN_DIR))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_TOOLCHAIN_DIR))
	# Set up the symlinks to enable lying about target name.
	set -e; \
	(cd $(TARGET_TOOLCHAIN_DIR); \
		ln -sf $(REAL_GNU_TARGET_NAME) $(GNU_TARGET_NAME); \
		cd bin; \
		for app in $(REAL_GNU_TARGET_NAME)-* ; do \
			ln -sf $$$${app} \
		   	$(GNU_TARGET_NAME)$$$${app##$(REAL_GNU_TARGET_NAME)}; \
		done; \
	);
	$(SCRIPT_DIR)/patch-specs.sh "$(TARGET_TOOLCHAIN_DIR)"
endef

$(eval $(call HostBuild))
