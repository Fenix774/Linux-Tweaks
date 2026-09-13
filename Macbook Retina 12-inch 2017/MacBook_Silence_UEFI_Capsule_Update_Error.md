# Silencing UEFI Capsule Update Errors in Fedora KDE

On Apple Intel hardware (such as the 12-inch MacBook 2017), the proprietary EFI implementation lacks support for standard UEFI runtime capsule updates (`UpdateCapsule`). Consequently, `fwupd` and KDE Discover produce errors such as:

```text
UEFI capsule updates not available or enabled in firmware setup
```

Because Apple delivers firmware updates exclusively through macOS installers rather than the Linux Vendor Firmware Service (LVFS), you can safely disable the capsule update check in `fwupd` to prevent persistent error dialogs and failed background checks.

---

## 1. Disable the UEFI Capsule Plugin in `fwupd`

Open a terminal and edit the UEFI capsule configuration file using root privileges:

```bash
sudo nano /etc/fwupd/uefi_capsule.conf
```

Locate the `[uefi_capsule]` section and change `DisableCapsuleUpdate` to `true`:

```ini
[uefi_capsule]
DisableCapsuleUpdate=true
```

> **Note:** If `/etc/fwupd/uefi_capsule.conf` is missing or commented out, you can set the key directly or create the file with the section header and key shown above.

Save the file and exit:
- In `nano`, press `Ctrl + O`, then `Enter` to write the changes.
- Press `Ctrl + X` to exit.

---

## 2. Restart the `fwupd` Daemon

Apply the changes by restarting the systemd service:

```bash
sudo systemctl restart fwupd.service
```

---

## 3. Verification

Verify that the capsule update backend is no longer being polled and that errors are resolved:

1. **Test `fwupd` directly:**
   ```bash
   fwupdmgr refresh
   ```
   The command should complete without reporting failures related to capsule updates or missing firmware setup options.

2. **Check KDE Discover:**
   - Launch **Discover**.
   - Navigate to the **Update** tab and click **Fetch Updates**.
   - The notification regarding unavailable UEFI capsule updates will no longer appear.
