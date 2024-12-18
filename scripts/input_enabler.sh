#!/bin/bash

set -e
source "$(dirname "$0")/utils.sh"

# Fetch connected outputs
outputs=()
get_connected_outputs outputs

if [ ${#outputs[@]} -eq 0 ]; then
    echo "No connected outputs found."
    exit 1
fi

# Fetch available input devices
inputs=()
get_inputs inputs

if [ ${#inputs[@]} -eq 0 ]; then
    echo "No input devices found."
    exit 1
fi

echo "Available input devices:"
PS3="Please select an input device: "
select chosen_input in "${inputs[@]}"; do
    if [ -n "$chosen_input" ]; then
        echo "You have selected: $chosen_input"
        break
    else
        echo "Invalid selection."
    fi
done

outputs_with_all=("${outputs[@]}" "ALL")
echo "Available outputs:"
PS3="Please select an output (or ALL): "
select chosen_output in "${outputs_with_all[@]}"; do
    if [ -n "$chosen_output" ]; then
        echo "You have selected: $chosen_output"
        break
    else
        echo "Invalid selection."
    fi
done

if [ "$chosen_output" != "ALL" ]; then
    command="riverctl input $chosen_input map-to-output $chosen_output"
    echo $command
    riverctl input "$chosen_input" map-to-output "$chosen_output"
fi

echo "Configuration applied successfully."
