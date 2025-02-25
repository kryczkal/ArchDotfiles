#!/usr/bin/env bash
# Install OBS Studio and related tools.
# MODULE_DEPENDENCIES: install_paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing OBS Studio and related packages..."
paru -S --noconfirm obs-studio wf-recorder
