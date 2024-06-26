#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Update the system
echo "Updating the system..."
pacman -Syu --noconfirm

# Install the Nouveau driver and other required packages
echo "Installing Nouveau driver and required packages..."
pacman -S --noconfirm xf86-video-nouveau libva-vdpau-driver vdpauinfo mesa libva-mesa-driver libvdpau-va-gl

# Install Wayland and related packages
echo "Installing Wayland and related packages..."
pacman -S --noconfirm wayland wayland-protocols

# Install additional packages
echo "Installing additional necessary packages..."
pacman -S --noconfirm vulkan-intel vulkan-tools


# VDPAU environment variables for Wayland
echo "Setting VDPAU environment variables for Wayland..."
cat << EOF > /etc/environment
VDPAU_DRIVER=nouveau
LIBVA_DRIVER_NAME=nouveau
GBM_BACKEND=nouveau
MESA_LOADER_DRIVER_OVERRIDE=nouveau
EOF

# Print completion message
echo "Environment variables set. Please reboot your system."


# Ensure the user is part of the video group
echo "Adding user $(logname) to the video group..."
usermod -aG video $(logname)

echo "Configuration complete."
echo "Please log out and log back in to apply the VDPAU environment variables."

exit 0

