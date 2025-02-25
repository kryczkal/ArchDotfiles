#!/usr/bin/env bash
# Install screenshot utilities.
# MODULE_DEPENDENCIES: install_paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing screenshot utilities..."
paru -S --noconfirm grim slurp wl-clipboard
