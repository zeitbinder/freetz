PATH_PREFIX=.

include ./common.mk

HOST_STAMP_BUILT:=$(HOST_BUILD_DIR)/.built
HOST_STAMP_INSTALLED:=$(TARGET_TOOLCHAIN_DIR)/stamp/.uclibc_installed

# uClibc >= 0.9.31 supports parallel building
ifeq ($(or $(FREETZ_TARGET_UCLIBC_0_9_32),$(FREETZ_TARGET_UCLIBC_0_9_33)),y)
HOST_BUILD_PARALLEL:=1
endif

define Host/SetToolchainInfo
	$(SED) -i -e 's,^\(LIBC_TYPE\)=.*,\1=$(PKG_NAME),' $(TARGET_TOOLCHAIN_DIR)/info.mk
	$(SED) -i -e 's,^\(LIBC_URL\)=.*,\1=http://www.uclibc.org/,' $(TARGET_TOOLCHAIN_DIR)/info.mk
	$(SED) -i -e 's,^\(LIBC_VERSION\)=.*,\1=$(PKG_VERSION),' $(TARGET_TOOLCHAIN_DIR)/info.mk
	$(SED) -i -e 's,^\(LIBC_SO_VERSION\)=.*,\1=$(LIBC_SO_VERSION),' $(TARGET_TOOLCHAIN_DIR)/info.mk
endef

define Host/Compile
	$(call PKG_EDIT_CONFIG,CROSS=$(FREETZ_TARGET_CROSS)) $(HOST_BUILD_DIR)/Rules.mak
	$(UCLIBC_MAKE) PREFIX= all
ifeq ($(or $(FREETZ_TARGET_UCLIBC_0_9_32),$(FREETZ_TARGET_UCLIBC_0_9_33)),y)
	# At this point uClibc is compiled and there is no reason for us to recompile it.
	# Remove some FORCE rule dependencies causing parts of uClibc to be recompiled (without a need)
	# over and over again each time make is invoked within uClibc dir (the actual target doesn't matter).
	# This is a bit dirty workaround we actually should get rid of as soon as we find a better solution.
	for i in $(HOST_BUILD_DIR)/Makerules $(HOST_BUILD_DIR)/extra/locale/Makefile.in; do \
		cp -a "$$$$i" "$$$$i-with-FORCE"; \
		$(SED) -i -r -e '/.*%[.]o[sS]:.*FORCE.*/s, FORCE , ,g' $$$$i; \
	done;
endif
endef

define Host/Install
	$(call Host/SetToolchainInfo)
	$(UCLIBC_MAKE) PREFIX="$(TARGET_TOOLCHAIN_DIR)/" install_runtime install_dev
	$(CP) $(HOST_BUILD_DIR)/libc/libc_so.a $(TARGET_TOOLCHAIN_DIR)/lib/
	$(CP) $(HOST_BUILD_DIR)/libpthread/*/libpthread_so.a $(TARGET_TOOLCHAIN_DIR)/lib/
	( cd $(TARGET_TOOLCHAIN_DIR) ; \
		for d in lib usr/lib ; do \
		  for f in libc.so libpthread.so libgcc_s.so ; do \
		    if [ -f $$$$d/$$$$f -a ! -L $$$$d/$$$$f ] ; then \
		      $(SED) -i -e 's,/usr/lib/,,g;s,/lib/,,g' $$$$d/$$$$f ; \
		    fi \
		  done \
		done \
	)
	rm -f \
		$(TARGET_TOOLCHAIN_DIR)/lib/libresolv*.so* \
		$(TARGET_TOOLCHAIN_DIR)/lib/libnsl*.so*
endef

$(eval $(call HostBuild))
