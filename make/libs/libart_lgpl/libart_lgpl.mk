$(call PKG_INIT_LIB, 2.3.21)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=08559ff3c67fd95d57b0c5e91a6b4302
$(PKG)_SITE:=http://ftp.gnome.org/pub/gnome/sources/libart_lgpl/2.3

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libart_lgpl_2.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(STAGING_DIR)/usr/lib/libart_lgpl_2.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libart_lgpl_2.so.$($(PKG)_LIB_VERSION)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBART_LGPL_DIR) all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBART_LGPL_DIR) \
		DESTDIR="$(STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(STAGING_DIR)/usr/lib/libart_lgpl_2.la \
		$(STAGING_DIR)/usr/lib/pkgconfig/libart-2.0.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBART_LGPL_DIR) clean
	$(RM) -r $(STAGING_DIR)/usr/lib/libart* \
		$(STAGING_DIR)/usr/bin/libart2-config \
		$(STAGING_DIR)/usr/lib/pkgconfig/libart-2.0.pc \
		$(STAGING_DIR)/usr/include/libart-2.0

$(pkg)-uninstall:
	$(RM) $(LIBART_LGPL_TARGET_DIR)/libart*.so*

$(PKG_FINISH)
