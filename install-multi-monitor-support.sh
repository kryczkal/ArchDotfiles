#!/bin/bash
echo "Installing dependencies for the repository..."
paru -S --noconfirm wlay-git kanshi

echo "Creating empty kanshi config"
mkdir -p ~/.config/kanshi
touch ~/.config/kanshi/config
echo "Adding kanshi -c ~/.config/kanshi/default to .profile"
echo "kanshi -c ~/.config.kanshi/default" >> .profile
echo "!!! when updating config with wlay, set config type to kanshi and path to /home/$(whoami)/.config/kanshi/[your_config_name] !!!"
