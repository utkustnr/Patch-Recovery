#!/bin/bash

if [ -f recovery.img.lz4 ];then
	lz4 -B6 --content-size -f recovery.img.lz4 recovery.img
fi

off=$(grep -ab -o SEANDROIDENFORCE recovery.img |tail -n 1 |cut -d : -f 1)
dd if=recovery.img of=r.img bs=4k count=$off iflag=count_bytes

if [ ! -f phh.pem ];then
    openssl genrsa -f4 -out phh.pem 4096
fi

mkdir unpack
cd unpack
../magiskboot unpack ../r.img
../magiskboot cpio ramdisk.cpio extract
# Reverse fastbootd ENG mode check
../magiskboot hexpatch system/bin/recovery e10313aaf40300aa6ecc009420010034 e10313aaf40300aa6ecc0094 # 20 01 00 35
../magiskboot hexpatch system/bin/recovery eec3009420010034 eec3009420010035
../magiskboot hexpatch system/bin/recovery 3ad3009420010034 3ad3009420010035
../magiskboot hexpatch system/bin/recovery 50c0009420010034 50c0009420010035
../magiskboot hexpatch system/bin/recovery 080109aae80000b4 080109aae80000b5
../magiskboot hexpatch system/bin/recovery 20f0a6ef38b1681c 20f0a6ef38b9681c
../magiskboot hexpatch system/bin/recovery 23f03aed38b1681c 23f03aed38b9681c
../magiskboot hexpatch system/bin/recovery 20f09eef38b1681c 20f09eef38b9681c
../magiskboot hexpatch system/bin/recovery 26f0ceec30b1681c 26f0ceec30b9681c
../magiskboot hexpatch system/bin/recovery 24f0fcee30b1681c 24f0fcee30b9681c
../magiskboot hexpatch system/bin/recovery 27f02eeb30b1681c 27f02eeb30b9681c
../magiskboot hexpatch system/bin/recovery b4f082ee28b1701c b4f082ee28b970c1
../magiskboot hexpatch system/bin/recovery 9ef0f4ec28b1701c 9ef0f4ec28b9701c
../magiskboot cpio ramdisk.cpio 'add 0755 system/bin/recovery system/bin/recovery'
../magiskboot repack ../r.img ../new-boot.img
cp ../new-boot.img ../recovery-patched.img
cd ..
rm -rf new-boot.img r.img recovery.img unpack phh.pem