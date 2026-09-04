#!/usr/bin/env bash
set -euo pipefail

# Ensure script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root (e.g., using sudo)."
    exit 1
fi

echo "=== 1/3: Excluding Incompatible Drivers in DNF ==="
sed -i '/^excludepkgs=.*broadcom-wl/d' /etc/dnf/dnf.conf 2>/dev/null || true
echo "excludepkgs=*broadcom-wl*,*akmod-wl*,*kmod-wl*" >> /etc/dnf/dnf.conf
dnf clean all

echo "=== 2/3: Removing Conflicting Packages & Stale Modprobe Configs ==="
dnf remove -y broadcom-wl akmod-wl kmod-wl 2>/dev/null || true
rm -f /etc/modprobe.d/*broadcom* /etc/modprobe.d/*wl*
dnf install -y linux-firmware

echo "=== 3/3: Blacklisting 'wl' Kernel Module & Loading 'brcmfmac' ==="
echo "blacklist wl" > /etc/modprobe.d/blacklist-wl.conf
modprobe -r wl 2>/dev/null || true
modprobe brcmfmac


echo "--------------------------------------------------------"
echo "Setup complete!"
echo "The system will now never find proprietary Broadcom drivers"
echo "--------------------------------------------------------"
