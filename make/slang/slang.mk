$(call PKG_INIT_BIN, 2.2.4)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=7fcfd447e378f07dd0c0bae671fe6487
$(PKG)_SITE:=ftp://space.mit.edu/pub/davis/slang/v2.2

$(PKG)_BINARY:=$($(PKG)_DIR)/src/elfobjs/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(STAGING_DIR)/usr/lib/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/lib$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_MODULES_DIR:=$(FREETZ_LIBRARY_PATH)/$(pkg)
$(PKG)_MODULES:=csv fcntl fork iconv pcre rand select slsmg socket sysconf termios varray zlib
$(PKG)_MODULES_LONG:=$($(PKG)_MODULES:%=%-module.so)
$(PKG)_MODULES_STAGING_DIR:=$($(PKG)_MODULES_LONG:%=$(STAGING_DIR)$($(PKG)_MODULES_DIR)/%)
$(PKG)_MODULES_TARGET_DIR:=$($(PKG)_MODULES_LONG:%=$($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/%)

$(PKG)_NOT_INCLUDED:=$(if $(FREETZ_PACKAGE_SLANG_MODULES),,$($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR))

$(PKG)_DEPENDS_ON += pcre zlib
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += libiconv
endif

$(PKG)_CONFIGURE_OPTIONS += --without-onig
$(PKG)_CONFIGURE_OPTIONS += --with-pcre="$(STAGING_DIR)"
$(PKG)_CONFIGURE_OPTIONS += --with-z="$(STAGING_DIR)"
$(PKG)_CONFIGURE_OPTIONS += --without-png
$(PKG)_CONFIGURE_OPTIONS += --with-readline=slang

$(PKG)_MAKE_PARAMS += MODULE_INSTALL_DIR="$(SLANG_MODULES_DIR)" STRIPPROG="$(TARGET_STRIP)"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(SLANG_DIR) $(SLANG_MAKE_PARAMS)

$($(PKG)_STAGING_BINARY) $($(PKG)_MODULES_STAGING_DIR): $($(PKG)_BINARY)
	$(SUBMAKE1) -C $(SLANG_DIR) $(SLANG_MAKE_PARAMS) \
		DESTDIR="$(STAGING_DIR)" \
		install
	$(call PKG_FIX_LIBTOOL_LA,prefix libdir includedir) \
		$(STAGING_DIR)/usr/lib/pkgconfig/slang.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

ifeq ($(strip $(FREETZ_PACKAGE_SLANG_MODULES)),y)
$($(PKG)_MODULES_TARGET_DIR): $($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/%: $(STAGING_DIR)$($(PKG)_MODULES_DIR)/%
	$(INSTALL_BINARY_STRIP)
endif

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $(if $(FREETZ_PACKAGE_SLANG_MODULES),$($(PKG)_MODULES_TARGET_DIR))

$(pkg)-clean:
	-$(SUBMAKE) -C $(SLANG_DIR) $(SLANG_MAKE_PARAMS) clean
	$(RM) -r \
		$(STAGING_DIR)/usr/lib/libslang* \
		$(STAGING_DIR)$(SLANG_MODULES_DIR) \
		$(STAGING_DIR)/usr/include/{slang,slcurses}.h \
		$(STAGING_DIR)/usr/lib/pkgconfig/slang.pc

$(pkg)-uninstall:
	$(RM) -r $(SLANG_TARGET_LIBDIR)/libslang*.so* $(SLANG_DEST_DIR)$(SLANG_MODULES_DIR)

$(call PKG_ADD_LIB,libslang)
$(PKG_FINISH)
