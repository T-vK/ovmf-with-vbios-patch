#! /bin/bash

# This build is based on information gather from:
#
#   https://www.reddit.com/r/VFIO/comments/8gv60l/current_state_of_optimus_muxless_laptop_gpu/
#   https://github.com/jscinoz/optimus-vfio-docs/issues/2#issuecomment-380335101
#   https://gist.github.com/Ashymad/2c8192519492dec262b344deb68fed44
#

rom_file=$1
echo "Building OVMF with a VBIOS for $rom_file"

# Prepare env
export SRC_DIR="/edk2"
export PATH="${SRC_DIR}/bin:${PATH}"
export EDK_TOOLS_PATH="${SRC_DIR}/BaseTools"

# Prepare for build
cd ${SRC_DIR}
mkdir -p bin
ln -sf /usr/bin/python2.7 bin/python

# Build Basetools
make -C BaseTools

# NVIDIA VBIOS Patches
/ovmf/prepare-rom-patch.sh $rom_file
cp /patches/vrom.h OvmfPkg/AcpiPlatformDxe/
cp /patches/vrom_table.h OvmfPkg/AcpiPlatformDxe/

dos2unix OvmfPkg/AcpiPlatformDxe/QemuFwCfgAcpi.c
patch -p1 < /ovmf/QemuFwCfgAcpi.c.patch
unix2dos OvmfPkg/AcpiPlatformDxe/QemuFwCfgAcpi.c

# Intel GVT-g Patches
patch -p1 < /ovmf/IntelIGD.patch

# Disable PIE
sed -r -i \
    -e 's/^BUILD_CFLAGS[[:space:]]*=(.*[a-zA-Z0-9])?/\0 -fPIC/' \
	BaseTools/Source/C/Makefiles/header.makefile || exit 1
sed -i '/^build -p/i echo $TARGET_TOOLS > target_tools_var' \
	OvmfPkg/build.sh || exit 1

# This build system is impressively complicated, needless to say
# it does things that get confused by PIE being enabled by default.
# Add -nopie to a few strategic places... :)
sed -r -i \
	-e 's/^DEFINE GCC_ALL_CC_FLAGS[[:space:]]*=(.*[a-zA-Z0-9])?/\0 -fno-pie/' \
	-e 's/^DEFINE GCC44_ALL_CC_FLAGS[[:space:]]*=(.*[a-zA-Z0-9])?/\0 -fno-pie/' \
	BaseTools/Conf/tools_def.template || exit 1
sed -r -i \
	-e 's/^BUILD_CFLAGS[[:space:]]*=(.*[a-zA-Z0-9])?/\0 -fno-pie/' \
	-e 's/^BUILD_LFLAGS[[:space:]]*=(.*[a-zA-Z0-9])?/\0 -no-pie/' \
	BaseTools/Source/C/Makefiles/header.makefile || exit 1

# Build OVMF
. edksetup.sh BaseTools
./BaseTools/BinWrappers/PosixLike/build -t GCC5 -a IA32 -a X64 -p OvmfPkg/OvmfPkgIa32X64.dsc -n $(nproc) -b RELEASE -D FD_SIZE_2MB -D SMM_REQUIRE -D SECURE_BOOT_ENABLE -D HTTP_BOOT_ENABLE -D TLS_ENABLE -D NETWORK_IP6_ENABLE -D TPM2_ENABLE -D TPM2_CONFIG_ENABLE -D EXCLUDE_SHELL_FROM_FD

# Copy to host build dir
cp ${SRC_DIR}/Build/Ovmf3264/RELEASE_GCC5/FV/OVMF_CODE.fd /build
cp ${SRC_DIR}/Build/Ovmf3264/RELEASE_GCC5/FV/OVMF_VARS.fd /build
