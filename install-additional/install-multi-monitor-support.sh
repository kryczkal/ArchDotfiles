#!/bin/bash
echo "Installing dependencies for the repository..."
paru -S --noconfirm wlay-git kanshi
echo "Creating empty kanshi config"
mkdir -p ~/.config/kanshi
touch ~/.config/kanshi/config
echo "Update the ~/.config/kanshi/config with wlay"
echo "If you want kanshi to run on startup of graphical environment, add 'kanshi &' to your startup script"
echo "!!! When updating config with wlay, set config type to kanshi and path to /home/$(whoami)/.config/kanshi/config !!!"
echo "'config' is the configuration that will be run on startup (default one), custom ones can be made but require 'kanshi -c [path/to/custom/config]'"
