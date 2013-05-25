GCC_VARIANT:=initial

include ../common.mk

GCC_CONFIGURE += \
	--prefix=$(TARGET_TOOLCHAIN_DIR) \
	--with-sysroot=$(TARGET_TOOLCHAIN_DIR) \
	--with-newlib \
	--enable-languages=c \
	--disable-shared \
	--disable-threads \

define Host/Compile
	$(CP) $(TARGET_BUILD_DIR_TOOLCHAIN)/linux-dev/* $(TARGET_BUILD_DIR_TOOLCHAIN)/$(LIBC)-dev/
	+$(GCC_MAKE) $(HOST_JOBS) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR) \
		all-build-libiberty \
		all-gcc \
		$(if $(GCC_BUILD_TARGET_LIBGCC),all-target-libgcc)
endef

define Host/Install
	$(GCC_MAKE) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR) \
		prefix="$(TARGET_TOOLCHAIN_DIR)/initial" \
		install-gcc \
		$(if $(GCC_BUILD_TARGET_LIBGCC),install-target-libgcc)
	$(call GCC_INSTALL_COMMON,$(TARGET_TOOLCHAIN_DIR)/usr,$(GCC_VERSION),$(REAL_GNU_TARGET_NAME),$(HOST_STRIP))
	$(call GCC_SET_HEADERS_TIMESTAMP,$(TARGET_TOOLCHAIN_DIR))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_TOOLCHAIN_DIR))

	# XXX: glibc insists on linking against libgcc_eh
	( cd $(TARGET_TOOLCHAIN_DIR)/initial/lib/gcc/$(REAL_GNU_TARGET_NAME)/$(PKG_VERSION) ; \
		[ -e libgcc_eh.a ] || ln -sf libgcc.a libgcc_eh.a ; \
		cp libgcc.a libgcc_initial.a; \
	)

	$(call FixupLibdir,$(TARGET_TOOLCHAIN_DIR)/initial)
	$$(call file_copy,$(TARGET_TOOLCHAIN_DIR)/initial/.,$(TARGET_TOOLCHAIN_DIR)/)
endef

$(eval $(call HostBuild))
