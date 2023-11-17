#!/bin/bash

# Update the system
echo "Updating system..."
sudo pacman -Syu

# Install Nouveau (mesa package)
echo "Installing Nouveau driver..."
sudo pacman -S mesa xf86-video-nouveau

echo "Nouveau driver installation complete."

