#!/usr/bin/env bash
# Install Rust CLI utilities and update shell configuration.
# MODULE_DEPENDENCIES: install_paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing Rust CLI utilities..."
paru -S --noconfirm bat lsd procs hexyl xplr fd bottom

if prompt_yes_no "Do you want to update .zshrc for colored -h and --help?"; then
  ZSHRC_FILE="$HOME/.zshrc"
  PROFILE_FILE="$HOME/.profile"
  ZPROFILE_FILE="$HOME/.zprofile"

  ALIAS1="alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'"
  ALIAS2="alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'"
  EXPORT1='export MANPAGER="sh -c '\''col -bx | bat -l man -p'\''"'
  EXPORT2='export MANROFFOPT="-c"'

  append_line_to_file_if_not_exists "$ALIAS1" "$ZSHRC_FILE"
  append_line_to_file_if_not_exists "$ALIAS2" "$ZSHRC_FILE"
  append_line_to_file_if_not_exists "$EXPORT1" "$PROFILE_FILE"
  append_line_to_file_if_not_exists "$EXPORT2" "$PROFILE_FILE"
  append_line_to_file_if_not_exists "$EXPORT1" "$ZPROFILE_FILE"
  append_line_to_file_if_not_exists "$EXPORT2" "$ZPROFILE_FILE"

  print_message "Shell configuration updated. Changes will take effect after a reboot or re-sourcing."
else
  print_message "Skipped updating shell configuration."
fi
