# MacBook 12" Retina (2017) Fedora Gnome Setup: Sleep & Lid Management

A setup and workaround guide for the broken ACPI suspend and SPI input controller wake issues on the 12-inch Retina MacBook (`MacBook10,1`) running Fedora Gnome.

---

## 1. Disable Broken Sleep & Suspend Targets

Masking sleep-related `systemd` targets prevents the OS, desktop environment (Gnome), or background daemons from triggering sleep states that lead to unrecoverable wake freezes.

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

## 2. Configure Lid-Close Action to Lock Session

Instead of attempting ACPI sleep when the lid is closed, configure `systemd-logind` to lock the session and power down the display.

Drop-in files in `/etc/systemd/logind.conf.d/` keep the main configuration clean and persist cleanly across package updates.

1. Create the drop-in configuration file:
   ```bash
   sudo mkdir -p /etc/systemd/logind.conf.d
   sudo tee /etc/systemd/logind.conf.d/macbook-lid.conf << EOF
   [Login]
   HandleLidSwitch=lock
   HandleLidSwitchExternalPower=lock
   HandleLidSwitchDocked=ignore
   EOF
   ```

2. Restart `systemd-logind` to apply the changes:
   ```bash
   sudo systemctl restart systemd-logind
   ```

   ---

### What the `HandleLidSwitch` Settings Mean

`systemd-logind` evaluates three distinct lid-close conditions depending on power state and connected hardware[cite: 1]:

* **`HandleLidSwitch`**: 
  Controls the action taken when the lid is closed while running on **battery power**[cite: 1].
* **`HandleLidSwitchExternalPower`**: 
  Controls the action taken when the lid is closed while plugged into the **AC charger / wall power**[cite: 1].
* **`HandleLidSwitchDocked`**: 
  Controls the action taken when the lid is closed while connected to an **external monitor** (or dock)[cite: 1].

---

### What the Values Do

* **`lock`**: 
  Tells your desktop session manager (GNOME, KDE) to lock the screen immediately and power off the display backlight without putting the CPU/kernel to sleep[cite: 1].
* **`ignore`**: 
  Completely disregards the lid close event[cite: 1]. Setting `HandleLidSwitchDocked=ignore` allows "clamshell mode"—letting you close the laptop and keep working on an external display without the machine locking or shutting down[cite: 1].
* **`suspend`** *(default on most Linux systems)*: 
  Attempts standard ACPI suspend-to-RAM (`s2idle`/S3).
* **`hibernate`**: 
  Writes the contents of RAM to swap and powers the system completely off.
* **`poweroff`**: 
  Executes an immediate clean shutdown.

---

## 3. Apply Changes & Restart

To ensure all GNOME desktop UI elements update and reload masked D-Bus interfaces, reboot your system:

```bash
sudo reboot
```

---

## 4. Maximize Idle Battery Life (Optional)

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
