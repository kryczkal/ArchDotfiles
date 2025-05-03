#!/usr/bin/env bash
# Install Apple fonts and additional fonts.
# MODULE_DEPENDENCIES: install_paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing fontconfig and fonts..."
paru -S --noconfirm fontconfig apple-fonts ttf-meslo-nerd noto-fonts noto-fonts-cjk
fc-cache -f
print_message "Fonts installed and cache updated."
