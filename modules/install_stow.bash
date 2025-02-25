#!/usr/bin/env bash
# install_stow.bash - Install GNU Stow.
# MODULE_DEPENDENCIES: install_paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing stow..."
paru -S --noconfirm stow
print_message "Stow installation complete."
