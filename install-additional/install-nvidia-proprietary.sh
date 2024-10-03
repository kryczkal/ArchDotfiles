#!/bin/bash
set -e

function print_message {
    echo -e "\033[1;34m$1\033[0m\n"
}

print_message "Starting NVIDIA Drivers Installation and Configuration for Wayland"
print_message "Updating system and installing NVIDIA drivers..."

sudo pacman -Syu --noconfirm nvidia nvidia-utils nvidia-settings

print_message "Enabling DRM Kernel Mode Setting (KMS) for NVIDIA..."
echo "options nvidia-drm modeset=1" | sudo tee /etc/modprobe.d/nvidia-drm.conf

print_message "Adding NVIDIA modules to initramfs..."
sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak
sudo sed -i '/^MODULES=/c\MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)' /etc/mkinitcpio.conf
sudo mkinitcpio -P

print_message "5. Updating bootloader with kernel parameters..."
read -p "Is /boot/grub/grub.cfg the bootloader configuration file? (y/N):" grub_choice
if [[ "$grub_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  read -p "Is GRUB the bootloader? (y/N): " bootloader_choice
  if [[ "$bootloader_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    bootloader_config_file=""
    read -p "Add nvidia-drm.modeset=1 to the kernel parameters in the bootloader configuration file manually"
  else
    read -p "Enter the bootloader configuration file path: " bootloader_config_file
  fi
else
    bootloader_config_file="/boot/grub/grub.cfg"
fi

if ! [[ -z "$bootloader_config_file" ]]; then
  sudo cp /etc/default/grub /etc/default/grub.bak
  sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia-drm.modeset=1"/' /etc/default/grub
  sudo grub-mkconfig -o /boot/grub/grub.cfg
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

