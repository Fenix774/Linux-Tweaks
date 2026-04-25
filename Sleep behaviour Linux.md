Usually on Linux Laptops use "s2idle" sleep mode. This can drain up to 10% battery in sleep each day.

Check sleep setting:
cat /sys/power/mem_sleep


Edit this file:
sudo nano /etc/default/grub

Edit the line "GRUB_CMDLINE_LINUX=" to include:
mem_sleep_default=deep
It may look like this afterwards:
GRUB_CMDLINE_LINUX="rd.luks.uuid=luks-12345678-abcd-1234-abcd-123456789abc rhgb quiet video=1920x1080 mem_sleep_default=deep"

Reload grub:
sudo grub2-mkconfig -o /etc/grub2.cfg
