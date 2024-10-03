#!/bin/bash
set -e

function print_message {
    echo -e "\033[1;34m$1\033[0m\n"
}

print_message "Starting Nouveau Drivers Installation"

print_message "Checking for NVIDIA proprietary drivers..."
if pacman -Qs nvidia > /dev/null; then
    nvidia_packages=$(pacman -Qqs nvidia | awk '{print $1}')
    print_message "The following NVIDIA packages are installed: \n$nvidia_packages\ncheck if they are needed before proceeding."
    read -p "Do you want to continue with the Nouveau driver installation? (y/N): " continue_choice
    if [[ ! "$continue_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
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
read -p "Do you want to reboot now? (y/N): " reboot_choice
if [[ "$reboot_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    print_message "Rebooting now..."
    sudo reboot
else
    print_message "Please remember to reboot your system later to apply the changes."
fi
