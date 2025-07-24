#!/usr/bin/env bash
# Install rofi and optionally an icon theme.
# MODULE_DEPENDENCIES: install_paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing rofi (Wayland)..."
paru -S --noconfirm rofi-wayland

read -rp "Do you also want to install an icon theme? (yes/no): " answer
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
if [[ "$answer" =~ ^(yes|y)$ ]]; then
	paru -S --noconfirm adwaita-icon-theme
	print_message "Icon theme installed."
else
	print_message "Icon theme installation skipped."
fi
