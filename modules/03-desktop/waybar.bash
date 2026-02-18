#!/usr/bin/env bash
# Install Waybar and required fonts.
# MODULE_DEPENDENCIES: 01-packages/paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.bash"

print_message "Installing Waybar and fonts..."
paru -S --noconfirm waybar otf-font-awesome ttf-hack-nerd
