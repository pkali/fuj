# fuj - Fujinet Ultra Jukebox 
Atari 8-bit FujiNet micro-loader.

Its goal is not to replace FN Config, but to allow for quick and easy loading of games and demos from various TNFS sites.
`xex` files are not mounted as a bootable disks, but loaded immediately, `atr` files mounted and rebooted without pressing [Return] key 3 times and wondering where am I and what I am doing here with the old mounted file name on the screen.

`fuj` core is based on Micro Sparta DOS loading mechanisms and offers a very low `MEMLO`, easily starting up almost all available `xex` files around.

* quicker to load than FN Config
* uses UltraSpeed procedures to allow for a maximum transfer speed on any Atari OS
* turns off BASIC automagically
* loads `xex` files instantly
* remembers your last position in the TNFS directories making it easier for browsing huge libraries of games and demos

It was born out of frustration with the FN Config process of mounting `xex` files and practical impossibility of quick viewing several demos one after another buried somewhere on TNFS servers.

References:
FujiNet device SIO commands: https://github.com/FujiNetWIFI/fujinet-firmware/wiki/SIO-Commands-for-Device-ID-%2470

FujiNet N: device commands:
https://github.com/FujiNetWIFI/fujinet-firmware/wiki/SIO-Commands-for-Device-IDs-%2471-to-%2478