#!/usr/bin/env bash
# Update system time settings.
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

# Must be run as root.
if [ "$(id -u)" -ne 0 ]; then
	print_error_message_and_exit "This script must be run as root."
fi

if [ $# -eq 0 ]; then
	print_error_message_and_exit "Usage: $0 <Region/City>"
fi

timezone="$1"
print_message "Setting time zone to $timezone..."
timedatectl set-timezone "$timezone"

print_message "Enabling NTP synchronization..."
timedatectl set-ntp true

print_message "Synchronizing hardware clock with system clock..."
hwclock --systohc

print_message "Time settings updated:"
echo "Time zone: $(timedatectl | grep 'Time zone')"
echo "NTP enabled: $(timedatectl | grep 'synchronized: yes')"
echo "Hardware clock: $(hwclock --show)"
