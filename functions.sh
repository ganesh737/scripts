#!/bin/bash

source ~/src/scripts/print_helpers.sh
source ~/src/scripts/command_tracing.sh

function check_empty_and_exit_on_empty {
    print_info "check_empty_and_exit_on_empty"
    local var_name=$1
    local var_value=$2
    if [ "$var_value" == "" ]
    then
        trc_err_exit_and_restore "\"\$$var_name\" is empty"
    else
        print_debug "Variable is set as \"\$$var_name\"=\"$var_value\""
    fi
}


function check_if_android_release {
    print_info "check_if_android_release"
    local android_releases="nougatoreo"
    local release=$1
    if [ "$android_releases" == "*$release*" ]
    then
        print_info "A valid release"
    else
        trc_err_exit_and_restore "\"\$$release\" is not a valid Android Release"
    fi
}


function check_host_partition {
    print_info "check_host_partition"
    print_debug "Checking for partition $@"
    if [ "$@" == "/dev/sda" ] || [ "$@" == "/dev/sdb" ] || [ "$@" == "/dev/sdc" ] || [ "$@" == "/dev/sdd" ] ; then
        trc_err_exit_and_restore "Trying to use host machine\'s device"
    fi
}