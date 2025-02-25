#!/usr/bin/env bash
# Install notification daemon packages.
# MODULE_DEPENDENCIES: install_paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing notification daemon packages..."
paru -S --noconfirm libnotify mako
