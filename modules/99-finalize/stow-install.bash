#!/usr/bin/env bash
# install_stow.bash - Install GNU Stow.
# MODULE_DEPENDENCIES: 01-packages/paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.bash"

print_message "Installing stow..."
paru -S --noconfirm stow
print_message "Stow installation complete."
