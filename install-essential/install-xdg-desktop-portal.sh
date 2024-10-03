#!/bin/bash

# Install necessary packages
paru -S --noconfirm xdg-desktop-portal
paru -S --noconfirm xdg-desktop-portal-gtk
paru -S --noconfirm xdg-desktop-portal-wlr

echo "Default configuration for xdg-desktop-portal is in the dotfiles folder and will be automatically set if the dotfiles are deployed using stow (./linker.sh)."

