# Apple FaceTime HD Camera Installation Guide (Fedora)

A step-by-step guide to extract required firmware and install the FaceTime HD (Broadcom 1570 PCIe) webcam driver on Fedora Linux.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Firmware Extraction and Installation](#2-firmware-extraction-and-installation)
3. [Dracut Configuration (Initramfs Inclusion)](#3-dracut-configuration-initramfs-inclusion)
4. [Driver Installation via Copr](#4-driver-installation-via-copr)
5. [Verification & Troubleshooting (Optional)](#5-verification--troubleshooting-optional)
6. [References & Sources](#6-references--sources)

---

## 1. Prerequisites

Ensure you have the required build tools and utilities (`git`, `make`, `curl`, `xz`, and `cpio`) installed:

```bash
sudo dnf install git make curl xz cpio
```

---

## 2. Firmware Extraction and Installation

Clone the firmware extraction tool repository, compile the extractor, download the macOS driver package, and extract the firmware binary:

```bash
# Clone the firmware extraction repository
git clone https://github.com/patjak/facetimehd-firmware.git

# Navigate into the repository directory
cd facetimehd-firmware

# Fetch macOS package and extract the firmware
make

# Install the firmware into /usr/lib/firmware/facetimehd/
sudo make install
```

---

## 3. Dracut Configuration (Initramfs Inclusion)

To ensure the firmware is available early during boot, add the firmware binary path to Dracut's configuration:

```bash
echo 'install_items+=" /usr/lib/firmware/facetimehd/firmware.bin "' | sudo tee -a /etc/dracut.conf.d/facetimehd.conf
```

*(Optional) Regenerate initramfs to apply the configuration immediately:*

```bash
sudo dracut -f
```

---

## 4. Driver Installation via Copr

Enable the COPR repository maintained for the DKMS kernel module and install the `facetimehd` package:

```bash
# Enable the COPR repository
sudo dnf copr enable frgt10/facetimehd-dkms

# Install the FaceTime HD driver package
sudo dnf install facetimehd
```

---

## 5. Verification & Troubleshooting (Optional)

After installation, load the kernel module or reboot your system:

```bash
# Load the kernel module manually
sudo modprobe facetimehd

# Verify that the module is loaded
lsmod | grep facetimehd

# Check kernel messages for device recognition
sudo dmesg | grep -i facetimehd
```

Test your webcam using applications such as **Cheese**, **Kamoso**, or a web browser.

---

## 6. References & Sources

- **Firmware Extraction Wiki:** [patjak/facetimehd - Firmware Extraction Guide](https://github.com/patjak/facetimehd/wiki/Get-Started#firmware-extraction)
- **Fedora COPR Repository:** [frgt10/facetimehd-dkms](https://copr.fedorainfracloud.org/coprs/frgt10/facetimehd-dkms/)
