#!/usr/bin/env bash
# Install River window manager and optionally additional tools.
# MODULE_DEPENDENCIES: install_paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing River, Wayland, and wayland-protocols..."
sudo pacman -S --noconfirm river wayland wayland-protocols

print_message "Appending XDG_SESSION_TYPE=wayland to ~/.profile..."
append_line_to_file_if_not_exists "XDG_SESSION_TYPE=wayland" "$HOME/.profile"
print_message "River installation complete. Reboot if necessary."
