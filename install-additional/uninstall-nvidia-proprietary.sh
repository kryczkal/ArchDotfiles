#!/bin/bash
set -e

function print_message {
    echo -e "\033[1;34m$1\033[0m\n"
}

print_message "Starting NVIDIA Drivers Uninstallation"

print_message "Removing NVIDIA drivers and utilities..."
sudo pacman -Rns --noconfirm nvidia nvidia-utils nvidia-settings

print_message "Removing GBM_BACKEND and __GLX_VENDOR_LIBRARY_NAME from environment variables..."
ENV_FILE="/etc/environment"
if grep -q '^GBM_BACKEND=nvidia-drm' "$ENV_FILE"; then
    sudo sed -i '/^GBM_BACKEND=nvidia-drm/d' "$ENV_FILE"
fi
if grep -q '^__GLX_VENDOR_LIBRARY_NAME=nvidia' "$ENV_FILE"; then
    sudo sed -i '/^__GLX_VENDOR_LIBRARY_NAME=nvidia/d' "$ENV_FILE"
fi
if grep -q '^LIBVA_DRIVER_NAME=nvidia' "$ENV_FILE"; then
    sudo sed -i '/^LIBVA_DRIVER_NAME=nvidia/d' "$ENV_FILE"
fi


print_message "Processing mkinitcpio configuration..."
if [ -f /etc/mkinitcpio.conf.bak ]; then
    read -p "Backup of mkinitcpio.conf found. Do you want to restore it? (y/N): " mkinitcpio_backup_choice
    if [[ "$mkinitcpio_backup_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        sudo mv /etc/mkinitcpio.conf.bak /etc/mkinitcpio.conf
    else
        print_message "Not restoring backup. Removing NVIDIA modules from mkinitcpio.conf..."
        sudo sed -i 's/\<nvidia\>//g; s/\<nvidia_modeset\>//g; s/\<nvidia_uvm\>//g; s/\<nvidia_drm\>//g' /etc/mkinitcpio.conf
        sudo sed -i '/^HOOKS=/ s/\<kms\>\|\<kms\>//g; s/^HOOKS=/HOOKS="kms /' /etc/mkinitcpio.conf
    fi
else
    print_message "No backup of mkinitcpio.conf found. Removing NVIDIA modules from mkinitcpio.conf..."
    sudo sed -i 's/\<nvidia\>//g; s/\<nvidia_modeset\>//g; s/\<nvidia_uvm\>//g; s/\<nvidia_drm\>//g' /etc/mkinitcpio.conf
    sudo sed -i '/^HOOKS=/ s/\<kms\>\|\<kms\>//g; s/^HOOKS=/HOOKS="kms /' /etc/mkinitcpio.conf
fi

print_message "Regenerating initramfs..."
sudo mkinitcpio -P

print_message "Deleting nvidia.hook..."
sudo rm -f /etc/pacman.d/hooks/nvidia.hook

print_message "Processing bootloader configuration..."
if [ -f /etc/default/grub.bak ]; then
    read -p "Backup of /etc/default/grub found. Do you want to restore it? (y/N): " grub_backup_choice
    if [[ "$grub_backup_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        sudo mv /etc/default/grub.bak /etc/default/grub
    else
        print_message "Not restoring backup. Removing NVIDIA kernel parameters from /etc/default/grub..."
        sudo sed -i 's/ nvidia-drm\.modeset=1//g; s/ nvidia_drm\.fbdev=1//g' /etc/default/grub
    fi
else
    print_message "No backup of /etc/default/grub found. Removing NVIDIA kernel parameters from /etc/default/grub..."
    sudo sed -i 's/ nvidia-drm\.modeset=1//g; s/ nvidia_drm\.fbdev=1//g' /etc/default/grub
fi

sudo grub-mkconfig -o /boot/grub/grub.cfg

print_message "Uninstallation complete."
echo -e "It's recommended to reboot your system to apply the changes.\n"
read -p "Do you want to reboot now? (y/N): " reboot_choice
if [[ "$reboot_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    print_message "Rebooting now..."
    sudo reboot
else
    print_message "Please remember to reboot your system later to apply the changes."
fi
