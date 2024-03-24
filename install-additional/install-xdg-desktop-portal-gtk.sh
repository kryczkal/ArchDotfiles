#!/bin/bash
paru -S --noconfirm xdg-desktop-portal-gtk

echo "Do you want to update the .zprofile and .profile to set the XDG_CURRENT_DESKTOP variable to sway? (yes/no)"
read answer
# Convert the answer to lowercase to simplify matching
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')


# General function to append a string to a file if it does not exist
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


# Check the user's answer
if [ "$answer" = "yes" ] || [ "$answer" = "y" ]; then
    EXPORT1='export XDG_CURRENT_DESKTOP=sway'
    EXPORT2='XDG_DESKTOP_PORTAL_DIR=/usr/share/xdg-desktop-portal/portals/'
    # Define the path to the .profile and .zprofile files
    PROFILE_FILE="$HOME/.profile"
    ZPROFILE_FILE="$HOME/.zprofile"
    # Code to execute if user answers yes
    # Check and append the exports to .profile
    append_if_not_exists "$EXPORT1" "$PROFILE_FILE"
    append_if_not_exists "$EXPORT2" "$PROFILE_FILE"
    # Check and append the exports to .zprofile
    append_if_not_exists "$EXPORT1" "$ZPROFILE_FILE"
    append_if_not_exists "$EXPORT2" "$ZPROFILE_FILE"
    echo "$PROFILE_FILE and $ZSHRC_FILE have been updated."
    echo "Changes will take place after reboot or manual sourcing of $PROFILE_FILE"

elif [ "$answer" = "no" ] || [ "$answer" = "n" ]; then
    # Code to execute if user answers no
    echo "You chose not to proceed."

else
    # Inform the user if the response is not recognized
    echo "Invalid response. Interpreting as 'no'"
fi

