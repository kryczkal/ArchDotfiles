#!/bin/bash

# Function to display error messages and exit
function error_exit {
    echo "$1" >&2
    exit 1
}

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    error_exit "This script must be run as root"
fi

echo "Checking current locale settings..."
current_locale=$(locale | grep LANG)
echo "Current Locale: $current_locale"

echo "Generating en_US.UTF-8 locale..."
sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen || error_exit "Failed to modify /etc/locale.gen"
sudo locale-gen || error_exit "Failed to generate en_US.UTF-8 locale"

echo "Updating locale configuration..."
sudo bash -c 'cat > /etc/locale.conf' <<EOF
LANG=en_US.UTF-8
EOF

echo "Updating system-wide locale settings..."
sudo bash -c 'cat > /etc/environment' <<EOF
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
EOF

echo "Applying changes..."
source /etc/locale.conf || error_exit "Failed to source /etc/locale.conf"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "Verifying new locale settings..."
new_locale=$(locale | grep LANG)
echo "New Locale: $new_locale"

if [[ $new_locale == *"en_US.UTF-8"* ]]; then
    echo "Locale successfully set to en_US.UTF-8"
else
    error_exit "Failed to set locale to en_US.UTF-8"
fi

