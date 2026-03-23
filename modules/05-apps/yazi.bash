#!/usr/bin/env bash
# Install Yazi file manager.
# MODULE_DEPENDENCIES: 01-packages/paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.bash"

print_message "Installing Yazi..."
paru -S --noconfirm yazi
