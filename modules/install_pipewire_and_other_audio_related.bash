#!/usr/bin/env bash
# Install Pipewire and sound utilities.
# MODULE_DEPENDENCIES: install_paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing Pipewire audio components..."
paru -S --noconfirm pipewire-audio wireplumber pipewire-alsa pipewire-jack pipewire-zeroconf

print_message "Installing PulseAudio replacement..."
paru -S --noconfirm pavucontrol pipewire-pulse

print_message "Sound utilities installed. Please reboot your system."
