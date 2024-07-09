#!/bin/bash

# This script sets up a GPG key for use with GitHub

# Ensure gnupg is installed
paru -S gnupg --noconfirm

gpg --full-generate-key

# Extracting and displaying the GPG key ID
key_id=$(gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | cut -d'/' -f2)
echo "GPG Key ID: $key_id"

# Exporting the GPG key to a file
gpg --armor --export $key_id > ~/gpg_key.pub
echo "Your GPG key has been exported to ~/gpg_key.pub"

echo "Do you want to configure Git to use this GPG key for signing commits? (yes/no)"
read use_git

if [[ $use_git == "yes" ]]; then
    git config --global user.signingkey $key_id
    git config --global commit.gpgsign true
    echo "Git configured to sign commits using GPG key ID: $key_id"
else
    echo "Git configuration skipped."
fi

echo "Please manually add your GPG public key from ~/gpg_key.pub to GitHub."
