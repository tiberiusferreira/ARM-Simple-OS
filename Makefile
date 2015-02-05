all:
    arm-eabi-gcc -c -ggdb usrcode.s -o usrcode.o
    arm-eabi-gcc -c -ggdb ra139187.s -o ra139187.o
    arm-eabi-ld usrcode.o -o usrcode  -Ttext=0x77802000 -Tdata=0x77802500
    arm-eabi-ld ra139187.o -o ra139187  --section-start=.iv=0x778005e0 -Ttext=0x77800700 -Tdata=0x77801800 -e 0x778005e0
	mksd.sh --so ra139187 --user usrcode
	arm-sim --rom=dumboot.bin --sd=disk.img -g --gdb-port=5005