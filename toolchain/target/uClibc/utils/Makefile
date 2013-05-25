PATH_PREFIX=..

include ../common.mk

HOST_STAMP_BUILT:=$(HOST_BUILD_DIR)/.utils_built
HOST_STAMP_INSTALLED:=$(TARGET_TOOLCHAIN_DIR)/stamp/.uclibc_utils_installed

define Host/Compile
	$(SED) -i -e 's,^CROSS=.*,CROSS=$(TARGET_CROSS),g' $(HOST_BUILD_DIR)/Rules.mak
	$(UCLIBC_MAKE) PREFIX= utils
endef

define Host/Install
	$(INSTALL_DIR) $(TARGET_TOOLCHAIN_DIR)/bin
	$(INSTALL_BIN) \
		$(HOST_BUILD_DIR)/utils/ldd \
		$(TARGET_TOOLCHAIN_DIR)/bin/
	$(INSTALL_DIR) $(TARGET_TOOLCHAIN_DIR)/sbin
	$(INSTALL_BIN) \
		$(HOST_BUILD_DIR)/utils/ldconfig \
		$(TARGET_TOOLCHAIN_DIR)/sbin/
endef

$(eval $(call HostBuild))
