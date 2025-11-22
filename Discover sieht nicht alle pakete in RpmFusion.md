AppStream metadata

RPM Fusion repositories also provide Appstream metadata to enable users to install packages using Gnome Software/KDE Discover. Please note that these are a subset of all packages since the metadata are only generated for GUI packages.

For the current Fedora releases: the suggested method is to install appstream-data using DNF.

    The following command will install the required group of packages:

    sudo dnf update @core

     * Since DNF5 (Fedora 41 and later), the Fedora groups cannot be extended by RPM Fusion, so you need to mention the package explicitely:
    sudo dnf install rpmfusion-\*-appstream-data






# AppStream Metadata

RPM Fusion repositories also provide AppStream metadata to enable users to install packages using Gnome Software or KDE Discover. Please note that these metadata are a subset of all available packages, as they are only generated for GUI-based packages.

## Fedora Release Installation

For current Fedora releases, the suggested method is to install the `appstream-data` package using DNF.

### To install the required group of packages:

```bash
sudo dnf update @core
````

> **Note**: Since DNF5 (Fedora 41 and later), the Fedora groups cannot be extended by RPM Fusion. Therefore, you must explicitly mention the package:

```bash
sudo dnf install rpmfusion-*appstream-data
```

```

This will create well-structured, readable content in your GitHub markdown file, including code blocks and notes for clarity.
```
