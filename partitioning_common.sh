#!bin/bash

source ~/src/scripts/print_helpers.sh


function reload_partitions {
    print_info "reload_partitions"
    sudo partprobe -s
}


function label_partition {
    print_info "label_partition"
    local _device_partition=$1
    local _label=$2
    # TODO: some error handling on
    # * empty label name
    # * instead of device partition, device name is provided
    print_debug "sudo e2label \"$_device_partition\" $_label"
    sudo e2label $_device_partition $_label
    check_result $?
}


function format_partition {
    print_info "format_partition"
    local _device_partition=$1
    local _format_type=$2
    local _label=$3
    local _options=$4
    local _label_cmd=""
    # TODO: some error handling on
    # * empty parameters
    if [ "$_label" == "" ] ; then
        print_info "Not applying label along with format"
    else
        print_info "Applying label along with format"
        if [ "$_format_type" == "vfat" ] ; then
            print_debug "detected labelling of vfat partition"
            _label_cmd="-n$_label"
        elif [ "$_format_type" == "ext4" ] ; then
            print_debug "detected labelling of ext4 partition"
            _label_cmd="-L$_label"
        else
            print_error "unknown partition type for labelling. not applying any label"
        fi
    fi

    if [ -z "$_options" ] ; then
        print_debug "format_partition:sudo mkfs.$_format_type $_device_partition $_label_cmd"
        sudo mkfs."$_format_type" "$_device_partition" "$_label_cmd"
    else
        print_debug "format_partition:sudo mkfs.$_format_type $_device_partition $_label_cmd $_options"
        sudo mkfs."$_format_type" "$_device_partition" "$_label_cmd" "$_options"
    fi
    check_result $?
}
