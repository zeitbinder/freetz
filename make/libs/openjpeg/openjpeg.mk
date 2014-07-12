$(call PKG_INIT_LIB, 1.5.2)
$(PKG)_LIB_VERSION:=1.5.2
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=c41772c30fb1c272358b3707233134a1
$(PKG)_SITE:=http://openjpeg.googlecode.com/files,@SF/openjpeg.mirror

$(PKG)_BINARY:=$($(PKG)_DIR)/libopenjpeg/.libs/libopenjpeg.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libopenjpeg.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libopenjpeg.so.$($(PKG)_LIB_VERSION)

$(PKG)_BUILD_PREREQ += autoreconf

$(PKG)_CONFIGURE_PRE_CMDS += autoreconf -f -i;
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG)_CONFIGURE_OPTIONS += --enable-jp3d=no
$(PKG)_CONFIGURE_OPTIONS += --enable-jpwl=no
$(PKG)_CONFIGURE_OPTIONS += --enable-lcms1=no
$(PKG)_CONFIGURE_OPTIONS += --enable-lcms2=no
$(PKG)_CONFIGURE_OPTIONS += --enable-png=no
$(PKG)_CONFIGURE_OPTIONS += --enable-tiff=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OPENJPEG_DIR)/libopenjpeg \
		libopenjpeg.la

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(OPENJPEG_DIR)/libopenjpeg \
		DESTDIR=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		install-includesHEADERS install-libLTLIBRARIES
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libopenjpeg.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPENJPEG_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/openjpeg* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libopenjpeg*

$(pkg)-uninstall:
	$(RM) $(OPENJPEG_TARGET_DIR)/libopenjpeg*.so*

$(PKG_FINISH)
