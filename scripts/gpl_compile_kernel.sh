#!/bin/bash

# Adopt this to your cross-compiler-path
CROSS_COMPILE=${HOME}/GU_GPL/archiv/tmp-0-gcc_x86_64/usr/bin/mips-linux-

# The following exports are required for avm_init_scripts
export FRITZ_BOX_BUILD_DIR=`pwd`
export KERNEL_BUILD=linux-2.6.32
KERNEL_BUILD_DIR=${FRITZ_BOX_BUILD_DIR}/${KERNEL_BUILD}
export INSTALL_MOD_PATH=${KERNEL_BUILD_DIR}/filesystem
KERNEL_CONFIG=${KERNEL_BUILD_DIR}/.config

TMP_DIR=${FRITZ_BOX_BUILD_DIR}/tmp
################################################################################

####
# This function runs avm_init_scripts 
####
function run_avm_init_scripts () {
	init_scripts='./drivers/dsl/init_dsl ./drivers/char/avm_new/init_avm ./drivers/char/avm_net_trace/init_net_trace \
				 ./drivers/char/ubik2/init_ubik2 ./drivers/char/avm_power/init_power \
				 ./drivers/char/flash_update/init_flash_update ./drivers/char/Piglet_noemif/init_Piglet \
				 ./drivers/char/Piglet_noemif/init_Piglet_noemif ./drivers/char/dect_io/init_dect_io \
				 ./drivers/char/audio/init_audio ./drivers/isdn/isdn_fon5/init_isdn_fon2 \
				 ./drivers/isdn/isdn_fon5/init_isdn ./drivers/isdn/isdn_fon5/init_isdn_fon4 \
				 ./drivers/isdn/isdn_fon5/init_isdn_fon6 ./drivers/isdn/isdn_fon5/init_isdn_fon3 \
				 ./drivers/isdn/isdn_fon5/init_isdn_fon ./drivers/isdn/isdn_fon5/init_isdn_fon5 \
				 ./drivers/isdn/capi_codec/init_capi_codec ./drivers/isdn/avm_dect/init_avm_dect \
				 ./drivers/isdn/capi_oslib/init_capi_oslib ./drivers/usb/musb/init_usb_host20 \
				 ./drivers/usb/misc/usbauth/init_stick_and_surf'
	echo Running avm_init_scripts:
	for i in ${init_scripts} ; do 
		if test -e ${i} ; then
			if ! test -x ${i} ; then
				chmod +x ${i}
			fi
			echo -------- Running ${i} -------
			script=`realpath ${i}`
			( cd `dirname ${i}` &&  ${script} 26 )
		fi
	done

}

####
# Compile the kernel 
####
function compile_kernel() {
	kernel_gcc_version=$((`echo -e "(__GNUC__ * 10000) + (__GNUC_MINOR__ * 100) + __GNUC_PATCHLEVEL__" | ${CROSS_COMPILE}gcc -E -P -`))
	kbuild_cflags=""
	echo "[$0]: GCC_VERSION = ${kernel_gcc_version}"
	if [ "${kernel_gcc_version}" -ge "40600" ] ; then 
		kbuild_cflags="-Wno-error=implicit-function-declaration -Wno-error=unused-but-set-variable"
	else
		kbuild_cflags="-Wno-implicit-function-declaration"
	fi
	make CROSS_COMPILE=${CROSS_COMPILE} ARCH=mips menuconfig
	make CROSS_COMPILE=${CROSS_COMPILE} ARCH=mips -j 16 KBUILD_CFLAGS_GCC40600="${kbuild_cflags}"
}


####
# Link cpmac files
####
function setup_cpmac() {
	echo setup cpmac
	CPMAC_DIR=${KERNEL_BUILD_DIR}/drivers/net/avm_cpmac
	cp ${CPMAC_DIR}/linux_avm_cpmac.h ${KERNEL_BUILD_DIR}/include/linux/avm_cpmac.h
	cp ${CPMAC_DIR}/linux_adm_reg.h ${KERNEL_BUILD_DIR}/include/linux/adm_reg.h
	cp ${CPMAC_DIR}/linux_ar_reg.h ${KERNEL_BUILD_DIR}/include/linux/ar_reg.h
	cp ${CPMAC_DIR}/Makefile.26 ${CPMAC_DIR}/Makefile
}

####
# Main
####
cd ${KERNEL_BUILD_DIR}
run_avm_init_scripts
setup_cpmac
compile_kernel
