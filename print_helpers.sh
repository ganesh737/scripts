#!/bin/bash


function print_info {
    message="$@"
    ## TODO: comment below line in 'devel' branch
    echo "INFO:  $message"
}


function print_debug {
    message="$@"
    if [ ! -z "$DEBUG" ] ; then
        echo "DEBUG: $message"
    fi
}


function print_error {
    message="$@"
    echo "ERROR: $message"
}

function print_message_with_borders {
    echo "**************************************************"
    echo "$1"
    echo "**************************************************"
}
