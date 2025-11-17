https://www.reddit.com/r/linux_gaming/comments/1lug3tv/i_found_why_kde_dont_feel_smooth_on_newer_nvidia/

A bit late but you can find your clocks using:
```
nvidia-smi --query-supported-clocks=gr,mem --format=csv
```
then you can use these:
```
nvidia-smi -lgc <minGpuClock,maxGpuClock>
nvidia-smi -lmc <minMemClock,maxMemClock>
```
For example these ranges:
1005 MHz - 3150 MHz
810 MHz - 11201 MHz
```
sudo nvidia-smi -lgc 1500,3150
sudo nvidia-smi -lmc 5001,11201
```
enable persistence:
```
sudo nvidia-smi -pm 1
```
disable persistence:
```
sudo nvidia-smi -pm 0
```
