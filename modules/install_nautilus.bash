#!/usr/bin/env bash
# Install Nautilus file manager.
# MODULE_DEPENDENCIES: install_paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing Nautilus..."
paru -S --noconfirm nautilus
