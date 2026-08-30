# MacBook 12" Retina (2017) Fedora KDE Setup: Sleep & Lid Management

A setup and workaround guide for the broken ACPI suspend and SPI input controller wake issues on the 12-inch Retina MacBook (`MacBook10,1`) running Fedora KDE Plasma.

---

## 1. Disable Broken Sleep & Suspend Targets

Masking sleep-related `systemd` targets prevents the OS, desktop environment (KDE), or background daemons from triggering sleep states that lead to unrecoverable wake freezes.

### Recommended: Mask All Sleep & Compound Targets

This completely blocks all sleep variations, including hybrid states and timed sleep triggers:

```bash
# Mask all sleep, suspend, and hybrid targets
sudo systemctl mask sleep.target suspend.target hybrid-sleep.target suspend-then-hibernate.target
```

### Alternative: Minimal Suspend Masking (Less Intrusive)

If you only want to block direct suspend-to-RAM while leaving compound sleep hooks untouched:

```bash
# Minimal target masking (may still allow hybrid sleep triggers)
sudo systemctl mask sleep.target suspend.target
```

> **Target Breakdown:**
> * `sleep.target`: Generic umbrella target for sleep events.
> * `suspend.target`: Standard Suspend-to-RAM / `s2idle`.
> * `hybrid-sleep.target`: Writes memory image to disk *and* suspends to RAM.
> * `suspend-then-hibernate.target`: Suspends to RAM first, then wakes to hibernate after a timer.

---

## 2. Configure Instant Screen-Off & Lock on Lid Close

### A. Screen Locking Configuration
1. Open **System Settings** → **Security & Privacy** → **Screen Locking**.
2. Set **Delay before password required** to **Immediately**.
3. Click **Apply**.

### B. Power Management (Lid Action)
1. Open **System Settings** → **Power Management** (under *Hardware*).
2. Under both **On Battery** and **On AC Power**, set:
   * **When laptop lid is closed**: **Lock screen**
3. Click **Apply**.

> *Note: In KDE Plasma, selecting "Lock screen" for lid closure immediately cuts power to the Retina display backlight upon closure and restores it with the password prompt upon opening.*

---

## 3. Maximize Idle Battery Life (Optional)

Because the Intel Y-series CPU is fanless and sips ~0.8W at idle, these optimizations keep battery drain minimal while the screen is off.

### A. Automated Hardware Power Tuning (`powertop`)
```bash
sudo dnf install -y powertop

# Create persistent auto-tune service
sudo tee /etc/systemd/system/powertop-autotune.service << 'EOF'
[Unit]
Description=Powertop Auto-Tune Power Management
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/powertop --auto-tune

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now powertop-autotune.service
```

### B. Enable Wi-Fi & Audio Power Saving (Optional)
```bash
# Aggressive Wi-Fi power saving
sudo tee /etc/NetworkManager/conf.d/default-wifi-powersave.conf << 'EOF'
[connection]
wifi.powersave = 3
EOF
sudo systemctl reload NetworkManager

# Intel HD Audio power down when idle
sudo tee /etc/modprobe.d/audio-powersave.conf << 'EOF'
options snd_hda_intel power_save=1 power_save_controller=Y
EOF
```
