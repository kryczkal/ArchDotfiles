#!/usr/bin/env bash
# Install OBS Studio and related tools.
# MODULE_DEPENDENCIES: 01-packages/paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.bash"

print_message "Installing OBS Studio and related packages..."
paru -S --noconfirm obs-studio wf-recorder
