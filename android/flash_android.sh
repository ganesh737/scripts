#!/bin/bash

source ../all_helpers.sh

RPI3_TMP_DIR="$HOME/src/rpi3/tmp/"


function create_boot {
    print_info "create_boot"
    fdisk_create_partition $FLASH_DRIVE +512M p a
    fdisk_update_partition_type_code $FLASH_DRIVE c
    fdisk_check_partition_creation $?
}

function create_system {
    print_info "create_system"
    fdisk_create_partition $FLASH_DRIVE +512M
    fdisk_check_partition_creation $?
}

function create_cache {
    print_info "create_cache"
    fdisk_create_partition $FLASH_DRIVE +512M
    fdisk_check_partition_creation $?
}

function create_userdata {
    print_info "create_userdata"
    fdisk_create_partition $FLASH_DRIVE rest p
}

function create_partitions {
    print_message_with_borders "create_partitions"
    create_boot
    create_system
    if [ "$FLASH_RELEASE" != "oreo" ]
    then
        create_cache
    fi
    create_userdata
    fdisk_print_partition_info "$FLASH_DRIVE"
}


function format_lable_userdata {
    print_info "format_lable_userdata"
    local userdataPartition=4
    if [ "$FLASH_RELEASE" == "oreo" ]
    then
        userdataPartition=3
    fi
    format_partition ${FLASH_DRIVE}${userdataPartition} ext4 data
    check_result $?
}

function format_partitions {
    print_message_with_borders "format_partitions"
    print_debug "format boot"
    format_partition ${FLASH_DRIVE}1 vfat BOOT
    if [ "$FLASH_RELEASE" != "oreo" ]
    then
        print_debug "format cache"
        format_partition ${FLASH_DRIVE}3 ext4 cache
    fi
    format_lable_userdata
    fdisk_print_partition_info "$FLASH_DRIVE"
}

function update_boot {
    print_info "update_boot"
    local boot_tmp_dir
    boot_tmp_dir=$(mktemp -d -t boot_XXXXXXXXXXXXXXXX -p $RPI3_TMP_DIR)
    sudo mount "$FLASH_DRIVE"1 "$boot_tmp_dir"
    tst sudo cp -rv $FLASH_CONTENT_DIR/boot/* "$boot_tmp_dir"
    tst sudo umount "$boot_tmp_dir"
    tst rmdir "$boot_tmp_dir"
}

function update_system {
    print_info "update_system"
    # print_debug "tst sudo dd if=\"$FLASH_CONTENT_DIR\"/system/system.img of=\"$FLASH_DRIVE\"2 bs=1M"
    tst sudo dd if=${FLASH_CONTENT_DIR}/system/system.img of=${FLASH_DRIVE}2 bs=1M
    label_partition ${FLASH_DRIVE}2 system
}

function update_contents {
    print_message_with_borders "update_contents"
    update_boot
    update_system
    fdisk_print_partition_info "$FLASH_DRIVE"
}


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

FLASH_RELEASE=$(echo $FLASH_CONTENT_DIR | sed "s/.*oid\/\(.*\)\/2.*/\1/")
check_empty_and_exit_on_empty "FLASH_RELEASE" "$FLASH_RELEASE"

read -p "Do you want to update Android on $FLASH_DRIVE ? " ANSWER

case "$ANSWER" in
    [yY]* )
        print_info "Continuing with update ...."
        ;;
    *)
        print_info "Stopping update"
        exit
        ;;
esac

check_host_partition "$FLASH_DRIVE"

start_timing_process

sudo umount "$FLASH_DRIVE"[0-9]

fdisk_delete_partitions $FLASH_DRIVE $ERASEWITHZEROS

create_partitions

format_partitions

update_contents

sync
sync

end_timing_process

print_time_for_process

print_message_with_borders "Flashing SD Card completed successfully !!!"
