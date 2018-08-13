#!/bin/bash

source ~/src/scripts/print_helpers.sh


function start_timing_process {
    print_info "start_timing_process"
    START_TIME_SECONDS=$(date +"%s")
}


function end_timing_process {
    print_info "end_timing_process"
    END_TIME_SECONDS=$(date +"%s")
}


function print_time_for_process {
    print_info "print_time_for_process"
    print_debug "Start Time=$START_TIME_SECONDS"
    print_debug "End Time=$END_TIME_SECONDS"
    local time_taken=$((END_TIME_SECONDS - START_TIME_SECONDS))
    print_info "Total Time Taken:$time_taken s"
}