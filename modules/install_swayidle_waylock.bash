#!/usr/bin/env bash
# Install swayidle and waylock.
# MODULE_DEPENDENCIES: install_paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing swayidle and waylock..."
paru -S --noconfirm swayidle waylock
