https://github.com/dlundqvist/xone/releases/tag/v0.4.11
https://github.com/dlundqvist/xone

Guide

    Unplug your Xbox devices.

    Clone the repository:

git clone https://github.com/dlundqvist/xone

    Install xone:

cd xone
sudo make install

NOTE: You can use the install-debug target instead to enable debug logging.

    Download the firmware for the wireless dongle (optional, makefile automatically installs firmware):

sudo install/firmware.sh

NOTE: The --skip-disclaimer flag might be useful for scripting purposes.

    Plug in your Xbox devices.

Updating

Just run the install script again after pulling the newset changes from the repository.

git pull
sudo make install

Reboot is highly suggested
