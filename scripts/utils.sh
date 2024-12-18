#!/bin/bash

get_connected_outputs() {
    local -n ref=$1
    ref=()
    for dir in /sys/class/drm/card*-*; do
        status_file="$dir/status"
        if [ -f "$status_file" ]; then
            status=$(cat "$status_file")
            if [ "$status" = "connected" ]; then
                output_name=$(basename "$dir")
                output_name=${output_name#card?-}
                ref+=("$output_name")
            fi
        fi
    done
}

get_inputs() {
    local -n inputs_ref=$1
    inputs_ref=()
    
    while read -r line; do
        # Skip lines that start with whitespace (indented lines)
        if [[ "$line" =~ ^[[:space:]] ]]; then
            continue
        fi
        # Skip empty lines
        if [ -z "$line" ]; then
            continue
        fi
        # Skip lines that begin with any number of spaces and "configured:"
        if [[ "$line" =~ ^[[:space:]]*configured: ]]; then
            continue
        fi
        inputs_ref+=("$line")
    done < <(riverctl list-inputs)
}
