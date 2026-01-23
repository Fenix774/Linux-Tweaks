Make a *.sh file with these contents. Don't forget to make the file executable with "chmod +x *.sh":

```
#!/bin/bash

konsole -e "bash -c 'set +x;

echo \"Running: sudo dnf upgrade --refresh -y\";
sudo dnf upgrade --refresh -y;

echo \"\";
echo \"--------------------------------------------------------------------------------------------\";
echo \"\";
echo \"\";
echo \"Running: flatpak update -y\";
sleep 3;

flatpak update -y;

echo \"\";
echo \"--------------------------------------------------------------------------------------------\";
echo \"\";
echo \"\";
echo \"Running: sudo snap refresh\";
sleep 3;

sudo snap refresh;

sleep 3;

exit; exec bash'"
```
