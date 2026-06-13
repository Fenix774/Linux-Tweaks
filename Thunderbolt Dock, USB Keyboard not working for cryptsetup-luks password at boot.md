
```
https://www.guyrutenberg.com/2026/03/04/usb-keyboard-not-working-in-dracut-when-connected-via-thunderbolt-dock/
```

USB Keyboard Not Working in Dracut When Connected via Thunderbolt Dock

My USB keyboard stopped working during the Dracut initramfs phase (e.g., at the LUKS password prompt) when connected through a Thunderbolt dock. It worked fine in GRUB, in GNOME, and when plugged directly into the laptop. It had also worked through the dock before.
Why It Broke

GRUB is probably using UEFI/BIOS USB legacy emulation and doesn’t need the Thunderbolt controller at all. Dracut uses the real kernel driver stack, so the Thunderbolt controller needs to be initialized and authorized before the keyboard becomes visible.

Checking the Thunderbolt security level:
```
$ cat /sys/bus/thunderbolt/devices/domain0/security
user
```
The user level requires explicit device authorization. In GNOME, boltd handles this automatically. In Dracut, nothing does. Previously, the security level was none, but a firmware update changed it to user.

IOMMU DMA protection is still active independently:
```
$ cat /sys/bus/thunderbolt/devices/domain0/iommu_dma_protection
1
```
Why Not Boot ACL?

The ideal fix would be to enroll the dock in the firmware’s Boot ACL – pre-authorized devices stored in UEFI NVRAM that are authorized before the OS loads. However, boltctl domains showed bootacl: 0/0 – the firmware doesn’t support it.
The Fix: A Dracut-Only Udev Rule

The solution is a udev rule that auto-authorizes Thunderbolt devices during the initramfs phase only. We don’t want this rule in the running system, as it would bypass boltd‘s authorization logic in GNOME. The clean way is a small dracut module that carries the udev rule inside the initramfs.

Create the module directory and files:
```
$ sudo mkdir -p /usr/lib/dracut/modules.d/99thunderbolt-auth

$ sudo tee /usr/lib/dracut/modules.d/99thunderbolt-auth/99-thunderbolt-auto-auth.rules <<'EOF'
ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
EOF

$ sudo tee /usr/lib/dracut/modules.d/99thunderbolt-auth/module-setup.sh <<'EOF'
#!/bin/bash
check() { return 0; }
depends() { return 0; }
install() {
    inst_simple "$moddir/99-thunderbolt-auto-auth.rules" 
        /etc/udev/rules.d/99-thunderbolt-auto-auth.rules
}
EOF
$ sudo chmod +x /usr/lib/dracut/modules.d/99thunderbolt-auth/module-setup.sh
```
Create the dracut config at /etc/dracut.conf.d/thunderbolt.conf:
```
add_dracutmodules+=" thunderbolt-auth "
```
Note that dracut module names in config files omit the numeric prefix – the directory is 99thunderbolt-auth but is referenced as thunderbolt-auth.

Rebuild the initramfs:
```
$ sudo dracut --force
```
Security Notes

The udev rule auto-authorizes Thunderbolt devices only during the brief Dracut window. In the running system, boltd continues to handle authorization normally. In both cases, IOMMU DMA protection remains active, which is the actual security boundary against malicious Thunderbolt devices.

There was this comment submitted for this solution:

```
Comment: Hey, 2 things:
right after >>inst_simple “$moddir/99-thunderbolt-auto-auth.rules”<< should not be a linebreak
It’s not working on my Thinkpad T14 Gen 3 Intel with the TB3 Gen2 Dock
Cheers, Tobi
```
