#!/bin/bash

source ../common/functions.sh

function copy_boot_contents {
    echo "Copying BOOT partition contents"
    boot_dir=${destDir}/boot/
    tst mkdir -p "$boot_dir"/overlays
    tst cp -v ${srcDirPrefix}/device/brcm/rpi3/boot/* "$boot_dir"
    tst cp -v ${srcDirPrefix}/kernel/rpi/arch/arm/boot/zImage "$boot_dir"
    tst cp -v ${srcDirPrefix}/kernel/rpi/arch/arm/boot/dts/bcm2710-rpi-3-b.dtb "$boot_dir"
    tst cp -v ${srcDirPrefix}/kernel/rpi/arch/arm/boot/dts/overlays/vc4-kms-v3d.dtbo "$boot_dir"/overlays/vc4-kms-v3d.dtbo
    tst cp -v ${srcDirPrefix}/out/target/product/rpi3/ramdisk.img "$boot_dir"
}

function copy_system_contents {
    echo "Copying system partition contents"
    system_dir=${destDir}/system/
    tst mkdir -p "$system_dir"
    tst cp -v ${srcDirPrefix}/out/target/product/rpi3/system.img "$system_dir"
}

bcode=$1
check_empty_and_exit_on_empty "bcode" "$bcode"

srcDirPrefix=$HOME/src/rpi3/"$bcode"
destDir=$HOME/src/rpi3/bin/android/$bcode/$(date +%Y%m%d%N)

tst mkdir -p "$destDir"

copy_boot_contents

copy_system_contents

print_message_with_borders "Copy completed successfully to $destDir"
