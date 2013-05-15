$(call PKG_INIT_LIB, 5976d7536d8c7a8d5a7f60fd2a3c34876a224f30, uclibcxx)
$(PKG)_LIB_VERSION:=0.2.3
$(PKG)_SOURCE:=uClibc++-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=838aa335ef7f2fcf7191e82d375d0178
#release URL: $(PKG)_SITE:=http://cxx.uclibc.org/src
$(PKG)_SITE:=http://git.uclibc.org/uClibc++/snapshot
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/uClibc++-$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/libuClibc++-$($(PKG)_LIB_VERSION).so
$(PKG)_STAGING_BINARY:=$(STAGING_DIR)/usr/lib/libuClibc++-$($(PKG)_LIB_VERSION).so
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libuClibc++-$($(PKG)_LIB_VERSION).so

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libuClibc__WITH_WCHAR

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	cp $(UCLIBCXX_MAKE_DIR)/Config.uclibc++ $(UCLIBCXX_DIR)/.config
	$(call PKG_EDIT_CONFIG, \
		UCLIBCXX_HAS_LFS=$(FREETZ_TARGET_LFS) \
		UCLIBCXX_HAS_WCHAR=$(FREETZ_LIB_libuClibc__WITH_WCHAR) \
		UCLIBCXX_SUPPORT_WCIN=$(FREETZ_LIB_libuClibc__WITH_WCHAR) \
		UCLIBCXX_SUPPORT_WCOUT=$(FREETZ_LIB_libuClibc__WITH_WCHAR) \
		UCLIBCXX_SUPPORT_WCERR=$(FREETZ_LIB_libuClibc__WITH_WCHAR) \
	) $(UCLIBCXX_DIR)/.config
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UCLIBCXX_DIR) \
		CPU_CFLAGS="$(TARGET_CFLAGS)" \
		CROSS="$(TARGET_CROSS)" \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(UCLIBCXX_DIR) \
		CPU_CFLAGS="$(TARGET_CFLAGS)" \
		CROSS="$(TARGET_CROSS)" \
		DESTDIR="$(STAGING_DIR)/usr" \
		install
	$(SED) -i -e 's|-I/include/uClibc++|-I$(STAGING_DIR)/usr/include/uClibc++|g' $(STAGING_DIR)/usr/bin/g++-uc
	$(SED) -i -e 's|-L/lib/|-L$(STAGING_DIR)/usr/lib/|g' $(STAGING_DIR)/usr/bin/g++-uc
	mv	$(STAGING_DIR)/usr/bin/g++-uc \
		$(STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-g++-uc
	ln -sf $(REAL_GNU_TARGET_NAME)-g++-uc $(STAGING_DIR)/usr/bin/$(GNU_TARGET_NAME)-g++-uc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP_WILDCARD_BEFORE_SO)

uclibcxx: $($(PKG)_STAGING_BINARY)

uclibcxx-precompiled: $($(PKG)_TARGET_BINARY)

uclibcxx-clean:
	-$(SUBMAKE) -C $(UCLIBCXX_DIR) clean
	$(RM) -r \
		$(STAGING_DIR)/usr/bin/$(GNU_TARGET_NAME)-g++-uc \
		$(STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-g++-uc \
		$(STAGING_DIR)/usr/lib/libuClibc++* \
		$(STAGING_DIR)/usr/include/uClibc++

uclibcxx-uninstall:
	$(RM) $(UCLIBCXX_TARGET_DIR)/libuClibc++*.so*

$(PKG_FINISH)
