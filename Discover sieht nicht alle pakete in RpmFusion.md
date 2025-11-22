RPM Fusion repositories also provide AppStream metadata to enable users to install packages using Gnome Software or KDE Discover. Please note that these metadata are a subset of all available packages, as they are only generated for GUI-based packages.<br><br>
For current Fedora releases, the suggested method is to install the `appstream-data` package using DNF.

### To install the required group of packages:

```bash
sudo dnf update @core
````

> **Note**: Since DNF5 (Fedora 41 and later), the Fedora groups cannot be extended by RPM Fusion. Therefore, you must explicitly mention the package:

```bash
sudo dnf install rpmfusion-*appstream-data
```
