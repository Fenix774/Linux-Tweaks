# Chromium / Chrome Configuration Guide

A guide to enabling middle-click autoscroll, disabling default browser prompts, and suppressing security warnings for unsupported command-line flags.

---

## 1. Launcher Command-Line Flags

Add the following flags to your application launcher (e.g., in your desktop entry or shortcut properties):

### Enable Middle-Click Autoscroll
Enables Windows-style middle-click autoscrolling in Chromium-based browsers on Linux:

```bash
--enable-blink-features=MiddleClickAutoscroll
```

### Disable Default Browser Prompt
Prevents the browser from asking to be set as the default browser:

```bash
--no-default-browser-check
```

---

### Combining with Desktop URL Placeholders (`%U`)

If your desktop launcher file (`.desktop`) already ends with the `%U` URL placeholder, format the command as follows:

- **Autoscroll only:**
  ```bash
  --enable-blink-features=MiddleClickAutoscroll %U
  ```

- **Autoscroll + Disable Default Browser Check:**
  ```bash
  --no-default-browser-check --enable-blink-features=MiddleClickAutoscroll %U
  ```

---

## 2. Disable "Unsupported Command-Line Flag" Warning

When using custom command-line flags, Chromium displays a security banner warning that unsupported flags are in use. You can suppress this warning using an enterprise policy.

### Step 1: Create the Policy Directory
Create the managed policy directory if it does not already exist:

```bash
sudo mkdir -p /etc/chromium/policies/managed
```

> **Note on other browsers:**
> - **Google Chrome:** Use `/etc/opt/chrome/policies/managed/`
> - **Chromium / Ungoogled Chromium:** Use `/etc/chromium/policies/managed/`

---

### Step 2: Create the Policy File
Open/create the policy configuration file:

```bash
sudo nano /etc/chromium/policies/managed/disable_flags_warning.json
```

*(If using Google Chrome, replace the path with `/etc/opt/chrome/policies/managed/disable_flags_warning.json`)*

---

### Step 3: Add Policy Configuration
Paste the following JSON content into the file:

```json
{
  "CommandLineFlagSecurityWarningsEnabled": false
}
```

Save the file and exit the editor (in `nano`, press `Ctrl+O`, `Enter`, then `Ctrl+X`).

---

### Step 4: Restart the Browser
Completely close and relaunch Chromium/Chrome.

### Result & Compatibility
- **Effect:** The *"unsupported command-line flag"* security banner will no longer appear on startup.
- **Supported Browsers:**
  - Chromium
  - Ungoogled Chromium
  - Google Chrome
