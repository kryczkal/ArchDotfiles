#!/bin/bash
paru -S --noconfirm fontconfig
paru -S --noconfirm apple-fonts
paru -S --noconfirm ttf-meslo-nerd
paru -S --noconfirm noto-fonts
fc-cache -f
