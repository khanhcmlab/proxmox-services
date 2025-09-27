#!/bin/bash

# Batch Installer for All VMs
# This script helps you install Arch Linux on all VMs sequentially

declare -A VM_CONFIG
VM_CONFIG["control-plane-1"]="192.168.1.110"
VM_CONFIG["worker-1"]="192.168.1.111"
VM_CONFIG["control-plane-2"]="192.168.1.112"
VM_CONFIG["worker-2"]="192.168.1.113"
VM_CONFIG["control-plane-3"]="192.168.1.114"
VM_CONFIG["worker-3"]="192.168.1.115"

echo "🎯 BATCH ARCH LINUX INSTALLER"
echo "=============================="
echo ""
echo "This script will help you install Arch Linux on all VMs."
echo "Make sure each VM is booted from the Arch Linux ISO."
echo ""

for hostname in "${!VM_CONFIG[@]}"; do
    ip="${VM_CONFIG[$hostname]}"
    echo "📋 $hostname -> $ip"
done

echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

echo ""
echo "🔧 For each VM, boot from Arch ISO and run this ONE command:"
echo ""
echo "curl -fsSL https://raw.githubusercontent.com/khanhcmlab/proxmox-services/refs/heads/main/auto-install.sh | bash"
echo ""
echo "Or if you prefer manual specification:"
echo ""

for hostname in "${!VM_CONFIG[@]}"; do
    ip="${VM_CONFIG[$hostname]}"
    echo "# For $hostname:"
    echo "curl -fsSL https://raw.githubusercontent.com/khanhcmlab/proxmox-services/refs/heads/main/install-archlinux.sh | bash -s $hostname $ip"
    echo ""
done

echo "💡 TIPS:"
echo "1. Start all VMs and boot them from Arch Linux ISO"
echo "2. On each VM console, paste the curl command above"
echo "3. The installation will run automatically"
echo "4. Each VM will reboot when installation is complete"
echo "5. After reboot, you can SSH with: ssh arch@<ip-address>"
echo ""
echo "🔐 Default credentials (CHANGE THESE!):"
echo "Username: arch"
echo "Password: archlinux"
echo "Root password: archlinux"