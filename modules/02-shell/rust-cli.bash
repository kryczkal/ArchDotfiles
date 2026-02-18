#!/usr/bin/env bash
# Install Rust CLI utilities and update shell configuration.
# MODULE_DEPENDENCIES: 01-packages/paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.bash"

print_message "Installing Rust CLI utilities..."
paru -S --noconfirm bat lsd procs hexyl xplr fd bottom

# Aliases and env vars (MANPAGER, etc.) are managed via stow:
#   dotfiles/common/.config/shell/aliases.sh
#   dotfiles/common/.config/shell/env.sh
print_message "Rust CLI utilities installed. Shell config is managed via stow."

