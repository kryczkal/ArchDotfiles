#!/usr/bin/env bash
# Install swayidle and waylock.
# MODULE_DEPENDENCIES: 01-packages/paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.bash"

print_message "Installing swayidle and waylock..."
paru -S --noconfirm swayidle waylock
