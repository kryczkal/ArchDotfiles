#!/bin/bash

# Define the Waybar configuration file path
WAYBAR_CONFIG="config" # Make sure this is the correct path to your Waybar config

# Array of possible sensor identifiers
declare -a identifiers=("k10temp" "coretemp")

# Function to find the hwmon path
find_hwmon_path() {
    for id in "${identifiers[@]}"; do
        for hwmon in /sys/class/hwmon/hwmon*/temp*_input; do
            if grep -q "$id" "$(dirname "$hwmon")/name"; then
                echo "$hwmon"
                return 0
            fi
        done
    done
    echo "No known CPU temperature sensors found."
    return 1
}

# Capture the hwmon path
HW_PATH=$(find_hwmon_path)

# If a hwmon path was found, update the configuration file
if [ -n "$HW_PATH" ] && [ "$HW_PATH" != "No known CPU temperature sensors found." ]; then
    # Use sed to update the hwmon-path in the Waybar configuration file
    # This assumes that the hwmon-path is already set to something in the file
    sed -i "s|\"hwmon-path\": \".*\"|\"hwmon-path\": \"$HW_PATH\"|" "$WAYBAR_CONFIG"

    echo "Updated Waybar configuration with hwmon-path: $HW_PATH"
else
    echo "Could not find a CPU temperature sensor to update Waybar configuration."
    exit 1
fi
