#!/bin/bash

# Super Quick One-Liner Installer
# Run this on each VM after booting from Arch ISO

# VM Configuration Array
declare -A VM_CONFIG
VM_CONFIG["control-plane-1"]="192.168.1.110"
VM_CONFIG["worker-1"]="192.168.1.111"
VM_CONFIG["control-plane-2"]="192.168.1.112"
VM_CONFIG["worker-2"]="192.168.1.113"
VM_CONFIG["control-plane-3"]="192.168.1.114"
VM_CONFIG["worker-3"]="192.168.1.115"

echo "🎯 AUTO-DETECT AND INSTALL"
echo "========================="

# Try to detect which VM this is based on VM ID or MAC address
VM_ID=$(dmidecode -s system-serial-number 2>/dev/null | grep -o '[0-9]\+' | tail -1)

case $VM_ID in
    110) HOSTNAME="control-plane-1" ;;
    111) HOSTNAME="worker-1" ;;
    112) HOSTNAME="control-plane-2" ;;
    113) HOSTNAME="worker-2" ;;
    114) HOSTNAME="control-plane-3" ;;
    115) HOSTNAME="worker-3" ;;
    *)
        echo "❌ Could not auto-detect VM. Please specify manually:"
        echo "Available options: control-plane-1, worker-1, control-plane-2, worker-2, control-plane-3, worker-3"
        read -p "Enter hostname: " HOSTNAME
        ;;
esac

if [ -z "${VM_CONFIG[$HOSTNAME]}" ]; then
    echo "❌ Invalid hostname: $HOSTNAME"
    exit 1
fi

IP_ADDRESS="${VM_CONFIG[$HOSTNAME]}"

echo "✅ Detected VM: $HOSTNAME"
echo "✅ IP Address: $IP_ADDRESS"
echo ""
echo "🚀 Starting automated installation..."
sleep 3

# Download and run the main installer
curl -fsSL https://raw.githubusercontent.com/khanhcmlab/proxmox-services/refs/heads/main/install-archlinux.sh -o /tmp/install.sh
chmod +x /tmp/install.sh
/tmp/install.sh "$HOSTNAME" "$IP_ADDRESS"