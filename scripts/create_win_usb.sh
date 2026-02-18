#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)."
  exit 1
fi

# Usage check
if [ "$#" -lt 2 ]; then
    echo "Usage: sudo ./create_win_usb.sh <windows.iso> <device> [optional_drivers_path]"
    echo "Example 1: sudo ./create_win_usb.sh win10.iso /dev/sdb"
    echo "Example 2: sudo ./create_win_usb.sh win10.iso /dev/sdb /home/user/downloads/rst_drivers/"
    echo "Example 3: sudo ./create_win_usb.sh win10.iso /dev/sdb /usr/share/virtio/virtio-win.iso"
    exit 1
fi

ISO_PATH="$1"
USB_DEVICE="$2"
DRIVER_SOURCE="$3"

MOUNT_ISO="/mnt/win_iso_temp"
MOUNT_USB="/mnt/win_usb_temp"
MOUNT_DRIVERS="/mnt/win_drivers_temp"

# Safety Warning
echo "WARNING: THIS WILL WIPE ALL DATA ON $USB_DEVICE"
echo "Target ISO: $ISO_PATH"
echo "Target Drive: $USB_DEVICE"
if [ -n "$DRIVER_SOURCE" ]; then
    echo "Drivers Source: $DRIVER_SOURCE"
fi

read -p "Are you sure you want to continue? (Type 'yes' to confirm): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborting."
    exit 1
fi

# 1. Unmount existing
echo "[1/7] Unmounting existing partitions..."
umount ${USB_DEVICE}* 2>/dev/null

# 2. Partitioning and Formatting
echo "[2/7] Partitioning and formatting (GPT/FAT32)..."
parted --script "$USB_DEVICE" mklabel gpt mkpart primary fat32 1MiB 100% set 1 esp on
partprobe "$USB_DEVICE"
sleep 2
mkfs.fat -F32 "${USB_DEVICE}1" > /dev/null

# 3. Mounting
echo "[3/7] Mounting drives..."
mkdir -p "$MOUNT_ISO"
mkdir -p "$MOUNT_USB"
mount -o loop "$ISO_PATH" "$MOUNT_ISO"
mount "${USB_DEVICE}1" "$MOUNT_USB"

# 4. Copying Windows Files
echo "[4/7] Copying Windows files (excluding install.wim)..."
rsync -a --info=progress2 --exclude='sources/install.wim' "$MOUNT_ISO/" "$MOUNT_USB/"
mkdir -p "$MOUNT_USB/sources"

# 5. Splitting install.wim
if [ -f "$MOUNT_ISO/sources/install.wim" ]; then
    echo "[5/7] Splitting install.wim..."
    wimlib-imagex split "$MOUNT_ISO/sources/install.wim" "$MOUNT_USB/sources/install.swm" 4000
elif [ -f "$MOUNT_ISO/sources/install.esd" ]; then
    echo "[5/7] Splitting install.esd..."
    wimlib-imagex split "$MOUNT_ISO/sources/install.esd" "$MOUNT_USB/sources/install.swm" 4000
fi

# 6. Copying Drivers (New Step)
if [ -n "$DRIVER_SOURCE" ]; then
    echo "[6/7] Processing drivers..."
    mkdir -p "$MOUNT_USB/drivers"
    
    if [ -d "$DRIVER_SOURCE" ]; then
        # If source is a folder
        echo "Copying driver folder..."
        cp -r "$DRIVER_SOURCE/"* "$MOUNT_USB/drivers/"
    elif [ -f "$DRIVER_SOURCE" ] && [[ "$DRIVER_SOURCE" == *.iso ]]; then
        # If source is an ISO (e.g., virtio)
        echo "Mounting and extracting driver ISO..."
        mkdir -p "$MOUNT_DRIVERS"
        mount -o loop "$DRIVER_SOURCE" "$MOUNT_DRIVERS"
        cp -r "$MOUNT_DRIVERS/"* "$MOUNT_USB/drivers/"
        umount "$MOUNT_DRIVERS"
        rmdir "$MOUNT_DRIVERS"
    else
        echo "Warning: Driver path is invalid or file type not supported. Skipping drivers."
    fi
else
    echo "[6/7] No drivers specified, skipping."
fi

# 7. Cleanup
echo "[7/7] Cleaning up..."
sync
umount "$MOUNT_USB"
umount "$MOUNT_ISO"
rmdir "$MOUNT_ISO"
rmdir "$MOUNT_USB"

echo "Success! Drivers are located in the 'drivers' folder on the USB."
