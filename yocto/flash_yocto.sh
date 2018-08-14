#!/bin/bash

source ~/src/scripts/all_helpers.sh

RPI3_TMP_DIR="$HOME/src/rpi3/tmp/"
CREATE_PARTITIONS_OPTIONS=""

function create_boot_partition {
    print_info "create_boot_partition"
    fdisk_create_partition $FLASH_DRIVE +64M p a
    fdisk_update_partition_type_code $FLASH_DRIVE c
}

function create_rfs_partition {
    print_info "create_rfs_partition"
    fdisk_create_partition $FLASH_DRIVE rest p
}

function update_boot {
    print_info "update_boot"
    local _boot_tmp_dir
    format_partition ${BOOT_PARTITION} vfat BOOT "-F 32"
    _boot_tmp_dir=$(mktemp -d -t boot_XXXXXXXXXXXXXXXX -p $RPI3_TMP_DIR)
    tst sudo mount "$BOOT_PARTITION" "$_boot_tmp_dir"

    tst sudo cp -rv $FLASH_CONTENT_DIR/boot/* "$_boot_tmp_dir"
    sync

    tst sudo umount "$_boot_tmp_dir"
    tst rmdir "$_boot_tmp_dir"
}

function update_rfs {
    print_info "update_rfs"
    local _rfs_tmp_dir
    local _rfs_archive
    format_partition ${RFS_PARTITION} ext4 ROOT
    _rfs_tmp_dir=$(mktemp -d -t rfs_XXXXXXXXXXXXXXXX -p $RPI3_TMP_DIR)
    tst sudo mount "$RFS_PARTITION" "$_rfs_tmp_dir"

    _rfs_archive=$(ls "$FLASH_CONTENT_DIR"/rfs/*.tar.xz)
    tst sudo tar --numeric-owner -C "$_rfs_tmp_dir" -xJf "$_rfs_archive"
    tst sudo cp "$FLASH_CONTENT_DIR"/rfs/hostname "$_rfs_tmp_dir"/etc/
    sync

    tst sudo umount "$_rfs_tmp_dir"
    tst rmdir "$_rfs_tmp_dir"
}

#Main

if [ "x${1}" == "x" ] ; then
    trc_err_exit_and_restore "No options provided"
fi

for i in $@
do
    case $i in
        --dir=*)
            FLASH_CONTENT_DIR="${i#*=}"
            check_empty_and_exit_on_empty "FLASH_CONTENT_DIR" "$FLASH_CONTENT_DIR"
            ;;
        --drive=*)
            FLASH_DRIVE="${i#*=}"
            check_empty_and_exit_on_empty "FLASH_DRIVE" "$FLASH_DRIVE"
            ;;
        --erase)
            ERASEWITHZEROS="yes"
            ;;
        --debug)
            DEBUG="TRUE"
            ;;
        *)
            trc_err_exit_and_restore "Could not understand the option $i"
            ;;
    esac
done

check_host_partition "$FLASH_DRIVE"

BOOT_PARTITION=${FLASH_DRIVE}1
RFS_PARTITION=${FLASH_DRIVE}2

start_timing_process

sudo umount "$FLASH_DRIVE"[0-9]

# fdisk_delete_partitions $FLASH_DRIVE $ERASEWITHZEROS

# create_boot_partition

# create_rfs_partition

fdisk_print_partition_info $FLASH_DRIVE

update_boot

update_rfs

end_timing_process

print_time_for_process

print_message_with_borders "Flashing Yocto based binary to SD Card completed successfully !!!"

