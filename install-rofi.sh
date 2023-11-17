#!/bin/bash
paru -S --noconfirm rofi-lbonn-wayland-git

echo "Do you also want to install an icon theme? (recommended) (yes/no)"
read answer

# Convert the answer to lowercase to simplify matching
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

# Check the user's answer
if [ "$answer" = "yes" ] || [ "$answer" = "y" ]; then
    # Code to execute if user answers yes
    paru -S --noconfirm adwaita-icon-theme

elif [ "$answer" = "no" ] || [ "$answer" = "n" ]; then
    # Code to execute if user answers no
    echo "User chose no"

else
    # Inform the user if the response is not recognized
    echo "Invalid response. Interpreting as 'no'"
fi

