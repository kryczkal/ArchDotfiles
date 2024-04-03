#!/bin/bash
paru -S xdg-utils-handlr
paru -S handlr
paru -S evince
paru -S nautilus
paru -S neovim
paru -S alacritty
paru -S chromium

handlr set .pdf org.gnome.Evince.desktop
handlr set .epub org.gnome.Evince.desktop

handlr set text/* nvim.desktop
handlr set .txt nvim.desktop
handlr set .sh nvim.desktop
handlr set .py nvim.desktop
handlr set .c nvim.desktop
handlr set .md nvim.desktop

handlr set inode/directory org.gnome.Nautilus.desktop

handlr set x-scheme-handler/terminal Alacritty.desktop

handlr set x-scheme-handler/http chromium.desktop
handlr set x-scheme-handler/https chromium.desktop
