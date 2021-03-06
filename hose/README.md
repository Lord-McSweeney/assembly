This directory contains assembly files that can be compiled into basic operating systems.
`serialcom.asm` will repeat anything you type into the COM1 port.
`text.asm` allows for writing text (in text mode, not graphical mode), allowing you to use the arrow keys, and pressing `ALT + 1-5` will allow you to use colored text.
`cmd.asm` gives you a simple shell, with the three commands `fil?`, `exit`, and `wait`. `exit` and `wait` are simple, but `fil?` will determine if the given command exists.

Example:
```
cmd> fil? exit
exit
cmd> fil? wait
wait
cmd> fil? !@#$

cmd> wait
[495 millisecond pause]
cmd> exit
[the CPU halts]
```

`loadboot.asm` is the bootloader for all of these. These programs expect to be run from 0x7e00, which the bootloader will do, if run correctly.

`hoseprog.asm` can be compiled into a raw binary that can be run from Hose. However, Hose can run only 27 byte binaries. Interrupts 0x60, 0x61, and 0x62 can be used.

All the files that end in `.bin` are binaries that can be run from an emulator, except `hoseprog.bin`, which can be run from Hose.

`cmdraw.asm` can be directly compiled and run. Check the file for more information.


UPDATE (Dec 15 2021)

cmd2.asm- Hose updated

64 byte files (55 byte body, 8 byte filename)

8 files

Loads from disk/diskette/CD-ROM (8 sectors)

Current files:
```
halt.lbc
wait.lbc [time]
cmd?.lbc
prnt.lbc
echo.lbc [string]
list.lbc
read.lbc [filename]
ftyp.txt
```
