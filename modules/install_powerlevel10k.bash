#!/usr/bin/env bash
# Install and configure powerlevel10k for Zsh.
# MODULE_DEPENDENCIES: install_paru install_zsh
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing powerlevel10k..."
mkdir -p "$HOME/installed-packages"
cd "$HOME/installed-packages" || print_error_message_and_exit "Cannot change directory."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
cd - > /dev/null

ZSHRC_FILE="$HOME/.zshrc"
NEW_THEME="powerlevel10k/powerlevel10k"
try_backup_file "$ZSHRC_FILE"
sed -i "/^ZSH_THEME=/c\ZSH_THEME=\"$NEW_THEME\"" "$ZSHRC_FILE"

print_message "Updated ZSH_THEME to $NEW_THEME in $ZSHRC_FILE. Restart the terminal to run the configuration wizard."
