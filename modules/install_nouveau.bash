#!/usr/bin/env bash
# Install nouveau drivers.
# MODULE_DEPENDENCIES: install_paru
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

print_message "Starting Nouveau Drivers Installation"

print_message "Checking for NVIDIA proprietary drivers..."
if pacman -Qs nvidia > /dev/null; then
  nvidia_packages=$(pacman -Qqs nvidia | awk '{print $1}')
  print_message "The following NVIDIA packages are installed:\n$nvidia_packages\nCheck if they are needed before proceeding."
  if ! prompt_yes_no "Do you want to continue with the Nouveau driver installation?"; then
    print_message "Exiting..."
    exit 0
  fi
fi

print_message "Removing any blacklisting of the Nouveau driver..."
if [ -f /etc/modprobe.d/nouveau.conf ]; then
  sudo rm /etc/modprobe.d/nouveau.conf
fi
sudo find /etc/modprobe.d/ -type f -exec sudo sed -i '/blacklist nouveau/d' {} \;

print_message "Ensuring modesetting is enabled for Nouveau..."
echo "options nouveau modeset=1" | sudo tee /etc/modprobe.d/nouveau.conf

print_message "Regenerating initramfs..."
sudo mkinitcpio -P

print_message "Updating bootloader configuration..."
if grep -q "nouveau.modeset=0" /etc/default/grub; then
  sudo sed -i 's/ nouveau\.modeset=0//g' /etc/default/grub
fi
sudo grub-mkconfig -o /boot/grub/grub.cfg

print_message "Nouveau driver installation complete."
echo -e "It's recommended to reboot your system to apply the changes.\n"
if prompt_yes_no "Do you want to reboot now?"; then
  print_message "Rebooting now..."
  sudo reboot
else
  print_message "Please remember to reboot your system later to apply the changes."
fi
