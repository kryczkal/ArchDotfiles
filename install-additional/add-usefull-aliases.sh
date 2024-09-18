#!/bin/env bash

set -e

function print_message {
    echo -e "\n\033[1;34m$1\033[0m\n"
}

aliases=(
    'alias .='"'"'alacritty --working-directory=$(pwd) & disown'"'"''
)

files=("$HOME/.bashrc" "$HOME/.zshrc")

for alias in "${aliases[@]}"; do
    print_message "Processing alias: $alias"

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            # Check if alias already exists in the file
            if grep -Fq "$alias" "$file"; then
                echo "Alias already exists in $file"
            else
                echo "$alias" >> "$file"
                echo "Alias added to $file"
            fi
        else
            echo "$file does not exist, skipping"
        fi
    done
done
