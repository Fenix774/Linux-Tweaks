# KDE Plasma: Screen Edge & Taskbar Reveal Configuration

## 1. Disable Pressure / Delay to Bring Up Taskbar

### Step 1: Open `kwinrc` in a Text Editor
```bash
nano ~/.config/kwinrc
```

### Step 2: Configure Delay Parameters
Under the `[Windows]` section, add or update the following parameters:

```ini
[Windows]
ElectricBorderDelay=0
ElectricBorderCooldown=0
```

#### Reference: Default & Balanced Values
* **Default Values** (standard dwell and cooldown times):
  ```ini
  [Windows]
  ElectricBorderDelay=150
  ElectricBorderCooldown=350
  ```
* **Reduced / Balanced Values** (responsive without accidental triggers):
  ```ini
  [Windows]
  ElectricBorderDelay=50
  ElectricBorderCooldown=150
  ```

### Step 3: Reload KWin
Apply the configuration changes immediately without logging out:

```bash
qdbus org.kde.KWin /KWin reconfigure
```

---

## 2. Disable Edge Glow Before Taskbar Comes Up

### Method 1: Terminal (Fastest)
Run the following commands to disable the Screen Edge glow plugin and reload KWin immediately:

```bash
# Disable the Screen Edge glow plugin in KWin
kwriteconfig6 --file kwinrc --group Plugins --key screenedgeEnabled false

# Reload KWin to apply the change instantly
qdbus org.kde.KWin /KWin reconfigure
```
> *Note: If using KDE Plasma 5, use `kwriteconfig5` instead of `kwriteconfig6`.*

### Method 2: System Settings (GUI)
1. Open **System Settings**.
2. Navigate to **Window Management** $
ightarrow$ **Desktop Effects**.
3. In the search box at the top, type `Screen Edge` (or locate **Highlight Screen Edges and Hot Corners** under the *Window Management* category).
4. Uncheck the box next to **Screen Edge**.
5. Click **Apply**.
