#!/usr/bin/env bash
# Install the Paru AUR helper, configure pacman/paru settings, and set up an alias.
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Installing necessary base-devel group, git, and cargo..."
sudo pacman -S --noconfirm --needed base-devel git cargo

print_message "Creating temporary directory for building packages..."
mkdir -p "$HOME/temporary-files"
cd "$HOME/temporary-files" || print_error_message_and_exit "Cannot change directory."

print_message "Cloning paru from AUR..."
git clone https://aur.archlinux.org/paru-git.git

cd paru-git || print_error_message_and_exit "Cannot enter paru-git directory."
print_message "Building and installing paru..."
makepkg -si --noconfirm

cd "$HOME" || exit
print_message "Paru installation complete."

print_message "Configuring paru..."

if prompt_yes_no "Do you want to enable color in pacman and paru? (recommended)"; then
    PACMAN_CONF="/etc/pacman.conf"
    print_message "Enabling color in $PACMAN_CONF..."
    sudo sed -i '/^#Color/s/^#//' "$PACMAN_CONF"
    echo "Color has been enabled in $PACMAN_CONF."
else
    echo "Skipping color configuration."
fi

if prompt_yes_no "Do you want to enable parallel downloading in pacman and paru? (recommended)"; then
    PACMAN_CONF="/etc/pacman.conf"
    print_message "Enabling parallel downloading in $PACMAN_CONF..."
    sudo sed -i '/^#ParallelDownloads/s/^#//' "$PACMAN_CONF"
    echo "Parallel downloading has been enabled in $PACMAN_CONF."
else
    echo "Skipping parallel downloading configuration."
fi

if prompt_yes_no "Do you want to enable BottomUp paru queries? (recommended)"; then
    PARU_CONF="/etc/paru.conf"
    print_message "Enabling BottomUp queries in $PARU_CONF..."
    sudo sed -i '/^#BottomUp/s/^#//' "$PARU_CONF"
    echo "BottomUp queries have been enabled in $PARU_CONF."
else
    echo "Skipping BottomUp queries configuration."
fi

if prompt_yes_no "Do you want colored paru output?"; then
    ALIAS="alias paru='paru --color=always'"
    print_message "Adding alias: $ALIAS"
    append_line_to_file_if_not_exists "$ALIAS" "$HOME/.bashrc"
    append_line_to_file_if_not_exists "$ALIAS" "$HOME/.zshrc"
    echo "Alias added. Please reload your shell configuration."
else
    echo "Skipping alias setup for paru."
fi

