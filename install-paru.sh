#!/bin/bash
# Ensure script is run as a normal user and not root
if [ "$(id -u)" -eq 0 ]; then
    echo "This script should not be run as root. Please run as a normal user."
    exit 1
fi
# Install necessary dependencies for building packages
echo "Installing necessary base-devel group and git..."
sudo pacman -S --needed base-devel git

# Create a directory for packages if it doesn't exist
mkdir -p downloaded-packages
cd downloaded-packages

# Clone the paru PKGBUILD from the AUR
echo "Cloning paru from AUR..."
git clone https://aur.archlinux.org/paru.git

# Change to the paru directory
cd paru

# Build and install paru
echo "Building and installing paru..."
makepkg -si

# Return to the original directory
cd ..

echo "paru installation complete."

