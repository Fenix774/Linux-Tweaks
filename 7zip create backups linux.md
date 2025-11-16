Install 7zip on Fedora:
```
sudo dnf install p7zip p7zip-plugins
```


Default command:
```
7z a /path/to/archive.7z /path/to/file1.abc /path/to/folder
```


When creating backups of linux directories use the "do not follow symbolic/hardlinks" option:
```
7z a -snh -snl /path/to/archive.7z /path/to/file1.abc /path/to/folder
```
-snh   → Store hard links as links (not duplicate files)

-snl   → Store symbolic links as links (don’t follow them)
