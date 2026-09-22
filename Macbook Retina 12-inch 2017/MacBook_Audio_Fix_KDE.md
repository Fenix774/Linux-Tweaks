# Fixing Audio Output on MacBook 12" (2017) running Fedora (KDE)

## Problem Overview
The 12-inch Retina MacBook (2017 / `MacBook10,1`) utilizes a **Cirrus Logic CS4208** audio codec paired with custom Apple amplifier power sequencing. While modern Linux distributions (like Fedora with PipeWire) recognize the Intel HDA sound card and display an internal speaker device, the upstream kernel lacks the proprietary GPIO initialization sequence needed to switch on the speaker amplifiers.

This guide walks through enabling firmware-level hardware initialization via NVRAM and compiling the patched Cirrus Logic kernel module with DKMS persistence.

---

## Step 1: Verify Hardware Model

Confirm your MacBook identifier from the terminal:

```bash
sudo dmidecode -s system-product-name
```

> **Expected Output:** `MacBook10,1`

---

## Step 2: Enable the Apple Startup Chime (Critical Firmware Step)

The CS4208 amplifier initialization sequence depends on Apple's EFI firmware waking up the audio controller before the OS kernel boots. If the startup sound was muted in macOS, the chip remains in a deep sleep state that Linux cannot wake.

1. Power off the MacBook.
2. Boot into macOS or macOS Recovery:
   - Hold **Command ($\mathbf{\mathscr{H}}$) + R** immediately after pressing the power button.
3. Open **Terminal** from the menu bar under **Utilities $\rightarrow$ Terminal**.
4. Unmute the startup chime by executing:
   ```bash
   nvram StartupMute=%00
   ```
5. Shut down the laptop completely:
   ```bash
   halt
   ```
6. Power on the MacBook and confirm you hear the audible boot chime before GRUB loads.

---

## Step 3: Install Kernel Build Dependencies on Fedora

Boot into your Fedora KDE installation and open `Konsole`. Ensure your system has the matching kernel development headers and build toolchain:

```bash
sudo dnf check-update
sudo dnf install -y git dkms kernel-devel kernel-headers make gcc wget
```

> **Note:** If you recently updated your kernel but haven't rebooted yet, reboot once before continuing to ensure the running kernel matches `kernel-devel`.

---

## Step 4: Clone and Install the Patched Cirrus Driver

Clone the Cirrus CS4208 driver repository and execute the DKMS installer:

```bash
# Clone the repository
git clone https://github.com/juicecultus/macbook12-audio-driver.git

# Enter repository directory
cd macbook12-audio-driver

# Run the installer script
sudo ./install.cirrus.driver.sh -i
```

This script performs the following actions:
- Identifies your running kernel version.
- Fetches the upstream kernel HDA sound subsystem source.
- Applies the CS4208 amplifier patch.
- Compiles `snd-hda-codec-cs420x.ko`.
- Registers the module with **DKMS** (Dynamic Kernel Module Support) so it automatically rebuilds upon future Fedora kernel updates.

---

## Step 5: Reboot and Verify

1. Restart your machine:
   ```bash
   systemctl reboot
   ```

2. After logging in, verify that the custom module is loaded:
   ```bash
   lsmod | grep snd_hda_codec_cs420x
   ```

3. Open **KDE System Settings $\rightarrow$ Sound** (or click the volume tray applet):
   - Set **Play speech and sounds through:** to `Built-in Audio Stereo` / `Internal Speakers`.
   - Ensure the volume slider is above 50% and not muted.
   - Click **Test** on the left and right stereo channels to verify sound output.

---

## Troubleshooting

- **Headphone Jack Auto-Detection:**
  If switching between speakers and 3.5mm headphones does not automatically transition, you can manually switch ports via the sound applet or install `pavucontrol`:
  ```bash
  sudo dnf install -y pavucontrol
  pavucontrol
  ```
  Navigate to the **Output Devices** tab and manually toggle the **Port** dropdown between *Speakers* and *Headphones*.

- **DKMS Status Check:**
  To verify the module status across kernel updates:
  ```bash
  dkms status
  ```