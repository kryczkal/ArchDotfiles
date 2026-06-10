#!/usr/bin/env bash
# Link dotfiles using GNU Stow, based on the active profile.
# MODULE_DEPENDENCIES: 99-finalize/stow-install
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.bash"

DOTFILES_DIR="$(dirname "${BASH_SOURCE[0]}")/../../dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
	print_error_message_and_exit "Dotfiles directory not found at $DOTFILES_DIR"
fi

cd "$DOTFILES_DIR" || exit 1

# Repo wins on conflicts: existing real files are moved to *.pre-stow first
# (never --adopt, which silently absorbs machine files into the repo).
stow_package() {
	local package="$1"
	backup_stow_conflicts "$package"
	stow -t "$HOME" "$package"
}

# Always stow common
print_message "Linking common dotfiles..."
stow_package common

# Determine device type from profile name or ask
PROFILE="${DOTFILES_PROFILE:-}"

if [[ "$PROFILE" == *"laptop"* ]]; then
	print_message "Linking laptop dotfiles..."
	stow_package laptop
else
	print_message "Linking desktop dotfiles..."
	stow_package desktop
fi

# Determine GPU from profile name or ask
if [[ "$PROFILE" == *"nvidia"* ]]; then
	print_message "Linking NVIDIA overrides..."
	stow_package nvidia
else
	print_message "Linking default GPU config..."
	stow_package default-gpu
fi

print_message "Dotfiles linked successfully."
