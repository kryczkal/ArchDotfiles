#!/bin/bash

# Fetch connected outputs
outputs=()
for dir in /sys/class/drm/card*-*; do
    status_file="$dir/status"
    if [ -f "$status_file" ]; then
        status=$(cat "$status_file")
        if [ "$status" = "connected" ]; then
            output_name=$(basename "$dir")
            output_name=${output_name#card?-}
            outputs+=("$output_name")
        fi
    fi
done

# Check if any outputs were found
if [ ${#outputs[@]} -eq 0 ]; then
    echo "No connected outputs found."
    exit 1
fi

# Fetch available input devices
inputs=()
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
    inputs+=("$line")
done < <(riverctl list-inputs)

# Check if any inputs were found
if [ ${#inputs[@]} -eq 0 ]; then
    echo "No input devices found."
    exit 1
fi

# User selects an input device
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

# User selects an output
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

# Map input to the selected output if not ALL
if [ "$chosen_output" != "ALL" ]; then
    command="riverctl input $chosen_input map-to-output $chosen_output"
    echo $command
    riverctl input "$chosen_input" map-to-output "$chosen_output"
fi

echo "Configuration applied successfully."
