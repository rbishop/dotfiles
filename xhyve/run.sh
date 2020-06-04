#!/bin/sh

xhyve \
  -A \
  -P \
  -H \
  -U 28AD306C-EFED-49EB-A196-1332013C2B9D \
  -c 4 \
  -m 4G \
  -s 0,hostbridge \
  -s 2,virtio-net \
  -s 4,virtio-blk,hdd.img \
  -s 31,lpc \
  -l com1,stdio \
  -f kexec,vmlinuz-5.5.5,initrd.img-5.5.5,"console=ttyS0 root=/dev/vda1"

  #-s 3,ahci-cd,debian-10.0.0-amd64-netinst.iso \
  #-f kexec,vmlinuz-4.19.0-5-amd64,initrd.img-4.19.0-5-amd64,"earlyprintk=serial console=ttyS0 root=/dev/vda1"
  #-f kexec,vmlinuz-5.4.6,initrd.img-5.4.6,"earlyprintk=serial console=ttyS0 root=/dev/vda1"
