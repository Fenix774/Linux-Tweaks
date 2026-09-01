# Fix: Screen Brightness & Hue Shifting on MacBook 12" Retina (Fedora KDE Plasma)

## The following is AI generated

The fix below here is AI generated, it does appear to fix the issue of the flickering though.

---

## Overview

When running **Fedora KDE Plasma (Wayland)** on an **Apple MacBook (Retina, 12-inch)** with Intel HD/UHD graphics, the display may intermittently flicker, pop in brightness, or shift color temperature/hue when opening, focusing, or resizing windows of varying brightness levels (e.g., switching between dark terminals and white browser pages).

---

## Root Cause

This issue is caused by **KWin DRM Direct Scanout**.

* **Standard Compositing:** KWin renders desktop windows through an OpenGL/Vulkan shader pipeline before sending the frame to the display.
* **Direct Scanout:** When a single application window fills the screen or meets overlay plane criteria, KWin bypasses the compositor shader and sends the application's frame buffer directly to the Intel DRM hardware plane to save memory bandwidth and reduce latency.

On the 12-inch MacBook's internal eDP Retina panel, the Intel DRM hardware plane and KWin's OpenGL shader apply slightly different gamma, color lookup tables (LUT), and transfer matrices. Every time a window triggers or releases direct scanout, an instantaneous luminance and hue shift occurs, mimicking a broken dynamic contrast feature.

---

## Solution

Disable direct scanout in KWin by setting the `KWIN_DRM_NO_DIRECT_SCANOUT` environment variable globally.

### Step 1: Edit `/etc/environment` to contain `KWIN_DRM_NO_DIRECT_SCANOUT=1`

Run the following command in your terminal:

```bash
echo "KWIN_DRM_NO_DIRECT_SCANOUT=1" | sudo tee -a /etc/environment
```

### Step 2: Reboot

Run the following command in your terminal to reboot:

```bash
sudo reboot
```

### Step 3: Confirmation

Run the following command in your terminal to verify if the setting is enabled:

```bash
printenv KWIN_DRM_NO_DIRECT_SCANOUT
```
