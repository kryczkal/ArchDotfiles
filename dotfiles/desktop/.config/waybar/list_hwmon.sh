#!/bin/bash

# List all temperature sensor input files and their associated device names

for hwmon in /sys/class/hwmon/hwmon*/temp*_input; do
    device="$(cat "$(dirname "$hwmon")/name")"
    echo "$device : $hwmon"
done

