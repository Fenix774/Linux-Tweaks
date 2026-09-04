#!/usr/bin/env bash
set -euo pipefail

# Ensure script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root (e.g., using sudo)."
    exit 1
fi

echo "=== 1/2: Installing NetworkManager WPA Auto-Patch Daemon ==="
# Create the script that converts all WPA3/SAE and PMF profiles to WPA2-PSK
cat << 'EOF' > /usr/local/bin/macbook-wifi-autofix.sh
#!/usr/bin/env bash
DIR="/etc/NetworkManager/system-connections"
CHANGED=0

for file in "$DIR"/*.nmconnection; do
    [ -f "$file" ] || continue

    if grep -q '^\[wifi-security\]' "$file"; then
        # Force WPA2-Personal (wpa-psk) instead of WPA3-SAE
        if grep -q -E 'key-mgmt=.*sae' "$file"; then
            sed -i -E 's/key-mgmt=.*/key-mgmt=wpa-psk/' "$file"
            CHANGED=1
        fi

        # Disable Protected Management Frames (PMF)
        if grep -q '^pmf=' "$file"; then
            if ! grep -q '^pmf=1' "$file"; then
                sed -i 's/^pmf=.*/pmf=1/' "$file"
                CHANGED=1
            fi
        else
            sed -i '/^\[wifi-security\]/a pmf=1' "$file"
            CHANGED=1
        fi

        # Preserve permanent hardware MAC address
        if grep -q '^\[wifi\]' "$file"; then
            if ! grep -q '^cloned-mac-address=' "$file"; then
                sed -i '/^\[wifi\]/a cloned-mac-address=preserve' "$file"
                CHANGED=1
            fi
        fi
    fi
done

if [ "$CHANGED" -eq 1 ]; then
    nmcli connection reload
fi
EOF

chmod +x /usr/local/bin/macbook-wifi-autofix.sh

# Create the systemd service unit
cat << 'EOF' > /etc/systemd/system/macbook-wifi-autofix.service
[Unit]
Description=Auto-patch NetworkManager profiles for MacBook BCM4350 (WPA2 only)
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/macbook-wifi-autofix.sh
EOF

# Create the systemd path unit to watch for new Wi-Fi profiles
cat << 'EOF' > /etc/systemd/system/macbook-wifi-autofix.path
[Unit]
Description=Watch for new NetworkManager Wi-Fi profiles

[Path]
PathModified=/etc/NetworkManager/system-connections
Unit=macbook-wifi-autofix.service

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the path watcher
systemctl daemon-reload
systemctl enable --now macbook-wifi-autofix.path

# Execute once immediately to sanitize any existing connection profiles
/usr/local/bin/macbook-wifi-autofix.sh

echo "=== 2/2: Unblocking Radio & Starting Wi-Fi Services ==="
rfkill unblock all
nmcli radio wifi on
systemctl restart NetworkManager

echo "--------------------------------------------------------"
echo "Setup complete! The system will now automatically convert"
echo "WPA3/SAE profiles to WPA2-PSK while leaving PMF and MAC settings alone."
echo "--------------------------------------------------------"
