#!/bin/bash
paru -S --noconfirm lemurs # paru can be replaced by any other AUR helper
sudo systemctl enable lemurs.service
mkdir -p /etc/lemurs/wayland/
echo "Lemurs will get a defualt entry for river"
echo "Press any key to continue"
read -n 1 -s -r
sudo mkdir -p /etc/lemurs/wayland
sudo cp ../river-lemurs-entry/river /etc/lemurs/wayland/
sudo chmod +x /etc/lemurs/wayland/river
systemctl enable lemurs
