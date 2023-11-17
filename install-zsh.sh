#!/bin/bash
paru -S --noconfirm zsh

echo "Do you want set zsh as the default shell for $(whoami)? (recommended) (yes/no)"
read answer

# Convert the answer to lowercase to simplify matching
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

# Check the user's answer
if [ "$answer" = "yes" ] || [ "$answer" = "y" ]; then
    # Code to execute if user answers yes
    echo "Setting Zsh as the default shell for user"
    ZSH_SHELL=$(which zsh)
    if chsh -s "$ZSH_SHELL"; then
        echo "Successfully changed the default shell to zsh."
        echo "Effect will take place after next login"
    else
        echo "Failed to change the default shell to zsh."
        exit 1
    fi

elif [ "$answer" = "no" ] || [ "$answer" = "n" ]; then
    # Code to execute if user answers no
    echo "You chose not to proceed."

else
    # Inform the user if the response is not recognized
    echo "Invalid response. Interpreting as 'no'"
fi

echo "Do you want to install oh-my-zsh? (recommended) (yes/no)"
read answer

# Convert the answer to lowercase to simplify matching
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

# Check the user's answer
if [ "$answer" = "yes" ] || [ "$answer" = "y" ]; then
    # Code to execute if user answers yes
    echo "Installing oh-my-zsh"
    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

elif [ "$answer" = "no" ] || [ "$answer" = "n" ]; then
    # Code to execute if user answers no
    echo "You chose not to proceed."

else
    # Inform the user if the response is not recognized
    echo "Invalid response. Interpreting as 'no'"
fi
