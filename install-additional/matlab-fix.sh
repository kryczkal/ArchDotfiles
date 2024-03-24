#!/bin/bash
# Function to append a string to a file if it does not already exist in the file.
# Parameters:
#   - string_to_append: The string to append to the file.
#   - target_file: The file to append the string to.
# Returns:
#   None
append_if_not_exists() {
    local string_to_append="$1"
    local target_file="$2"

    if ! grep -Fq "$string_to_append" "$target_file"; then
        echo "$string_to_append" >> "$target_file"
        echo "Appended to $target_file: $string_to_append"
    else
        echo "Already in $target_file: $string_to_append"
    fi
}
# Explanation of the code
echo "This code is a fix for the blank screen issue in MATLAB when running on the Wayland display server. It sets the environment variable _JAVA_AWT_WM_NONREPARENTING to 1, which enables non-reparenting window managers to work correctly with MATLAB."

# Prompt the user
echo "Would you like to apply this fix? (y/n)"
read response

# Check user's response
if [ "$response" == "y" ]; then
    # Code to append the export statement to the profile files
    EXPORT='export _JAVA_AWT_WM_NONREPARENTING=1'
    PROFILE_FILE="$HOME/.profile"
    ZPROFILE_FILE="$HOME/.zprofile"
    append_if_not_exists "$EXPORT" "$PROFILE_FILE"
    append_if_not_exists "$EXPORT" "$ZPROFILE_FILE"
fi
