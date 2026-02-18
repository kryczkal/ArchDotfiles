#!/usr/bin/env bash
# Install packages needed for shell aliases (lsd, bat, etc.)
# Aliases themselves are managed via stow in dotfiles/common/.config/shell/aliases.sh
# MODULE_DEPENDENCIES: 02-shell/rust-cli
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.bash"

# The actual aliases are in dotfiles/common/.config/shell/aliases.sh
# and get symlinked by stow. Nothing to install here beyond what rust-cli provides.
print_message "Aliases are managed via stow (dotfiles/common/.config/shell/aliases.sh)"
print_message "Make sure your .zshrc/.bashrc sources ~/.config/shell/aliases.sh"
