#!/bin/bash
paru -S xdg-utils-handlr
paru -S handlr
paru -S evince

handlr set .pdf org.gnome.Evince.desktop
handlr set .epub org.gnome.Evince.desktop

handlr set text/* nvim.desktop
handlr set .txt nvim.desktop
handlr set .sh nvim.desktop
handlr set .py nvim.desktop
handlr set .c nvim.desktop
handlr set .md nvim.desktop

handlr set inode/directory org.gnome.Nautilus.desktop


