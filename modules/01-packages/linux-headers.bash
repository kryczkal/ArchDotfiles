#!/usr/bin/env bash
# Install Linux headers.
# MODULE_DEPENDENCIES: 01-packages/paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.bash"

print_message "Installing linux-headers..."
sudo pacman -S --noconfirm linux-headers
print_message "Linux headers installation complete."
