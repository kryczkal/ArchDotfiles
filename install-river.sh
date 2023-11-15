#!/bin/bash
sudo pacman -S river wayland wlroots wayland-protocols
while true; do
    # Ask the user a yes/no question
    echo "Do you want to install my config along with all my river tools? (yes/no)"
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
echo 'export XDG_SESSION_TYPE=wayland' >> ~/.profile

echo "XDG_SESSION_TYPE set to Wayland in ~/.profile, This will be effective from the next login or if you source it"
echo "Finished, you should be able to use 'river' command, if not, reboot"
