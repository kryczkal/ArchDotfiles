#!/bin/bash
# Ensure script is run as a normal user and not root
if [ "$(id -u)" -eq 0 ]; then
    echo "This script should not be run as root. Please run as a normal user."
    exit 1
fi
# Install necessary dependencies for building packages
echo "Installing necessary base-devel group and git..."
sudo pacman -S --noconfirm --needed base-devel git

# Create a directory for packages if it doesn't exist
mkdir -p installed-packages
cd installed-packages

# Clone the paru PKGBUILD from the AUR
echo "Cloning paru from AUR..."
git clone https://aur.archlinux.org/paru.git

# Change to the paru directory
cd paru

# Build and install paru
echo "Building and installing paru..."
makepkg -si

# Return to the original directory
cd ..

echo "paru installation complete."

echo "Configuring paru"
echo "Do you want to enable color in pacman and paru? (yes/no)"
read answer

# Convert the answer to lowercase to simplify matching
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

# Check the user's answer
if [ "$answer" = "yes" ] || [ "$answer" = "y" ]; then
    # Code to execute if user answers yes
    # Define the path to the pacman.conf file
    PACMAN_CONF="/etc/pacman.conf"

    # Backup the existing pacman.conf file
    sudo cp "$PACMAN_CONF" "$PACMAN_CONF.backup"

    # Uncomment the "Color" line using sed
    sudo sed -i '/^#Color/s/^#//' "$PACMAN_CONF"

    echo "Color has been enabled in $PACMAN_CONF."

elif [ "$answer" = "no" ] || [ "$answer" = "n" ]; then
    # Code to execute if user answers no
    echo "You chose not to proceed."

else
    # Inform the user if the response is not recognized
    echo "Invalid response. Interpreting as 'no'"
fi
echo "Do you want to enable parallel downloading in pacman and paru? (yes/no)"
read answer
# Check the user's answer
if [ "$answer" = "yes" ] || [ "$answer" = "y" ]; then
    # Code to execute if user answers yes
    # Define the path to the pacman.conf file
    PACMAN_CONF="/etc/pacman.conf"

    # Backup the existing pacman.conf file
    sudo cp "$PACMAN_CONF" "$PACMAN_CONF.backup"

    # Uncomment the "Color" line using sed
    sudo sed -i '/^#ParallelDownloads/s/^#//' "$PACMAN_CONF"

    echo "Color has been enabled in $PACMAN_CONF."

elif [ "$answer" = "no" ] || [ "$answer" = "n" ]; then
    # Code to execute if user answers no
    echo "You chose not to proceed."

else
    # Inform the user if the response is not recognized
    echo "Invalid response. Interpreting as 'no'"
fi

echo "Do you want to enable BottomUp paru querries (recommended) (yes/no)"
read answer

# Convert the answer to lowercase to simplify matching
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

# Check the user's answer
if [ "$answer" = "yes" ] || [ "$answer" = "y" ]; then
    # Code to execute if user answers yes
    # Define the path to the pacman.conf file
    PARU_CONF="/etc/paru.conf"

    # Backup the existing pacman.conf file
    sudo cp "$PARU_CONF" "$PARU_CONF.backup"

    # Uncomment the "Color" line using sed
    sudo sed -i '/^#BottomUp/s/^#//' "$PARU_CONF"

    echo "BottomUp has been enabled in $PARU_CONF."

elif [ "$answer" = "no" ] || [ "$answer" = "n" ]; then
    # Code to execute if user answers no
    echo "You chose not to proceed."

else
    # Inform the user if the response is not recognized
    echo "Invalid response. Interpreting as 'no'"
fi
