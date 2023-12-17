#!/bin/bash
sudo pacman -S river wayland wlroots wayland-protocols
while true; do
    # Ask the user a yes/no question
    echo "Do you want to install my config along with all my river tools? (yes/no)"
    # TODO: this option in unnecesarry and misleading
    read answer

    # Convert the answer to lowercase to simplify matching
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

    # Check the user's answer
    if [ "$answer" = "yes" ] || [ "$answer" = "y" ]; then
        # Code to execute if user answers yes
        sudo pacman -S alacritty
        break  # Exit the loop

    elif [ "$answer" = "no" ] || [ "$answer" = "n" ]; then
        # Code to execute if user answers no
        echo "You chose not to proceed."
        break  # Exit the loop

    else
        # Inform the user if the response is not recognized
        echo "Invalid response. Please answer yes or no."
    fi
done
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
# Define the path to the .profile file
PROFILE_FILE="$HOME/.profile"
EXPORT="XDG_SESSION_TYPE=wayland"
append_if_not_exists "$EXPORT" "$PROFILE_FILE"
echo "Finished, you should be able to use 'river' command, if not, reboot"
# General function to append a string to a file if it does not exist
