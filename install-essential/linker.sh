#!/bin/bash
# Execute stow from inside the dotfiles directory
cd ../dotfiles
stow -t "$HOME" common

echo "Is your device a laptop (has battery/screen brightness) (yes/no)"
read answer

# Convert the answer to lowercase to simplify matching
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

# Check the user's answer
if [ "$answer" = "yes" ] || [ "$answer" = "y" ]; then
    # Code to execute if user answers yes
    stow -t "$HOME" laptop

elif [ "$answer" = "no" ] || [ "$answer" = "n" ]; then
    # Code to execute if user answers no
    stow -t "$HOME" desktop

else
    # Inform the user if the response is not recognized
    echo "Invalid response. Interpreting as 'no'"
fi

