#!/bin/bash
# Execute stow from inside the dotfiles directory
cd dotfiles

# Stow all packages in the .config directory
stow -t "$HOME/.config" .config 

# Then stow top-level dotfiles directly into the home directory
stow -t "$HOME" .

# Check for errors
if [ $? -eq 0 ]; then
    echo "Dotfiles are successfully stowed."
else
    echo "There was an error in stowing dotfiles."
fi

