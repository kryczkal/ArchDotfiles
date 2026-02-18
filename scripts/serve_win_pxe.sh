#!/bin/bash

# Default Configuration
DEFAULT_INTERFACE="eno1"
DEFAULT_ISO="/home/wookie/Downloads/Win10_22H2_English_x64v1.iso"
SERVER_IP="192.168.50.1"
DHCP_RANGE="192.168.50.100,192.168.50.150,12h"

# Work directories
WORK_DIR="/tmp/winpxe_work"
MOUNT_DIR="/tmp/winpxe_iso"

# --- Safety Checks ---
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root." 
   exit 1
fi

# --- Interactive Prompts ---
echo "--- Configuration ---"
read -p "Enter Network Interface [Default: $DEFAULT_INTERFACE]: " INTERFACE
INTERFACE=${INTERFACE:-$DEFAULT_INTERFACE}

read -p "Enter path to Windows ISO [Default: $DEFAULT_ISO]: " ISO_PATH
ISO_PATH=${ISO_PATH:-$DEFAULT_ISO}

if [[ ! -f "$ISO_PATH" ]]; then
    echo "Error: ISO file not found at $ISO_PATH"
    exit 1
fi

# --- Cleanup Trap ---
cleanup() {
    echo ""
    echo "--- Shutting down ---"
    
    # Kill background processes
    if [[ -n "$HTTP_PID" ]]; then kill $HTTP_PID 2>/dev/null; fi
    if [[ -n "$SMB_PID" ]]; then kill $SMB_PID 2>/dev/null; fi
    if [[ -n "$DNS_PID" ]]; then kill $DNS_PID 2>/dev/null; fi

    # Unmount ISO
    umount "$MOUNT_DIR" 2>/dev/null
    
    # Remove temp dirs
    rm -rf "$WORK_DIR"
    rm -rf "$MOUNT_DIR"

    # Flush IP address
    ip addr del "$SERVER_IP/24" dev "$INTERFACE" 2>/dev/null

    # Re-enable Network Manager
    echo "--- Re-connecting $INTERFACE to NetworkManager ---"
    nmcli device connect "$INTERFACE" 2>/dev/null
    
    echo "Cleanup complete."
}
trap cleanup EXIT

# --- Network Manager Disconnect ---
echo "--- Disconnecting $INTERFACE from NetworkManager ---"
nmcli device disconnect "$INTERFACE"

# --- Setup Directories ---
echo "--- Setting up directories ---"
mkdir -p "$WORK_DIR"
mkdir -p "$MOUNT_DIR"

# --- Mount ISO ---
echo "--- Mounting ISO ---"
# We use -f to fake mount if already mounted, or just proceed if not
mount -o loop,ro "$ISO_PATH" "$MOUNT_DIR" 2>/dev/null || echo "ISO might already be mounted, proceeding..."

# --- Network Setup ---
echo "--- Configuring Static IP on $INTERFACE ---"
ip link set "$INTERFACE" up
ip addr add "$SERVER_IP/24" dev "$INTERFACE"

# --- Download Bootloaders ---
echo "--- Downloading wimboot and iPXE ---"
cd "$WORK_DIR"
# Check if internet is reachable (might fail if eno1 was the only connection)
# We try to download; if fail, we assume files might be cached or user has wifi
wget -q -O wimboot https://github.com/ipxe/wimboot/releases/latest/download/wimboot || echo "Warning: Download failed. Ensure you have WiFi or cached files."
wget -q -O ipxe.efi http://boot.ipxe.org/ipxe.efi
wget -q -O undionly.kpxe http://boot.ipxe.org/undionly.kpxe

# --- Create iPXE Script ---
cat > "$WORK_DIR/boot.ipxe" <<EOF
#!ipxe
kernel http://$SERVER_IP:8000/wimboot
initrd http://$SERVER_IP:8000/BCD         BCD
initrd http://$SERVER_IP:8000/boot.sdi    boot.sdi
initrd http://$SERVER_IP:8000/boot.wim    boot.wim
boot
EOF

# --- Prepare Boot Files for HTTP ---
# Case-insensitive copy attempts
cp "$MOUNT_DIR/boot/bcd" "$WORK_DIR/BCD" 2>/dev/null || cp "$MOUNT_DIR/boot/BCD" "$WORK_DIR/BCD"
cp "$MOUNT_DIR/boot/boot.sdi" "$WORK_DIR/boot.sdi" 2>/dev/null || cp "$MOUNT_DIR/boot/boot.sdi" "$WORK_DIR/boot.sdi"
# cp "$MOUNT_DIR/sources/boot.wim" "$WORK_DIR/boot.wim" 2>/dev/null || cp "$MOUNT_DIR/sources/boot.wim" "$WORK_DIR/boot.wim"
cp /tmp/wim_patch/boot-patched.wim "$WORK_DIR/boot.wim"

# --- Start HTTP Server ---
echo "--- Starting HTTP Server (Port 8000) ---"
python -m http.server 8000 --directory "$WORK_DIR" 2>/dev/null &
HTTP_PID=$!

# --- Start Samba Server ---
echo "--- Starting Samba Server (Port 445) ---"
cat > "$WORK_DIR/smb.conf" <<EOF
[global]
    workgroup = WORKGROUP
    server string = PXE Server
    security = user
    map to guest = Bad User
    guest account = nobody
    log file = /dev/null
    disable netbios = yes
    smb ports = 445

[install]
    path = $MOUNT_DIR
    browsable = yes
    read only = yes
    guest ok = yes
EOF

smbd --configfile="$WORK_DIR/smb.conf" --foreground --no-process-group &
SMB_PID=$!

# --- Start DNSMASQ (DHCP + TFTP) ---
echo "--- Starting DNSMASQ (DHCP + TFTP) ---"
cat > "$WORK_DIR/dnsmasq.conf" <<EOF
interface=$INTERFACE
bind-interfaces
dhcp-range=$DHCP_RANGE
enable-tftp
tftp-root=$WORK_DIR

# 1. Match iPXE requests (Second stage)
dhcp-match=set:ipxe,175
dhcp-boot=tag:ipxe,boot.ipxe

# 2. Match Client Architecture (First stage)
dhcp-match=set:efi-x86_64,option:client-arch,7
dhcp-match=set:efi-bc,option:client-arch,9

# 3. Send binaries ONLY if not yet iPXE
# If UEFI (Arch 7 or 9) and NOT iPXE, send ipxe.efi
dhcp-boot=tag:efi-x86_64,tag:!ipxe,ipxe.efi
dhcp-boot=tag:efi-bc,tag:!ipxe,ipxe.efi

# If Legacy BIOS (default) and NOT iPXE, send undionly.kpxe
dhcp-boot=tag:!efi-x86_64,tag:!efi-bc,tag:!ipxe,undionly.kpxe
EOF

dnsmasq --conf-file="$WORK_DIR/dnsmasq.conf" --no-daemon &
DNS_PID=$!

echo ""
echo "==========================================================="
echo "SERVER IS RUNNING on $SERVER_IP ($INTERFACE)"
echo "Connect your PC and boot from network (PXE)."
echo ""
echo "CRITICAL INSTALLATION STEPS:"
echo "1. The PC will load files and show the Windows Installer."
echo "2. Once the 'Install Now' screen appears, press SHIFT + F10 to open CMD."
echo "3. Type the following command to mount the ISO share:"
echo "   net use z: \\\\$SERVER_IP\\install /user:guest"
echo "4. Run the setup:"
echo "   z:\\setup.exe"
echo "==========================================================="
echo "Press ENTER to stop the server and cleanup..."
read -r
