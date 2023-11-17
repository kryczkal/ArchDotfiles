#!/bin/bash
paru -S --noconfirm zsh
echo "Installing oh-my-zsh"
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
echo "Installing powerlevel10k"
mkdir -p installed-packages
cd installed-packages
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Define the path to the .zshrc file
ZSHRC_FILE="$HOME/.zshrc"

# Define the new theme string
NEW_THEME="powerlevel10k/powerlevel10k"

# Backup the existing .zshrc file
cp "$ZSHRC_FILE" "$ZSHRC_FILE.backup"

# Use sed to find the ZSH_THEME= line and replace its value
sed -i "/^ZSH_THEME=/c\ZSH_THEME=\"$NEW_THEME\"" "$ZSHRC_FILE"

echo "ZSH_THEME has been updated to $NEW_THEME in $ZSHRC_FILE."

