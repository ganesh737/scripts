#!/bin/bash

source ~/src/scripts/print_helpers.sh

function trc {
    print_info "$@"
    "$@"
    local status=$?
    return $status
}


function trc_silent {
    print_info "$@"
    "$@" 2> /dev/null 1> /dev/null
    local status=$?
    return $status
}


function exit_and_restore {
    #       echo "Restore START"
    #       echo "Restore END"
    print_info "."
    print_info "$@"
    print_info "."
    exit $exit_code
}


function trc_err_exit_and_restore {
    print_info "."
    print_info "ERROR: $*"
    print_info "."
    exit_code=1
    exit_and_restore "Stopped \"$0\" with error!"
}


function tst {
    print_info "$@"
    "$@"
    local status=$?
    if [ $status -ne 0 ]
    then
        exit_code=$status
        trc_err_exit_and_restore "tst \"$*\" return $status"
    fi
    return $status
}


function check_result {
    local result=$1
    if [ $result -ne 0 ]
    then
        exit_code=$result
        trc_err_exit_and_restore "check_result returned \"$result\""
    fi
}