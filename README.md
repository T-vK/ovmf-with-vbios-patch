# ovmf-with-vbios-patch

Based on @bitthieves work which is based on @marcosscriven's initial work.

Automates the build of a patched OVMF image to be used with QEMU for NVIDIA GPU PCI/VFIO Passthrough.

Additionally, adds support for Intel GVT-g / RAMFB, which finally allows emulating a hybrid GPU setup (Optimus).

## How to use

### Method 1 (prebuilt docker image)

Set up

``` Bash
mkdir ./build
sudo docker pull tavk/ovmf-vbios-patch:1.0.1-edk2-stable201905
```

Patching OVMF 

``` Bash
# put your vBIOS ROM in ./rom/ and replace my-vbios.rom in the following command
sudo docker run --rm -ti -v "$(pwd)/build:/build:z" -v "$(pwd)/roms:/roms:z" -e "VROM=my-vbios.rom" tavk/ovmf-vbios-patch:1.0.1-edk2-stable201905
```

### Method 2 (build it yourself)

Set up

``` Bash
git clone https://github.com/T-vK/ovmf-with-vbios-patch.git
cd ovmf-with-vbios-patch
mkdir ./build
sudo docker build -t ovmf-vbios-patch .
```

Patching OVMF 

``` Bash
# put your vBIOS ROM in ./rom/ and replace my-vbios.rom in the following command
sudo docker run --rm -ti -v "$(pwd)/build:/build:z" -v "$(pwd)/roms:/roms:z" -e "VROM=my-vbios.rom" ovmf-vbios-patch
```

Your patched `OVMF_CODE.fd` and `OVMF_VARS.fd` files can be found in the `./build/` directory when it's done.
