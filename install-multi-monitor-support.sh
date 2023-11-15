#!/bin/bash

# Update the system and install dependencies
echo "Updating system..."
sudo pacman -Syu

echo "Installing dependencies for the repository..."
paru -S wlay-git kanshi

echo "Creating empty kanshi config"
mkdir -p ~/.config/kanshi
touch ~/.config/kanshi/config
echo "!!! when updating config with wlay, set config type to kanshi and path to /home/$(whoami)/.config/kanshi/[your_config_name] !!!"
