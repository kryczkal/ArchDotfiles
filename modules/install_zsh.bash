#!/usr/bin/env bash
# Install Zsh, set as default shell, and optionally install oh-my-zsh.
# MODULE_DEPENDENCIES: install_paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing Zsh..."
paru -S --noconfirm zsh

read -p "Do you want to set Zsh as the default shell for $(whoami)? (yes/no): " answer
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
if [[ "$answer" =~ ^(yes|y)$ ]]; then
  ZSH_SHELL=$(which zsh)
  if chsh -s "$ZSH_SHELL"; then
    print_message "Default shell changed to Zsh. It will take effect at next login."
  else
    print_error_message_and_exit "Failed to change default shell."
  fi
else
  print_message "Skipping default shell change."
fi

read -p "Do you want to install oh-my-zsh? (yes/no): " answer
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
if [[ "$answer" =~ ^(yes|y)$ ]]; then
  paru -S --noconfirm wget
  print_message "Installing oh-my-zsh..."
  sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
else
  print_message "Skipping oh-my-zsh installation."
fi
