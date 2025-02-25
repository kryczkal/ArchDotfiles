#!/usr/bin/env bash
# Install the Paru AUR helper.
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing base-devel, git, and cargo..."
sudo pacman -S --noconfirm --needed base-devel git cargo

print_message "Creating a temporary directory for building paru..."
tmp_dir=$(mktemp -d)

print_message "Cloning paru from AUR into $tmp_dir..."
git clone https://aur.archlinux.org/paru-git.git "$tmp_dir/paru-git"

cd "$tmp_dir/paru-git" || print_error_message_and_exit "Cannot change into paru-git directory."
print_message "Building and installing paru..."
makepkg -si --noconfirm

print_message "Cleaning up temporary directory..."
rm -rf "$tmp_dir"

print_message "Paru installation complete."
