#!/usr/bin/env bash
# Generate and configure a GPG key for GitHub.
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Ensuring gnupg is installed..."
paru -S --noconfirm gnupg

print_message "Generating GPG key..."
gpg --full-generate-key

key_id=$(gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | cut -d'/' -f2)
print_message "GPG Key ID: $key_id"

print_message "Exporting GPG key to ~/gpg_key.pub..."
gpg --armor --export "$key_id" >"$HOME/gpg_key.pub"
print_message "Your GPG key has been exported to $HOME/gpg_key.pub"

if prompt_yes_no "Do you want to configure Git to use this GPG key for signing commits?"; then
	git config --global user.signingkey "$key_id"
	git config --global commit.gpgsign true
	print_message "Git configured to sign commits using GPG key ID: $key_id"
else
	print_message "Git configuration skipped."
fi

key_contents=$(cat "$HOME/gpg_key.pub")
print_message "GPG key contents:"
print_message "$key_contents"
print_message "Please manually add your GPG public key to Github or other services."
