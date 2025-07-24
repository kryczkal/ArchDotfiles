#!/usr/bin/env bash
# Generate an SSH key for GitHub.
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Ensuring openssh is installed..."
sudo pacman -S --noconfirm openssh

read -rp "Please enter your email address for the SSH key: " user_email
print_message "Generating SSH key..."
ssh-keygen -t ed25519 -C "$user_email"

print_message "Enabling SSH agent..."
eval "$(ssh-agent -s)"
ssh-add "$HOME/.ssh/id_ed25519"

print_message "Your SSH public key:"
cat "$HOME/.ssh/id_ed25519.pub"
print_message "Copy this key to your GitHub account."
print_message "After adding the key, you can safely delete the public key file if you wish. It can be regenerated at any time."
