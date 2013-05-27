$(call PKG_INIT_LIB, 1.6.3)
$(PKG)_LIB_VERSION:=1.9.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=ddf02f4e1d2dc30f76734df806e613eb
$(PKG)_SITE:=http://developer.kde.org/~wheeler/files/src

$(PKG)_BINARY:=$($(PKG)_DIR)/taglib/.libs/libtag.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(STAGING_DIR)/usr/lib/libtag.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libtag.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON := $(STDCXXLIB) zlib
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

# touch some autotools' files to prevent configure from being regenerated
$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 configure.in.in configure.in subdirs acinclude.m4 aclocal.m4 admin/acinclude.m4.in admin/libtool.m4.in;

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-debug

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(PKG_MAKE) -C $(TAGLIB_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(PKG_MAKE) -C $(TAGLIB_DIR) \
		DESTDIR="$(STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(STAGING_DIR)/usr/lib/libtag.la \
		$(STAGING_DIR)/usr/lib/pkgconfig/taglib*.pc \
		$(STAGING_DIR)/usr/bin/taglib-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(PKG_MAKE) -C $(TAGLIB_DIR) clean
	$(RM) -r \
		$(STAGING_DIR)/usr/include/taglib \
		$(STAGING_DIR)/usr/lib/libtag* \
		$(STAGING_DIR)/usr/lib/pkgconfig/taglib*.pc \
		$(STAGING_DIR)/usr/bin/taglib-config

$(pkg)-uninstall:
	$(RM) $(TAGLIB_TARGET_DIR)/libtag*.so*

$(PKG_FINISH)
