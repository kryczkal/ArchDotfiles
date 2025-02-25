#!/usr/bin/env bash
# Repair system locale settings.
set -euo pipefail
IFS=$'\n\t'

# Must be run as root.
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

source "$(dirname "$0")/../lib/utils.bash"

print_message "Checking current locale settings..."
current_locale=$(locale | grep LANG)
echo "Current Locale: $current_locale"

print_message "Generating en_US.UTF-8 locale..."
sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen || print_error_message_and_exit "Failed to modify /etc/locale.gen"
sudo locale-gen || print_error_message_and_exit "Failed to generate en_US.UTF-8 locale"

print_message "Updating locale configuration..."
sudo bash -c 'cat > /etc/locale.conf' <<EOF
LANG=en_US.UTF-8
EOF

print_message "Updating system-wide locale settings..."
sudo bash -c 'cat > /etc/environment' <<EOF
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
EOF

print_message "Applying changes..."
source /etc/locale.conf || print_error_message_and_exit "Failed to source /etc/locale.conf"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

new_locale=$(locale | grep LANG)
echo "New Locale: $new_locale"

if [[ $new_locale == *"en_US.UTF-8"* ]]; then
  print_message "Locale successfully set to en_US.UTF-8"
else
  print_error_message_and_exit "Failed to set locale to en_US.UTF-8"
fi
