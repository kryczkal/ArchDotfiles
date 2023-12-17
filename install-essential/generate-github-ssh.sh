#!/bin/bash
echo "If not present, install openssh"
sudo pacman -S openssh

# Prompt the user for their email address
echo "Please enter your email address for the ssh key:"
read user_email

echo "Generate new key with provided email, use the default file path"
ssh-keygen -t ed25519 -C "$user_email"

# enable ssh agent
echo "Enabling SSH agent"
eval "$(ssh-agent -s)"

echo "Adding the file to ssh-keys"
ssh-add ~/.ssh/id_ed25519

echo "Printing the ssh-key for copying to GitHub"
cat ~/.ssh/id_ed25519.pub

