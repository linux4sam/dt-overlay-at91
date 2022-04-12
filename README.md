# Microchip Device Tree Overlays and FIT image

## 1. Introduction

A device tree overlay is a file that can be used at runtime (by the bootloader 
in our case) to dynamically modify the device tree, by adding nodes to the tree 
and making changes to properties in the existing tree.

The FIT (Flattened Image Tree) format allows for flexibility in handling images 
of various types and enhances integrity protection of images with stronger checksums.

## 2. Build DT-Overlay

To build the overlays for a board make sure the following steps are done:

* the environment variables ARCH and CROSS_COMPILE are set correctly. By default,
ARCH is set to arm and will need to be explicitly overridden for riscv.
* (optional) the environment variable KERNEL_DIR points to Linux kernel and the 
kernel was already built for the board. This is needed because the DT Overlay 
repository uses the Device Tree Compiler (dtc) from the kernel source tree. By default, 
KERNEL_DIR is set to a linux directory that would be under the parent directory 
in the directory tree: ../linux
* (optional) the environment variable KERNEL_BUILD_DIR that points to where the Linux 
kernel binary and Device Tree blob, resulting of your compilation of the kernel, are 
located. By default, KERNEL_BUILD_DIR is set to the same directory as KERNEL_DIR. It 
shouldn't be changed if you have the habit of compiling your kernel within the Linux 
source tree 

The following example shows how to build the overlays for sama5d2_xplained:

    $ make sama5d2_xplained_dtbos

## 3. Build FIT image

 To build the FIT image with overlays for a board make sure the following steps 
are done:

* the environment variables ARCH and CROSS_COMPILE are set correctly. By default,
ARCH is set to arm and will need to be explicitly overridden for riscv.
* (optional) the environment variable KERNEL_DIR points to Linux kernel and the 
kernel was already built for the board. This is needed because the DT Overlay 
repository uses the Device Tree Compiler (dtc) from the kernel source tree. By 
default, KERNEL_DIR is set to a linux directory that would be under the parent 
directory in the directory tree: ../linux
* (optional) the environment variable KERNEL_BUILD_DIR that points to where the 
Linux kernel binary and Device Tree blob, resulting of your compilation of the 
kernel, are located. By default, KERNEL_BUILD_DIR is set to the same directory 
as KERNEL_DIR. It shouldn't be changed if you have the habit of compiling your 
kernel within the Linux source tree.
* mkimage is installed on the development machine and the Device Tree Compiler 
from Linux kernel is in the PATH environment variable 

The following example shows how to build the FIT image for sama5d2_xplained:

    $ make sama5d2_xplained.itb

## 4. Loading FIT image in u-boot

The FIT image is a placeholder that has the zImage and the base Device Tree, plus 
additional overlays that can be selected at boot time.

The following steps are required to boot the FIT Image from U-boot:

* Load the FIT image like you would normally load the uImage or zImage.
* There is no need to load additional Device Tree Blob, the FIT image includes it
* When booting the FIT image, specify the FIT configuration to use. Several 
configurations can be appended to the basic configuration, which we name 'kernel_dtb' 

Example:

    bootm 0x24000000#kernel_dtb

This will load the FIT image from address 0x24000000 in memory and then run the 
configuration named 'kernel_dtb'. This configuration includes the kernel plus the 
base Device Tree Blob built with the kernel.

To load additional FIT configurations, just append another configuration to the command.

Example to load the image sensor controller Device Tree overlay + sensor omnivision 0v7740:

    bootm 0x24000000#kernel_dtb#isc#ov7740

## 5. Contributing

To contribute to Microchip Device Tree Overlays, you should submit patches for 
review to the github pull-request facility directly. Do not forget to Cc the 
maintainers.

Maintainers:

Cristian Birsan <cristian.birsan@microchip.com>

Nicolas Ferre <nicolas.ferre@microchip.com>

For PolarFire SoC (MPFS), please also Cc:

Valentina Fernandez Alanis <valentina.fernandezalanis@microchip.com>

When creating patches insert the [dt-overlay-mchp] tag in the subject, for example
use something like:

    git format-patch -s --subject-prefix='dt-overlay-mchp][PATCH' <origin>
