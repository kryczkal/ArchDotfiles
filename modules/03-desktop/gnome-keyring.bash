#!/usr/bin/env bash
# Install gnome-keyring and configure PAM to unlock it on login.
# MODULE_DEPENDENCIES: 01-packages/paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.bash"

print_message "Installing gnome-keyring, libsecret, and seahorse..."
sudo pacman -S --noconfirm --needed gnome-keyring libsecret seahorse

PAM_FILE="/etc/pam.d/login"
if ! grep -q "pam_gnome_keyring.so" "$PAM_FILE"; then
    print_message "Configuring PAM for gnome-keyring in $PAM_FILE..."
    # Backup the PAM file
    if [ -f "$PAM_FILE" ] && [ ! -f "${PAM_FILE}.bak" ]; then
        sudo cp "$PAM_FILE" "${PAM_FILE}.bak"
        print_message "Backup created: ${PAM_FILE}.bak"
    fi
    # Insert 'auth' line after 'auth include system-local-login'
    sudo sed -i '/auth\s\+include\s\+system-local-login/a auth       optional     pam_gnome_keyring.so' "$PAM_FILE"
    # Insert 'session' line after 'session include system-local-login'
    sudo sed -i '/session\s\+include\s\+system-local-login/a session    optional     pam_gnome_keyring.so auto_start' "$PAM_FILE"
    print_message "PAM configuration updated."
else
    print_message "PAM configuration for gnome-keyring already exists."
fi

print_message "Gnome-keyring setup complete."
