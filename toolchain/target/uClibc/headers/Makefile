PATH_PREFIX:=..

include ../common.mk

HOST_STAMP_BUILT:=$(HOST_BUILD_DIR)/.headers_built
HOST_STAMP_INSTALLED:=$(TARGET_TOOLCHAIN_DIR)/stamp/.uclibc_headers_installed

define Host/Compile

endef

define Host/Install
	PATH='$(TARGET_PATH)' $(MAKE) -C $(HOST_BUILD_DIR) \
		$(UCLIBC_COMMON_BUILD_FLAGS) \
		PREFIX="$(UCLIBC_KERNEL_HEADERS_DIR)" \
		DEVEL_PREFIX=/ \
		RUNTIME_PREFIX="$(UCLIBC_KERNEL_HEADERS_DIR)" \
		HOSTCC="$(HOSTCC) $(UCLIBC_HOST_CFLAGS)" \
		CC="$(TARGET_CC)" \
		CPU_CFLAGS="$(TARGET_CFLAGS)" \
		ARCH="$(FREETZ_TARGET_ARCH)" \
		headers \
		$(if $(FREETZ_TARGET_UCLIBC_0_9_28),install_dev,install_headers)
endef

$(eval $(call HostBuild))

