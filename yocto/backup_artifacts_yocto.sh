#!/bin/bash

source ../all_helpers.sh

KERNEL_IMAGE_TYPE=zImage
DTBS="bcm2709-rpi-2-b.dtb \
    bcm2710-rpi-3-b.dtb \
    bcm2710-rpi-cm3.dtb"
BOOTLDRFILES="bootcode.bin \
              cmdline.txt \
              config.txt \
              fixup_cd.dat \
              fixup.dat \
              fixup_db.dat \
              fixup_x.dat \
              start_cd.elf \
              start_db.elf \
              start.elf \
              start_x.elf"

function copy_boot_contents {
    echo "Copying BOOT partition contents"
    local _boot_dir=${DESTDIR}/boot/
    tst mkdir -p "$_boot_dir"
    tst mkdir -p "$_boot_dir"/overlays

    for f in ${BOOTLDRFILES}; do
        if [ ! -f ${SRCDIR}/bcm2835-bootfiles/${f} ]; then
            trc_err_exit_and_restore "Bootloader file not found: ${SRCDIR}/bcm2835-bootfiles/$f"
        fi
    done
    tst cp -v "$SRCDIR"/bcm2835-bootfiles/* "$_boot_dir"
    for f in "$SRCDIR"/"$KERNEL_IMAGE_TYPE"-*.dtbo; do
        if [ -L $f ]; then
            tst cp -v "$f" "$_boot_dir/overlays"
        fi
    done
    # Using only zImage. So taking only zImage related changes from Jumpnowtek
    tst rename -v 's/zImage-([\w\-]+).dtbo/$1.dtbo/' "$_boot_dir"/overlays/*.dtbo

    for f in $DTBS; do
        tst cp "$SRCDIR"/${KERNEL_IMAGE_TYPE}-${f} "$_boot_dir"/${f}
    done

    tst cp -v "$SRCDIR"/"$KERNEL_IMAGE_TYPE" "$_boot_dir"
}

function copy_rootfs_contents {
    echo "Copying system partition contents"
    local _rfs_dir=${DESTDIR}/rfs/
    local _target_hostname=$TARGET_HOSTNAME

    tst mkdir -p "$_rfs_dir"
    tst cp -v "$SRCDIR"/console-image-raspberrypi3.tar.xz "$_rfs_dir"
    tst bash -c "echo ${_target_hostname} > $_rfs_dir/hostname"
}

# Main
TARGET_HOSTNAME=rpi3

ws_build_folder=$1
if [ -z $ws_build_folder ] ; then
    trc_err_exit_and_restore "Path to build folder is not provided!!!"
fi

image_type=$2

SRCDIR="$ws_build_folder"/tmp/deploy/images/raspberrypi3/
DESTDIR="$HOME"/src/rpi3/bin/yocto/"$bcode"/$(date +%Y%m%d%N)

tst mkdir -p "$DESTDIR"

copy_boot_contents

copy_rootfs_contents

print_message_with_borders "Copy completed successfully to $DESTDIR"
