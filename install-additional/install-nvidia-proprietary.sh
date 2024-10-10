#!/bin/bash
set -e

function print_message {
    echo -e "\033[1;34m$1\033[0m\n"
}

print_message "Starting NVIDIA Drivers Installation and Configuration for Wayland"
print_message "Updating system and installing NVIDIA drivers..."

sudo pacman -Syu --noconfirm nvidia nvidia-utils nvidia-settings

print_message "Adding GBM_BACKEND and __GLX_VENDOR_LIBRARY_NAME to environment variables..."
ENV_FILE="/etc/environment"
if ! grep -q '^GBM_BACKEND=nvidia-drm' "$ENV_FILE"; then
    echo "GBM_BACKEND=nvidia-drm" | sudo tee -a "$ENV_FILE"
fi
if ! grep -q '^__GLX_VENDOR_LIBRARY_NAME=nvidia' "$ENV_FILE"; then
    echo "__GLX_VENDOR_LIBRARY_NAME=nvidia" | sudo tee -a "$ENV_FILE"
fi
if ! grep -q '^LIBVA_DRIVER_NAME=nvidia' "$ENV_FILE"; then
    echo "LIBVA_DRIVER_NAME=nvidia" | sudo tee -a "$ENV_FILE"
fi

print_message "Removing KMS from HOOKS in initramfs and creating backup of mkinitcpio.conf"
sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak
sudo sed -i '/^HOOKS=/ s/\<kms\>//g' /etc/mkinitcpio.conf

print_message "Adding NVIDIA modules to initramfs..."
sudo sed -i '/^MODULES=/c\MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)' /etc/mkinitcpio.conf
sudo mkinitcpio -P

print_message "Adding a pacman hook that updates initramfs after an NVIDIA driver update..."
HOOK_FILE="/etc/pacman.d/hooks/nvidia.hook"
sudo mkdir -p /etc/pacman.d/hooks
sudo tee "$HOOK_FILE" > /dev/null <<EOF
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
# Uncomment the installed NVIDIA package
Target=nvidia
#Target=nvidia-open
#Target=nvidia-lts
# If running a different kernel, modify below to match
Target=linux

[Action]
Description=Updating NVIDIA module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case \$trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF

print_message "Updating bootloader with kernel parameters..."
read -p "Is /boot/grub/grub.cfg the bootloader configuration file? (y/N): " grub_choice

if [[ "$grub_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  read -p "Is GRUB the bootloader? (y/N): " bootloader_choice
  if [[ "$bootloader_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    bootloader_config_file="/boot/grub/grub.cfg"
  else
    read -p "Enter the bootloader configuration file path: " bootloader_config_file
  fi
else
  bootloader_config_file=""
  read -p "Add nvidia-drm.modeset=1 to the kernel parameters in the bootloader configuration file manually"
fi

if [[ -n "$bootloader_config_file" ]]; then
  sudo cp /etc/default/grub /etc/default/grub.bak
  if ! grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia-drm.modeset=1"/' /etc/default/grub
  fi

  if ! grep -q "nvidia_drm.fbdev=1" /etc/default/grub; then
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia_drm.fbdev=1"/' /etc/default/grub
  fi

  sudo grub-mkconfig -o "$bootloader_config_file"
fi

print_message "Installation and configuration complete."

echo -e "It's recommended to reboot your system to apply the changes.\n"
read -p "Do you want to reboot now? (y/N): " reboot_choice
if [[ "$reboot_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    print_message "Rebooting now..."
    sudo reboot
else
    print_message "Please remember to reboot your system later to apply the changes."
fi

