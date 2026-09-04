# Broadcom Wi-Fi Configuration & Automation Scripts for Linux

This document compiles three administrative automation scripts designed to resolve persistent Wi-Fi connectivity, driver collision, and authentication failure issues on Linux systems equipped with Broadcom wireless chipsets (notably Apple MacBook hardware using chipsets such as the BCM4350 and BCM4360).

---

## Table of Contents
1. [Overview & Strategy](#overview--strategy)
2. [Script Comparison Matrix](#script-comparison-matrix)
3. [Script 1: NetworkManager WPA3-to-WPA2 Auto-Patch Daemon](#script-1-networkmanager-wpa3-to-wpa2-auto-patch-daemon)
   - [Description & Technical Details](#description--technical-details-1)
   - [Script Source Code](#script-source-code-1)
   - [Verification & Management](#verification--management-1)
4. [Script 2: Hardened NetworkManager Auto-Patch Daemon (WPA2, PMF Disabled & MAC Preservation)](#script-2-hardened-networkmanager-auto-patch-daemon-wpa2-pmf-disabled--mac-preservation)
   - [Description & Technical Details](#description--technical-details-2)
   - [Script Source Code](#script-source-code-2)
   - [Verification & Management](#verification--management-2)
5. [Script 3: Broadcom Driver Sanitization & Package Lock (Fedora / DNF)](#script-3-broadcom-driver-sanitization--package-lock-fedora--dnf)
   - [Description & Technical Details](#description--technical-details-3)
   - [Script Source Code](#script-source-code-3)
   - [Verification & Management](#verification--management-3)
6. [Recommended Deployment Order](#recommended-deployment-order)

---

## Overview & Strategy

Broadcom wireless adapters running under Linux often encounter two distinct categories of failure:
1. **Driver Stack Collisions:** Conflicts between the proprietary `broadcom-wl` module and the in-kernel open-source driver (`brcmfmac` / `b43`), leading to kernel panics, unrecognized interfaces, or blocked radios.
2. **Modern WPA3 / PMF Incompatibilities:** Many older Broadcom firmware implementations fail to complete the simultaneous authentication of equals (SAE) handshake in WPA3-Personal or drop connections when Protected Management Frames (PMF / 802.11w) are enforced, even on mixed WPA2/WPA3 networks.

The scripts below provide complete automated remedies: **Script 3** sanitizes the kernel driver environment, while **Script 1** and **Script 2** install automated system-level daemons using `systemd.path` to sanitize NetworkManager connection profiles dynamically whenever new Wi-Fi networks are added.

---

## Script Comparison Matrix

| Feature / Action | Script 1 | Script 2 | Script 3 |
| :--- | :--- | :--- | :--- |
| **Primary Scope** | NetworkManager Profile Sanitization | NetworkManager Profile Sanitization | Kernel Driver & Package Management |
| **Target OS / Tool** | Any Linux system with NetworkManager & Systemd | Any Linux system with NetworkManager & Systemd | Fedora / RHEL-based systems (using DNF) |
| **WPA3/SAE Mitigation** | Replaces `key-mgmt=.*sae` with `wpa-psk` | Replaces `key-mgmt=.*sae` with `wpa-psk` | N/A |
| **PMF (802.11w) Handling** | Untouched (preserves user/AP default) | Forces `pmf=1` (disabled) | N/A |
| **MAC Address Handling** | Untouched (preserves user/system default) | Forces `cloned-mac-address=preserve` | N/A |
| **Persistence Mechanism** | `systemd.path` watcher on `/etc/NetworkManager/system-connections` | `systemd.path` watcher on `/etc/NetworkManager/system-connections` | Persistent `/etc/dnf/dnf.conf` & modprobe blacklist |
| **Driver Clean-up** | Unblocks rfkill, restarts NetworkManager | Unblocks rfkill, restarts NetworkManager | Purges `broadcom-wl`, blacklists `wl`, loads `brcmfmac` |

---

## Script 1: NetworkManager WPA3-to-WPA2 Auto-Patch Daemon

### Description & Technical Details 1

#### Purpose
This script addresses connection drops and authentication stalls caused by WPA3/SAE negotiation on Broadcom chipsets (such as BCM4350). When connecting to modern access points advertising transition mode (WPA2/WPA3 mixed), NetworkManager often selects WPA3-SAE, leading to failure.

#### How It Works
1. **Root Privilege Check:** Verifies execution as `root` (EUID 0).
2. **Worker Script Generation (`/usr/local/bin/macbook-wifi-autofix.sh`):**
   - Scans all `.nmconnection` files in `/etc/NetworkManager/system-connections/`.
   - Checks if the profile has a `[wifi-security]` block with `key-mgmt` set to SAE.
   - Modifies the setting in-place using `sed` to `key-mgmt=wpa-psk`.
   - Calls `nmcli connection reload` only if a change was actually made.
3. **Systemd Automation:**
   - Deploys `macbook-wifi-autofix.service`: a oneshot unit executing the worker script.
   - Deploys `macbook-wifi-autofix.path`: a systemd path monitoring unit watching `/etc/NetworkManager/system-connections` for modifications. Whenever you connect to a new network, NetworkManager writes a file, triggering this unit immediately.
4. **Service Initialization:**
   - Reloads the systemd daemon and activates `macbook-wifi-autofix.path`.
   - Runs an immediate pass on existing connections.
   - Executes `rfkill unblock all`, enables Wi-Fi radio, and restarts NetworkManager.

### Script Source Code 1

```bash
#!/usr/bin/env bash
set -euo pipefail

# Ensure script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root (e.g., using sudo)."
    exit 1
fi

echo "=== 1/2: Installing NetworkManager WPA Auto-Patch Daemon ==="
# Create the script that converts WPA3/SAE profiles to WPA2-PSK only
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
```

### Verification & Management 1

- **Check Path Watcher Status:**
  ```bash
  systemctl status macbook-wifi-autofix.path
  ```
- **Inspect Past Automatic Runs:**
  ```bash
  journalctl -u macbook-wifi-autofix.service
  ```
- **Manually Run Worker Script:**
  ```bash
  sudo /usr/local/bin/macbook-wifi-autofix.sh
  ```

---

## Script 2: Hardened NetworkManager Auto-Patch Daemon (WPA2, PMF Disabled & MAC Preservation)

### Description & Technical Details 2

#### Purpose
This script is an expanded, hardened alternative to Script 1. In addition to forcing WPA2-PSK over WPA3-SAE, it eliminates two other common failure vectors on Apple MacBook Broadcom hardware:
1. **Protected Management Frames (PMF / 802.11w):** Older Broadcom firmware crashes or silently rejects associations when PMF is enabled or mandated by the router. Setting `pmf=1` instructs NetworkManager to explicitly disable PMF negotiation.
2. **MAC Address Randomization Collisions:** Newer distributions randomize the Wi-Fi MAC address during scans and associations. Certain Broadcom chips reject firmware reconfiguration when the MAC address is changed dynamically, leading to disconnection loops. Forcing `cloned-mac-address=preserve` ensures the interface keeps its factory burned-in MAC address.

#### How It Works
- Implements the same systemd watcher daemon architecture (`systemd.path` + `systemd.service`) as Script 1.
- In `/usr/local/bin/macbook-wifi-autofix.sh`, it checks each `.nmconnection` file for:
  - `key-mgmt=.*sae` → rewritten to `key-mgmt=wpa-psk`.
  - `pmf=` under `[wifi-security]` → set or inserted as `pmf=1` (disabled).
  - `cloned-mac-address=` under `[wifi]` → inserted as `cloned-mac-address=preserve` if not already defined.
- Reloads NetworkManager connections only if modifications occurred.

### Script Source Code 2

```bash
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
```

### Verification & Management 2

- **Verify a specific connection profile has been patched:**
  ```bash
  sudo cat /etc/NetworkManager/system-connections/<YOUR_SSID>.nmconnection
  ```
  Look for:
  ```ini
  [wifi]
  cloned-mac-address=preserve

  [wifi-security]
  key-mgmt=wpa-psk
  pmf=1
  ```
- **Check daemon execution:**
  ```bash
  systemctl status macbook-wifi-autofix.path
  ```

---

## Script 3: Broadcom Driver Sanitization & Package Lock (Fedora / DNF)

### Description & Technical Details 3

#### Purpose
On Fedora and Red Hat-based distributions, enabling repositories such as RPM Fusion often results in the automatic installation of `broadcom-wl` (`akmod-wl`). While `broadcom-wl` supports older chipsets (like BCM4311/4312/4322), it actively conflicts with modern FullMAC chipsets (like BCM4350, BCM43602) which require the upstream Linux kernel module `brcmfmac`. When both drivers exist, module conflicts prevent the Wi-Fi card from working.

#### How It Works
1. **DNF Exclusion Lock (Step 1/3):**
   - Cleans any old `excludepkgs` rules regarding `broadcom-wl` from `/etc/dnf/dnf.conf`.
   - Appends `excludepkgs=*broadcom-wl*,*akmod-wl*,*kmod-wl*` to `/etc/dnf/dnf.conf`.
   - Runs `dnf clean all` so future package updates (`dnf update`) never reinstall the conflicting driver.
2. **Package & Modprobe Purge (Step 2/3):**
   - Uninstalls packages `broadcom-wl`, `akmod-wl`, and `kmod-wl`.
   - Removes lingering modprobe configurations from `/etc/modprobe.d/*broadcom*` and `/etc/modprobe.d/*wl*` that may have blacklisted the native driver.
   - Installs/updates the upstream `linux-firmware` package to ensure official Broadcom firmware files (`brcmfmac4350-pcie.bin`, etc.) are present.
3. **Module Blacklist & Open-Source Driver Loading (Step 3/3):**
   - Writes `blacklist wl` into `/etc/modprobe.d/blacklist-wl.conf` to prevent the proprietary driver from ever loading.
   - Unloads the `wl` module from the running kernel with `modprobe -r wl`.
   - Immediately loads the official `brcmfmac` kernel driver via `modprobe brcmfmac`.

### Script Source Code 3

```bash
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
```

### Verification & Management 3

- **Check which driver module is bound to the PCI Wi-Fi device:**
  ```bash
  lspci -k -d 14e4:
  ```
  Expected output should indicate `Kernel driver in use: brcmfmac`.
- **Verify DNF package exclusions:**
  ```bash
  dnf list "*broadcom-wl*"
  ```
  The package should either not appear or be marked as excluded.
- **Inspect kernel ring buffer for Broadcom firmware loading:**
  ```bash
  dmesg | grep -i brcm
  ```

---

## Recommended Deployment Order

If you are setting up a fresh or malfunctioning Linux installation on an affected MacBook:

1. **Step 1: Execute Script 3** (Fedora / DNF users) to purge conflicting proprietary `wl` packages, enforce `brcmfmac`, and update kernel firmware.
2. **Step 2: Choose and Execute Script 1 or Script 2**:
   - Use **Script 1** if you only have trouble with WPA3 access points and want to leave PMF and MAC addressing under standard NetworkManager behavior.
   - Use **Script 2** (Recommended for most troubled MacBooks) if your connection still drops intermittently, as disabling PMF and preserving the hardware MAC address provides maximum compatibility with legacy Broadcom firmware.
