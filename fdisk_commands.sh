#!/bin/bash

source ~/src/scripts/print_helpers.sh
source ~/src/scripts/partitioning_common.sh

function fdisk_print_partition_info {
    print_info "fdisk_print_partition_info"
    local _device=$1
    tst sudo fdisk -lu $_device
    tst sudo blkid ${_device}*
}


function fdisk_sleep_after_partition_change {
    print_debug "sleeping 1s to allow the partition change to reflect"
    sleep 1s
}


function fdisk_check_partition_creation {
    fdisk_sleep_after_partition_change
    if [ $1 -ne 0 ]
    then
        reload_partitions
    fi
}


function fdisk_delete_partitions {
    print_message_with_borders "fdisk_delete_partitions"
    local _device=$1
    local _erase_with_zeros=$2
    if [ ! -z "$_erase_with_zeros" ]
    then
        print_info "The next command will take some time. Enough time watch a movie with some popcorn :)"
        print_debug "tst dd if=/dev/zero bs=32M of=$_device"
        sudo dd if=/dev/zero bs=32M of=$_device
    fi
    print_debug "echo -e \"o\nw\n\" | sudo fdisk -u $_device"
    echo -e "o\nw\n" | sudo fdisk -u $_device
    fdisk_check_partition_creation $?
}


function fdisk_create_partition {
    print_info "fdisk_create_partition"
    local _device=$1
    local _size=$2
    local _partition_type=$3
    local _enable_bootflag=$4
    if [ "$_partition_type" == "" ] ; then
        _partition_type="p"
    fi
    if [ ! -z "$_enable_bootflag" ] ; then
        _enable_bootflag="a\n"
    fi
    if [ "$_size" == "rest" ] ; then
        _size=""
    fi
    print_debug "echo -e \"n\\n${_partition_type}\\n\\n\\n${_size}\\n${_enable_bootflag}w\\n\" | sudo fdisk -u $_device"
    echo -e "n\n${_partition_type}\n\n\n${_size}\n${_enable_bootflag}w\n" | sudo fdisk -u $_device
}


function fdisk_update_partition_type_code {
    print_info "fdisk_update_partition_type_code"
    local _device=$1
    local _partition_type_code=$2
    print_debug "echo -e \"t\\n${_partition_type_code}\\nw\\n\" \| sudo fdisk -u $_device"
    echo -e "t\n${_partition_type_code}\nw\n" | sudo fdisk -u $_device
}
