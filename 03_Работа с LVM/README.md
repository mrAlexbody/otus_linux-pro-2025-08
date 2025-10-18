# Домашнее задание "Работа с LVM"

### Цель:
+ создавать и управлять логическими томами в LVM;

### Описание/Пошаговая инструкция выполнения домашнего задания:
### 🎯 Задание

На виртуальной машине с Ubuntu 24.04 и LVM:
+ Уменьшить том под / до 8G.
+ Выделить том под /home.
+ Выделить том под /var - сделать в mirror.
+ /home - сделать том для снапшотов.
+ Прописать монтирование в fstab. Попробовать с разными опциями и разными файловыми системами (на выбор).

Работа со снапшотами:
+ сгенерить файлы в /home/;
+ снять снапшот;
+ удалить часть файлов;
+ восстановиться со снапшота.

###⭐️Задание со звездочкой

+ На дисках поставить btrfs/zfs — с кэшем, снапшотами и разметить там каталог /opt.
+ Логировать работу можно с помощью утилиты script.
---
##Начало работы:
```shell
root@linux:~# lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 24.04 LTS
Release:        24.04
Codename:       noble

root@linux:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
fd0                         2:0    1    4K  0 disk
sda                         8:0    0   60G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1,8G  0 part /boot
└─sda3                      8:3    0 18,2G  0 part
  └─ubuntu--vg-ubuntu--lv 252:0    0   10G  0 lvm  /
sdb                         8:16   0   10G  0 disk
sdc                         8:32   0   20G  0 disk
sdd                         8:48   0   30G  0 disk
sde                         8:64   0   40G  0 disk
sr0                        11:0    1 1024M  0 rom

```
>> Проверил что с LVM:
```shell
root@linux:~# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda3
  VG Name               ubuntu-vg
  PV Size               <18,23 GiB / not usable 3,00 MiB
  Allocatable           yes
  PE Size               4,00 MiB
  Total PE              4665
  Free PE               2105
  Allocated PE          2560
  PV UUID               ggNhZy-QpXA-pPfr-lQnm-E5YW-YSS8-zZ982o

root@linux:~# vgdisplay
  --- Volume group ---
  VG Name               ubuntu-vg
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               18,22 GiB
  PE Size               4,00 MiB
  Total PE              4665
  Alloc PE / Size       2560 / 10,00 GiB
  Free  PE / Size       2105 / 8,22 GiB
  VG UUID               A7LiHO-TM17-0ONo-5OJ3-5TlF-CqKq-glT9cS

root@linux:~# lvdisplay
  --- Logical volume ---
  LV Path                /dev/ubuntu-vg/ubuntu-lv
  LV Name                ubuntu-lv
  VG Name                ubuntu-vg
  LV UUID                iiWpQx-1SdI-4yRB-gy6q-51Xq-wEXM-hjZAfW
  LV Write Access        read/write
  LV Creation host, time ubuntu-server, 2025-09-09 19:08:34 +0000
  LV Status              available
  # open                 1
  LV Size                10,00 GiB
  Current LE             2560
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           252:0

root@linux:~# lvmdiskscan
  /dev/sda2 [       1,77 GiB]
  /dev/sda3 [     <18,23 GiB] LVM physical volume
  /dev/sdb  [      10,00 GiB]
  /dev/sdc  [      20,00 GiB]
  /dev/sdd  [      30,00 GiB]
  /dev/sde  [      40,00 GiB]
  4 disks
  1 partition
  0 LVM physical volume whole disks
  1 LVM physical volume
```
## Уменьшить / том до 8GB
> Подготовка временного тома для / раздела:
```shell
root@linux:~# pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
root@linux:~# vgcreate vg_root /dev/sdb
  Volume group "vg_root" successfully created
root@linux:~# lvcreate -n lv_root -l +100%FREE /dev/vg_root
  Logical volume "lv_root" created.
```
> Создание файловой системы и его монтирование:
```shell
root@linux:~# mkfs.ext4 /dev/vg_root/lv_root
mke2fs 1.47.0 (5-Feb-2023)
Discarding device blocks: done
Creating filesystem with 2620416 4k blocks and 655360 inodes
Filesystem UUID: 8c666259-6129-4239-a06b-61a3dfbe435e
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

root@linux:~# mount /dev/vg_root/lv_root /mnt
root@linux:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
fd0                         2:0    1    4K  0 disk
sda                         8:0    0   60G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1,8G  0 part /boot
└─sda3                      8:3    0 18,2G  0 part
  └─ubuntu--vg-ubuntu--lv 252:0    0   10G  0 lvm  /
sdb                         8:16   0   10G  0 disk
└─vg_root-lv_root         252:1    0   10G  0 lvm  /mnt
sdc                         8:32   0   20G  0 disk
sdd                         8:48   0   30G  0 disk
sde                         8:64   0   40G  0 disk
sr0                        11:0    1 1024M  0 rom

```
> Копирование всех данных с / в /mnt:
````shell
root@linux:~# rsync -avxHAX --progress / /mnt/
sending incremental file list
./
bin -> usr/bin
lib -> usr/lib
lib64 -> usr/lib64
sbin -> usr/sbin
swap.img
  2.038.431.744 100%  550,23MB/s    0:00:03 (xfr#1, ir-chk=1022/1028)
bin.usr-is-merged/
boot/
cdrom/
dev/
etc/
etc/.pwd.lock
              0 100%    0,00kB/s    0:00:00 (xfr#2, ir-chk=1479/1507)
etc/.resolv.conf.systemd-resolved.bak
            648 100%    1,10kB/s    0:00:00 (xfr#3, ir-chk=1478/1507)
etc/.updated
            208 100%    0,35kB/s    0:00:00 (xfr#4, ir-chk=1477/1507)
etc/adduser.conf
          3.444 100%    5,83kB/s    0:00:00 (xfr#5, ir-chk=1476/1507)
etc/bash.bashrc
          2.319 100%    3,92kB/s    0:00:00 (xfr#6, ir-chk=1475/1507)
etc/bash_completion
             45 100%    0,08kB/s    0:00:00 (xfr#7, ir-chk=1474/1507)
etc/bindresvport.blacklist
            367 100%    0,62kB/s    0:00:00 (xfr#8, ir-chk=1473/1507)
etc/ca-certificates.conf
          6.288 100%   10,62kB/s    0:00:00 (xfr#9, ir-chk=1472/1507)
etc/crontab
          1.136 100%    1,92kB/s    0:00:00 (xfr#10, ir-chk=1471/1507)
etc/crypttab
             54 100%    0,09kB/s    0:00:00 (xfr#11, ir-chk=1470/1507)
...
var/log/unattended-upgrades/unattended-upgrades.log
         30.605 100%    1,72MB/s    0:00:00 (xfr#109165, to-chk=17/132421)
var/log/unattended-upgrades/unattended-upgrades.log.1.gz
          1.779 100%  102,19kB/s    0:00:00 (xfr#109166, to-chk=16/132421)
var/mail/
var/opt/
var/snap/
var/spool/
var/spool/mail -> ../mail
var/spool/cron/
var/spool/cron/crontabs/
var/spool/rsyslog/
var/tmp/
var/tmp/systemd-private-c66ba17d91e74cbba2f40cf2036accc0-ModemManager.service-AcMmQF/
var/tmp/systemd-private-c66ba17d91e74cbba2f40cf2036accc0-ModemManager.service-AcMmQF/tmp/
var/tmp/systemd-private-c66ba17d91e74cbba2f40cf2036accc0-polkit.service-83OATW/
var/tmp/systemd-private-c66ba17d91e74cbba2f40cf2036accc0-polkit.service-83OATW/tmp/
var/tmp/systemd-private-c66ba17d91e74cbba2f40cf2036accc0-systemd-logind.service-wQ5IOh/
var/tmp/systemd-private-c66ba17d91e74cbba2f40cf2036accc0-systemd-logind.service-wQ5IOh/tmp/
var/tmp/systemd-private-c66ba17d91e74cbba2f40cf2036accc0-systemd-resolved.service-MEhVy0/
var/tmp/systemd-private-c66ba17d91e74cbba2f40cf2036accc0-systemd-resolved.service-MEhVy0/tmp/
var/tmp/systemd-private-c66ba17d91e74cbba2f40cf2036accc0-systemd-timesyncd.service-BQvHCI/
var/tmp/systemd-private-c66ba17d91e74cbba2f40cf2036accc0-systemd-timesyncd.service-BQvHCI/tmp/
var/tmp/systemd-private-c66ba17d91e74cbba2f40cf2036accc0-upower.service-9WhYUC/
var/tmp/systemd-private-c66ba17d91e74cbba2f40cf2036accc0-upower.service-9WhYUC/tmp/

sent 4.826.871.107 bytes  received 2.182.213 bytes  95.624.818,22 bytes/sec
total size is 4.822.006.864  speedup is 1,00

````
>> Проверка:
```shell
root@linux:~# ls /mnt
bin                boot   dev  home  lib64              lost+found  mnt  proc  run   sbin.usr-is-merged  srv       sys  usr
bin.usr-is-merged  cdrom  etc  lib   lib.usr-is-merged  media       opt  root  sbin  snap                swap.img  tmp  var
```
> Коонфигурация grub для того, чтобы при старте перейти в новый /. 
```shell
root@linux:~# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done

root@linux:~# ls -la /mnt
total 1990748
drwxr-xr-x  23 root root       4096 сен  9 19:10 .
drwxr-xr-x  23 root root       4096 сен  9 19:10 ..
lrwxrwxrwx   1 root root          7 апр 22  2024 bin -> usr/bin
drwxr-xr-x   2 root root       4096 фев 26  2024 bin.usr-is-merged
drwxr-xr-x   4 root root       4096 окт  2 06:39 boot
dr-xr-xr-x   2 root root       4096 апр 23  2024 cdrom
drwxr-xr-x  21 root root       4280 окт 18 12:40 dev
drwxr-xr-x 108 root root       4096 окт  1 08:22 etc
drwxr-xr-x   3 root root       4096 сен  9 19:33 home
lrwxrwxrwx   1 root root          7 апр 22  2024 lib -> usr/lib
lrwxrwxrwx   1 root root          9 апр 22  2024 lib64 -> usr/lib64
drwxr-xr-x   2 root root       4096 фев 26  2024 lib.usr-is-merged
drwx------   2 root root      16384 сен  9 19:08 lost+found
drwxr-xr-x   2 root root       4096 апр 23  2024 media
drwxr-xr-x   2 root root       4096 окт 18 12:43 mnt
drwxr-xr-x   2 root root       4096 апр 23  2024 opt
dr-xr-xr-x 266 root root          0 сен 30 16:44 proc
drwx------   3 root root       4096 сен 12 17:42 root
drwxr-xr-x  30 root root        960 окт 18 12:07 run
lrwxrwxrwx   1 root root          8 апр 22  2024 sbin -> usr/sbin
drwxr-xr-x   2 root root       4096 апр  3  2024 sbin.usr-is-merged
drwxr-xr-x   2 root root       4096 сен  9 19:33 snap
drwxr-xr-x   2 root root       4096 апр 23  2024 srv
-rw-------   1 root root 2038431744 сен  9 19:10 swap.img
dr-xr-xr-x  13 root root          0 окт 18 12:46 sys
drwxrwxrwt  13 root root       4096 окт 18 11:58 tmp
drwxr-xr-x  12 root root       4096 апр 23  2024 usr
drwxr-xr-x  13 root root       4096 сен  9 19:33 var

root@linux:~# chroot /mnt/

root@linux:/# grub-mkconfig -o /boot/grub/grub.cfg
Sourcing file `/etc/default/grub'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.8.0-85-generic
Found initrd image: /boot/initrd.img-6.8.0-85-generic
Found linux image: /boot/vmlinuz-6.8.0-79-generic
Found initrd image: /boot/initrd.img-6.8.0-79-generic
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
Adding boot menu entry for UEFI Firmware Settings ...
done

```
> Обновил образ initrd
```shell
root@linux:/# update-initramfs -u
update-initramfs: Generating /boot/initrd.img-6.8.0-85-generic
```
> Перезагрузил систему:
```shell
root@linux:/# reboot
Running in chroot, ignoring request.
root@linux:/# exit
exit
root@linux:~# reboot
Broadcast message from root@linux on pts/2 (Sat 2025-10-18 12:58:26 UTC):

The system will reboot now!

```
>> После старта:
```shell
amyskin@linux:~$ sudo -i
[sudo] password for amyskin:
root@linux:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
fd0                         2:0    1    4K  0 disk
sda                         8:0    0   60G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1,8G  0 part /boot
└─sda3                      8:3    0 18,2G  0 part
  └─ubuntu--vg-ubuntu--lv 252:1    0   10G  0 lvm
sdb                         8:16   0   10G  0 disk
└─vg_root-lv_root         252:0    0   10G  0 lvm  /
sdc                         8:32   0   20G  0 disk
sdd                         8:48   0   30G  0 disk
sde                         8:64   0   40G  0 disk
sr0                        11:0    1 1024M  0 rom

```
###Удаление старого LV размером в 40G и создание нового на 8G:
```shell
root@linux:~# lvremove /dev/ubuntu-vg/ubuntu-lv
Do you really want to remove and DISCARD active logical volume ubuntu-vg/ubuntu-lv? [y/n]: y
  Logical volume "ubuntu-lv" successfully removed.

root@linux:~# lvcreate -n ubuntu-vg/ubuntu-lv -L 8G /dev/ubuntu-vg
WARNING: ext4 signature detected on /dev/ubuntu-vg/ubuntu-lv at offset 1080. Wipe it? [y/n]: y
  Wiping ext4 signature on /dev/ubuntu-vg/ubuntu-lv.
  Logical volume "ubuntu-lv" created.


```
>Возвращение / раздела на том в 8GB:
```shell
root@linux:~# mkfs.ext4 /dev/ubuntu-vg/ubuntu-lv
mke2fs 1.47.0 (5-Feb-2023)
Discarding device blocks: done
Creating filesystem with 2097152 4k blocks and 524288 inodes
Filesystem UUID: d9048322-acf0-446b-a900-f776074799e8
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

root@linux:~# mount /dev/ubuntu-vg/ubuntu-lv /mnt
root@linux:~# rsync
rsync      rsync-ssl
root@linux:~# rsync -avxHAX --progress / /mnt/
sending incremental file list
./
bin -> usr/bin
lib -> usr/lib
lib64 -> usr/lib64
sbin -> usr/sbin
swap.img
  1.069.711.360  52%  307,36MB/s    0:00:03
...
var/log/unattended-upgrades/unattended-upgrades.log
         30.605 100%  515,31kB/s    0:00:00 (xfr#109170, to-chk=15/132422)
var/log/unattended-upgrades/unattended-upgrades.log.1.gz
          1.779 100%   29,45kB/s    0:00:00 (xfr#109171, to-chk=14/132422)
var/mail/
var/opt/
var/snap/
var/spool/
var/spool/mail -> ../mail
var/spool/cron/
var/spool/cron/crontabs/
var/spool/rsyslog/
var/tmp/
var/tmp/systemd-private-f836d8de0aff477e866163eae73879c5-ModemManager.service-7xN1h9/
var/tmp/systemd-private-f836d8de0aff477e866163eae73879c5-ModemManager.service-7xN1h9/tmp/
var/tmp/systemd-private-f836d8de0aff477e866163eae73879c5-polkit.service-AP2x9f/
var/tmp/systemd-private-f836d8de0aff477e866163eae73879c5-polkit.service-AP2x9f/tmp/
var/tmp/systemd-private-f836d8de0aff477e866163eae73879c5-systemd-logind.service-WgrrrY/
var/tmp/systemd-private-f836d8de0aff477e866163eae73879c5-systemd-logind.service-WgrrrY/tmp/
var/tmp/systemd-private-f836d8de0aff477e866163eae73879c5-systemd-resolved.service-irpBsw/
var/tmp/systemd-private-f836d8de0aff477e866163eae73879c5-systemd-resolved.service-irpBsw/tmp/
var/tmp/systemd-private-f836d8de0aff477e866163eae73879c5-systemd-timesyncd.service-tsw5Va/
var/tmp/systemd-private-f836d8de0aff477e866163eae73879c5-systemd-timesyncd.service-tsw5Va/tmp/

sent 4.852.237.684 bytes  received 2.182.175 bytes  77.670.717,74 bytes/sec
total size is 4.847.363.006  speedup is 1,00

```
> Конфигурация grub:
```shell
root@linux:~# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done

root@linux:~# ls /mnt
bin                boot   dev  home  lib64              lost+found  mnt  proc  run   sbin.usr-is-merged  srv       sys  usr
bin.usr-is-merged  cdrom  etc  lib   lib.usr-is-merged  media       opt  root  sbin  snap                swap.img  tmp  var

root@linux:~# chroot /mnt/

root@linux:/# grub-mkconfig -o /boot/grub/grub.cfg
Sourcing file `/etc/default/grub'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.8.0-85-generic
Found initrd image: /boot/initrd.img-6.8.0-85-generic
Found linux image: /boot/vmlinuz-6.8.0-79-generic
Found initrd image: /boot/initrd.img-6.8.0-79-generic
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
Adding boot menu entry for UEFI Firmware Settings ...
done
root@linux:/# update-initramfs -u
update-initramfs: Generating /boot/initrd.img-6.8.0-85-generic
W: Couldn't identify type of root file system for fsck hook

```
>> Без перезагрузки!!!
##Выделил том под /var и сделал в зеркало:
> Из свободных дисков создал зеркало
```shell
root@linux:/# pvcreate /dev/sdc /dev/sdd
  Physical volume "/dev/sdc" successfully created.
  Physical volume "/dev/sdd" successfully created.
root@linux:/# vgcreate vg_var /dev/sdc /dev/sdd
  Volume group "vg_var" successfully created
root@linux:/# lvcreate -l +10%FREE -m1 -n lv_var vg_var
  Logical volume "lv_var" created.
root@linux:/# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
fd0                         2:0    1    4K  0 disk
sda                         8:0    0   60G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1,8G  0 part /boot
└─sda3                      8:3    0 18,2G  0 part
  └─ubuntu--vg-ubuntu--lv 252:1    0    8G  0 lvm  /
sdb                         8:16   0   10G  0 disk
└─vg_root-lv_root         252:0    0   10G  0 lvm
sdc                         8:32   0   20G  0 disk
├─vg_var-lv_var_rmeta_0   252:2    0    4M  0 lvm
│ └─vg_var-lv_var         252:6    0  2,5G  0 lvm
└─vg_var-lv_var_rimage_0  252:3    0  2,5G  0 lvm
  └─vg_var-lv_var         252:6    0  2,5G  0 lvm
sdd                         8:48   0   30G  0 disk
├─vg_var-lv_var_rmeta_1   252:4    0    4M  0 lvm
│ └─vg_var-lv_var         252:6    0  2,5G  0 lvm
└─vg_var-lv_var_rimage_1  252:5    0  2,5G  0 lvm
  └─vg_var-lv_var         252:6    0  2,5G  0 lvm
sde                         8:64   0   40G  0 disk
sr0                        11:0    1 1024M  0 rom

```
> Создал фс на новом и перетащил туда актуальный /var
```shell
root@linux:/# mkfs.ext4 /dev/vg_var/lv_var
mke2fs 1.47.0 (5-Feb-2023)
Discarding device blocks: done
Creating filesystem with 654336 4k blocks and 163840 inodes
Filesystem UUID: d1a085ea-c60b-4aab-9b32-30ea4dc2a9d6
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

root@linux:/# mount /dev/vg_var/lv_var /mnt
root@linux:/# mkdir /tmp/oldvar && mv /var/* /tmp/oldvar

```
>Смонтировал новый каталог var в /var и скопировал туда из старого var данные
```shell
root@linux:/# mount /dev/vg_var/lv_var /mnt

root@linux:/# mkdir /tmp/oldvar && mv /var/* /tmp/oldvar

root@linux:/# umount /mnt

root@linux:/# mount /dev/vg_var/lv_var /var

root@linux:/# echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab

root@linux:/# cat /etc/fstab
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/ubuntu-vg/ubuntu-lv during curtin installation
/dev/disk/by-id/dm-uuid-LVM-A7LiHOTM170ONo5OJ35TlFCqKqglT9cSiiWpQx1SdI4yRBgy6q51XqwEXMhjZAfW / ext4 defaults 0 1
# /boot was on /dev/sda2 during curtin installation
/dev/disk/by-uuid/bad47e9c-3ab0-471b-8ab0-83d353c77c2b /boot ext4 defaults 0 1
/swap.img       none    swap    sw      0       0
UUID="d1a085ea-c60b-4aab-9b32-30ea4dc2a9d6" /var ext4 defaults 0 0

root@linux:/# ls /var
lost+found

root@linux:/# cp -aR /tmp/oldvar/* /var/

root@linux:/# ls /var
backups  cache  crash  lib  local  lock  log  lost+found  mail  opt  run  snap  spool  tmp
```
> Перезагрузка системы !!!
>> После старта проверил
```shell
root@linux:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
fd0                         2:0    1    4K  0 disk
sda                         8:0    0   60G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1,8G  0 part /boot
└─sda3                      8:3    0 18,2G  0 part
  └─ubuntu--vg-ubuntu--lv 252:1    0    8G  0 lvm  /
sdb                         8:16   0   10G  0 disk
└─vg_root-lv_root         252:0    0   10G  0 lvm
sdc                         8:32   0   20G  0 disk
├─vg_var-lv_var_rmeta_0   252:2    0    4M  0 lvm
│ └─vg_var-lv_var         252:6    0  2,5G  0 lvm  /var
└─vg_var-lv_var_rimage_0  252:3    0  2,5G  0 lvm
  └─vg_var-lv_var         252:6    0  2,5G  0 lvm  /var
sdd                         8:48   0   30G  0 disk
├─vg_var-lv_var_rmeta_1   252:4    0    4M  0 lvm
│ └─vg_var-lv_var         252:6    0  2,5G  0 lvm  /var
└─vg_var-lv_var_rimage_1  252:5    0  2,5G  0 lvm
  └─vg_var-lv_var         252:6    0  2,5G  0 lvm  /var
sde                         8:64   0   40G  0 disk
sr0                        11:0    1 1024M  0 rom

```
> Всё ок!!! Теперь почистим от временных VolumeGroup
```shell
root@linux:~# lvremove /dev/vg_root/lv_root
Do you really want to remove and DISCARD active logical volume vg_root/lv_root? [y/n]: y
  Logical volume "lv_root" successfully removed.

root@linux:~# vgremove /dev/vg_root
  Volume group "vg_root" successfully removed

root@linux:~# pvremove /dev/sdb
  Labels on physical volume "/dev/sdb" successfully wiped.

```
## Выделить том под /home
> Создал том для /home
```shell
root@linux:~# lvcreate -n LogVol_Home -L 2G /dev/ubuntu-vg
  Logical volume "LogVol_Home" created.
root@linux:~# mkfs.ext4 /dev/ubuntu-vg/LogVol_Home
mke2fs 1.47.0 (5-Feb-2023)
Discarding device blocks: done
Creating filesystem with 524288 4k blocks and 131072 inodes
Filesystem UUID: 1bb5a269-9d82-4d5a-8803-3541c0134905
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
````
>Вренное монтирование в /mnt/
```shell
root@linux:~# mount /dev/ubuntu-vg/LogVol_Home /mnt/
```
>Копирование данных
```shell
root@linux:~# cp -aR /home/* /mnt/
```
>Замена на новый /home
```shell
root@linux:~# rm -rf /home/*
root@linux:~# umount /mnt
root@linux:~# mount /dev/ubuntu-vg/LogVol_Home /home/
root@linux:~# echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
root@linux:~# ls -la /home
total 28
drwxr-xr-x  4 root    root     4096 окт 18 13:52 .
drwxr-xr-x 23 root    root     4096 сен  9 19:10 ..
drwxr-x---  4 amyskin amyskin  4096 окт 18 13:41 amyskin
drwx------  2 root    root    16384 окт 18 13:51 lost+found

```
## Как из /home - сделать том для снапшотов.
> Создал кучу файлов в /home/tmp_files:
```shell
root@linux:~# cd /home/
root@linux:/home# mkdir tmp_files
root@linux:/home# ls
amyskin  lost+found  tmp_files
root@linux:/home# cd ./tmp_files/
root@linux:/home/tmp_files# for i in {1..1000}; do dd if=/dev/zero of="test_file_$i.dat" bs=1k count=10 status=none; done
root@linux:/home/tmp_files# ls -la
total 12044
drwxr-xr-x 2 root root 40960 окт 18 14:03 .
drwxr-xr-x 5 root root  4096 окт 18 14:03 ..
-rw-r--r-- 1 root root 10240 окт 18 14:03 test_file_1000.dat
-rw-r--r-- 1 root root 10240 окт 18 14:03 test_file_100.dat
-rw-r--r-- 1 root root 10240 окт 18 14:03 test_file_101.dat
-rw-r--r-- 1 root root 10240 окт 18 14:03 test_file_102.dat
-rw-r--r-- 1 root root 10240 окт 18 14:03 test_file_103.dat
-rw-r--r-- 1 root root 10240 окт 18 14:03 test_file_104.dat
-rw-r--r-- 1 root root 10240 окт 18 14:03 test_file_105.dat
-rw-r--r-- 1 root root 10240 окт 18 14:03 test_file_106.dat
....
-rw-r--r-- 1 root root 10240 окт 18 14:03 test_file_995.dat
-rw-r--r-- 1 root root 10240 окт 18 14:03 test_file_996.dat
-rw-r--r-- 1 root root 10240 окт 18 14:03 test_file_997.dat
-rw-r--r-- 1 root root 10240 окт 18 14:03 test_file_998.dat
-rw-r--r-- 1 root root 10240 окт 18 14:03 test_file_999.dat
-rw-r--r-- 1 root root 10240 окт 18 14:03 test_file_99.dat
-rw-r--r-- 1 root root 10240 окт 18 14:03 test_file_9.dat
```
> Проверил сколько занило место:
```shell
root@linux:/home/tmp_files# df -hT
Filesystem                         Type   Size  Used Avail Use% Mounted on
tmpfs                              tmpfs  392M  1,2M  391M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv  ext4   7,8G  4,3G  3,2G  58% /
tmpfs                              tmpfs  2,0G     0  2,0G   0% /dev/shm
tmpfs                              tmpfs  5,0M     0  5,0M   0% /run/lock
/dev/mapper/vg_var-lv_var          ext4   2,4G  598M  1,7G  26% /var
/dev/sda2                          ext4   1,8G  192M  1,5G  12% /boot
tmpfs                              tmpfs  392M   12K  392M   1% /run/user/1000
/dev/mapper/ubuntu--vg-LogVol_Home ext4   2,0G   12M  1,8G   1% /home
```
> Создал снэпшот
```shell
root@linux:/home/tmp_files# lvcreate -L 100MB -s -n home_snap /dev/ubuntu-vg/LogVol_Home
  Logical volume "home_snap" created.
```
> Удалил папку /home/tmp_files
```shell
root@linux:/home/tmp_files# cd ../
root@linux:/home# ls -la
total 68
drwxr-xr-x  5 root    root     4096 окт 18 14:03 .
drwxr-xr-x 24 root    root     4096 окт 18 14:02 ..
drwxr-x---  4 amyskin amyskin  4096 окт 18 13:41 amyskin
drwx------  2 root    root    16384 окт 18 13:51 lost+found
drwxr-xr-x  2 root    root    40960 окт 18 14:03 tmp_files
root@linux:/home# rm -rf ./tmp_files
root@linux:/home# ls -la
total 28
drwxr-xr-x  4 root    root     4096 окт 18 14:10 .
drwxr-xr-x 24 root    root     4096 окт 18 14:02 ..
drwxr-x---  4 amyskin amyskin  4096 окт 18 13:41 amyskin
drwx------  2 root    root    16384 окт 18 13:51 lost+found
root@linux:/home#

```
>Процесс востановления из снэпшота
```shell
root@linux:/# umount /home

root@linux:/# lvconvert --merge /dev/ubuntu-vg/home_snap
  Merging of volume ubuntu-vg/home_snap started.
  ubuntu-vg/LogVol_Home: Merged: 100,00%

root@linux:/# mount /dev/mapper/ubuntu--vg-LogVol_Home /home
mount: (hint) your fstab has been modified, but systemd still uses
       the old version; use 'systemctl daemon-reload' to reload.

root@linux:/# ls -la /home/
total 68
drwxr-xr-x  5 root    root     4096 окт 18 14:03 .
drwxr-xr-x 24 root    root     4096 окт 18 14:02 ..
drwxr-x---  4 amyskin amyskin  4096 окт 18 13:41 amyskin
drwx------  2 root    root    16384 окт 18 13:51 lost+found
drwxr-xr-x  2 root    root    40960 окт 18 14:03 tmp_files

```
>> Всё ок!!!
