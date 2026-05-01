Identify device:
upower -e

Get more info:
upower -i /org/freedesktop/UPower/devices/battery_hid_abcdefghijkx12345_battery

Output may look something like this:
  native-path:          hid_abcdefghijkx12345_battery
  model:                <model_name_of_hid_device>
  power supply:         no
  updated:              Do 01 Jan 1970 01:00:00 CET (1223456008 seconds ago)
  has history:          yes
  has statistics:       yes
  tablet
    warning-level:       none
    percentage:          0%
    icon-name:          'battery-missing-symbolic'


Create udev rule:
sudo nano /etc/udev/rules.d/99-ignore-battery-hid.rules

Paste this (replace with correct model name):
SUBSYSTEM=="power_supply", ATTR{model_name}=="<model_name_of_hid_device>", OPTIONS+="ignore_device"

Reload udev rules:
sudo udevadm control --reload
sudo udevadm trigger

Restart UPower (or reboot):
systemctl restart upower

