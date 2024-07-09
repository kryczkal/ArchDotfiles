#!/bin/bash
paru -S --noconfirm xdg-desktop-portal
paru -S --noconfirm xdg-desktop-portal-gtk
paru -S --noconfirm xdg-desktop-portal-wlr

prompt_user() {
    while true; do
        read -p "Do you want to configure xdg-desktop-portal to use GTK backend by default and fallback to WLR? (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}


if prompt_user; then
    # Define the configuration file path
    CONFIG_DIR="$HOME/.config/xdg-desktop-portal"
    CONFIG_FILE="$CONFIG_DIR/portals.conf"

    # Ensure the directory exists
    mkdir -p "$CONFIG_DIR"

    # Define the desired configuration
    CONFIG_CONTENT="[preferred]\nbackends=gtk;wlr"
    # Check if the file already exists
    if [ -f "$CONFIG_FILE" ]; then
        # Check if the required configuration is already present
        if grep -q "backends=gtk;wlr" "$CONFIG_FILE"; then
            echo "Configuration already present in $CONFIG_FILE"
        else
            echo -e "\n$CONFIG_CONTENT" >> "$CONFIG_FILE"
            echo "Configuration appended to $CONFIG_FILE"
        fi
    else
        # Create the file with the required configuration
        echo -e "$CONFIG_CONTENT" > "$CONFIG_FILE"
        echo "Configuration written to $CONFIG_FILE"
    fi

    echo "Done!"
else
    echo "Configuration aborted by the user."
fi
