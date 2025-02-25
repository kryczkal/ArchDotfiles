#!/usr/bin/env bash
# Install xdg-desktop-portal and related packages.
# MODULE_DEPENDENCIES: install_paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing xdg-desktop-portal packages..."
paru -S --noconfirm xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-wlr
print_message "xdg-desktop-portal installation complete. Default configuration is provided via dotfiles."
