#!/usr/bin/env bash
# Install clipboard utilities.
# MODULE_DEPENDENCIES: install_paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing wl-clipboard..."
paru -S --noconfirm wl-clipboard
print_message "Clipboard utility installation complete."
