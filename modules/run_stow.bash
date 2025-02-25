#!/usr/bin/env bash
# Link dotfiles using GNU Stow.
# MODULE_DEPENDENCIES: install_stow
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

DOTFILES_DIR="$(dirname "$0")/../dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
  print_error_message_and_exit "Dotfiles directory not found at $DOTFILES_DIR"
fi

print_message "Linking common dotfiles..."
cd "$DOTFILES_DIR" || exit 1
stow -t "$HOME" common --adopt

while true; do
  read -p "Is your device a laptop (has battery/screen brightness)? (yes/no): " answer
  answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
  case $answer in
    yes|y)
      stow -t "$HOME" laptop
      break
      ;;
    no|n)
      stow -t "$HOME" desktop
      break
      ;;
    *)
      echo "Invalid response. Please enter 'yes' or 'no'."
      ;;
  esac
done

while true; do
  read -p "Do you want to enable NVIDIA overrides? (yes/no): " answer
  answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
  case $answer in
    yes|y)
      stow -t "$HOME" flags-nvidia
      break
      ;;
    no|n)
      stow -t "$HOME" flags-default
      break
      ;;
    *)
      echo "Invalid response. Please enter 'yes' or 'no'."
      ;;
  esac
done

print_message "Dotfiles linked successfully."
