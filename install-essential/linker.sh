#!/bin/bash
# Execute stow from inside the dotfiles directory
cd ../dotfiles
stow -t "$HOME" common --adopt

# Ask the user if their device is a laptop
while true; do
    read -p "Is your device a laptop (has battery/screen brightness) (yes/no)? " answer
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
    case $answer in
        yes|y)
            stow -t "$HOME" laptop
            break
            ;;
        no|n)
            stow -t "$HOME" desktop
            break
            ;;
        *)
            echo "Invalid response. Please enter 'yes' or 'no'."
            ;;
    esac
done

# Ask the user if they want to enable NVIDIA overrides
while true; do
    read -p "Do you want to enable NVIDIA overrides (yes/no)? " answer
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
    case $answer in
        yes|y)
            stow -t "$HOME" flags-nvidia
            break
            ;;
        no|n)
            stow -t "$HOME" flags-default
            break
            ;;
        *)
            echo "Invalid response. Please enter 'yes' or 'no'."
            ;;
    esac
done
