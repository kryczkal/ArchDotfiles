#!/usr/bin/env bash
# Uninstall NVIDIA proprietary drivers.
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Starting NVIDIA Drivers Uninstallation"

print_message "Removing NVIDIA drivers and utilities..."
sudo pacman -Rns --noconfirm nvidia nvidia-utils nvidia-settings

print_message "Removing GBM_BACKEND and __GLX_VENDOR_LIBRARY_NAME from environment variables..."
ENV_FILE="/etc/environment"
sudo sed -i '/^GBM_BACKEND=nvidia-drm/d' "$ENV_FILE"
sudo sed -i '/^__GLX_VENDOR_LIBRARY_NAME=nvidia/d' "$ENV_FILE"
sudo sed -i '/^LIBVA_DRIVER_NAME=nvidia/d' "$ENV_FILE"

print_message "Processing mkinitcpio configuration..."
if [ -f /etc/mkinitcpio.conf.bak ]; then
  if prompt_yes_no "Backup of mkinitcpio.conf found. Do you want to restore it?"; then
    sudo mv /etc/mkinitcpio.conf.bak /etc/mkinitcpio.conf
  else
    print_message "Not restoring backup. Removing NVIDIA modules from mkinitcpio.conf..."
    sudo sed -i 's/\<nvidia\>//g; s/\<nvidia_modeset\>//g; s/\<nvidia_uvm\>//g; s/\<nvidia_drm\>//g' /etc/mkinitcpio.conf
    sudo sed -i '/^HOOKS=/ s/\<kms\>\|\<kms\>//g; s/^HOOKS=/HOOKS="kms /' /etc/mkinitcpio.conf
  fi
else
  print_message "No backup found. Removing NVIDIA modules from mkinitcpio.conf..."
  sudo sed -i 's/\<nvidia\>//g; s/\<nvidia_modeset\>//g; s/\<nvidia_uvm\>//g; s/\<nvidia_drm\>//g' /etc/mkinitcpio.conf
  sudo sed -i '/^HOOKS=/ s/\<kms\>\|\<kms\>//g; s/^HOOKS=/HOOKS="kms /' /etc/mkinitcpio.conf
fi

print_message "Regenerating initramfs..."
sudo mkinitcpio -P

print_message "Deleting nvidia.hook..."
sudo rm -f /etc/pacman.d/hooks/nvidia.hook

print_message "Processing bootloader configuration..."
if [ -f /etc/default/grub.bak ]; then
  if prompt_yes_no "Backup of /etc/default/grub found. Do you want to restore it?"; then
    sudo mv /etc/default/grub.bak /etc/default/grub
  else
    print_message "Not restoring backup. Removing NVIDIA kernel parameters..."
    sudo sed -i 's/ nvidia-drm\.modeset=1//g; s/ nvidia_drm\.fbdev=1//g' /etc/default/grub
  fi
else
  print_message "No backup found. Removing NVIDIA kernel parameters..."
  sudo sed -i 's/ nvidia-drm\.modeset=1//g; s/ nvidia_drm\.fbdev=1//g' /etc/default/grub
fi

sudo grub-mkconfig -o /boot/grub/grub.cfg

print_message "Uninstallation complete."
echo -e "It's recommended to reboot your system to apply the changes.\n"
if prompt_yes_no "Do you want to reboot now?"; then
  print_message "Rebooting now..."
  sudo reboot
else
  print_message "Please remember to reboot later."
fi
