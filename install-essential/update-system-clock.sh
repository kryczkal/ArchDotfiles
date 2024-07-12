#!/bin/bash

# Check if run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

# Check for argument presence
if [ $# -eq 0 ]; then
  echo "Usage: $0 [Region/City]"
  exit 1
fi

# Set the specified time zone
echo "Setting time zone to $1..."
timedatectl set-timezone $1

# Enable NTP synchronization
echo "Enabling NTP synchronization..."
timedatectl set-ntp true

# Synchronize hardware clock with system clock
echo "Synchronizing hardware clock with system clock..."
hwclock --systohc

# Confirm operations
echo "Time zone set to: $(timedatectl | grep 'Time zone')"
echo "System clock synchronized: $(timedatectl | grep 'synchronized: yes')"
echo "Hardware clock set to: $(hwclock --show)"

echo "All time settings have been successfully updated."
