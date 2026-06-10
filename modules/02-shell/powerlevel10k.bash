#!/usr/bin/env bash
# Install and configure powerlevel10k for Zsh.
# MODULE_DEPENDENCIES: 01-packages/paru 02-shell/zsh
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.bash"

print_message "Installing powerlevel10k..."
mkdir -p "$HOME/installed-packages"
cd "$HOME/installed-packages" || print_error_message_and_exit "Cannot change directory."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
cd - >/dev/null

# ZSH_THEME is set in the repo-managed .zshrc (stowed by 99-finalize/stow);
# nothing to edit here.
print_message "powerlevel10k installed. The stowed .zshrc already selects the theme."
