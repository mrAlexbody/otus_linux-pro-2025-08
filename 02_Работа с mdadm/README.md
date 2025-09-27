Домашнее задание 02
=
#### "Работа с mdadm"

### Цель:
+ научиться использовать утилиту для управления программными RAID-массивами в Linux;

### Описание/Пошаговая инструкция выполнения домашнего задания:

### 🎯 Задание

+ Добавьте в виртуальную машину несколько дисков

+ Соберите RAID-0/1/5/10 на выбор

+ Сломайте и почините RAID

+ Создайте GPT таблицу, пять разделов и смонтируйте их в системе.

---
Конфигурация VM сервера:
+ Memory: 4GB
+ Processor: 2 CPU
+ Hard Disk  (SCSI): 30 GB
+ Hard Disk2 (SCSI): 5GB
+ Hard Disk3 (SCSI): 5GB
+ Hard Disk4 (SCSI): 5GB
+ Hard Disk5 (SCSI): 5GB
+ OS Linux: Ubuntu 24.04 LTS
+ Core: 6.8.0-83-generic
---
> Запуск VM смотрим какие блочные устройства есть:
```shell
amyskin@vm02:/home/ofdadmin$ sudo lshw -class disk
  *-disk:0
       description: SCSI Disk
       product: VMware Virtual S
       vendor: VMware,
       physical id: 0.0.0
       bus info: scsi@32:0.0.0
       logical name: /dev/sda
       version: 1.0
       size: 30GiB (32GB)
       capabilities: 7200rpm gpt-1.00 partitioned partitioned:gpt
       configuration: ansiversion=2 guid=88c62cd1-c2b6-4df5-b8d3-1833c73b660c logicalsectorsize=512 sectorsize=512
  *-disk:1
       description: SCSI Disk
       product: VMware Virtual S
       vendor: VMware,
       physical id: 0.1.0
       bus info: scsi@32:0.1.0
       logical name: /dev/sdb
       version: 1.0
       size: 5GiB (5368MB)
       capabilities: 7200rpm
       configuration: ansiversion=2 logicalsectorsize=512 sectorsize=512
  *-disk:2
       description: SCSI Disk
       product: VMware Virtual S
       vendor: VMware,
       physical id: 0.2.0
       bus info: scsi@32:0.2.0
       logical name: /dev/sdc
       version: 1.0
       size: 5GiB (5368MB)
       capabilities: 7200rpm
       configuration: ansiversion=2 logicalsectorsize=512 sectorsize=512
  *-disk:3
       description: SCSI Disk
       product: VMware Virtual S
       vendor: VMware,
       physical id: 0.3.0
       bus info: scsi@32:0.3.0
       logical name: /dev/sdd
       version: 1.0
       size: 5GiB (5368MB)
       capabilities: 7200rpm
       configuration: ansiversion=2 logicalsectorsize=512 sectorsize=512
  *-disk:4
       description: SCSI Disk
       product: VMware Virtual S
       vendor: VMware,
       physical id: 0.4.0
       bus info: scsi@32:0.4.0
       logical name: /dev/sde
       version: 1.0
       size: 5GiB (5368MB)
       capabilities: 7200rpm
       configuration: ansiversion=2 logicalsectorsize=512 sectorsize=512
  *-cdrom
       description: DVD-RAM writer
       product: VMware SATA CD01
       vendor: NECVMWar
       physical id: 0.0.0
       bus info: scsi@3:0.0.0
       logical name: /dev/cdrom
       logical name: /dev/sr0
       version: 1.00
       capabilities: removable audio cd-r cd-rw dvd dvd-r dvd-ram
       configuration: ansiversion=5 status=ready
     *-medium
          physical id: 0
          logical name: /dev/cdrom
          capabilities: gpt-1.00 partitioned partitioned:gpt
          configuration: guid=208735e8-0bfb-4630-81a1-295dd9a30afa
```
>> или так:
```shell
amyskin@vm02:/home/ofdadmin$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   30G  0 disk
??sda1   8:1    0    1M  0 part
??sda2   8:2    0   30G  0 part /
sdb      8:16   0    5G  0 disk
sdc      8:32   0    5G  0 disk
sdd      8:48   0    5G  0 disk
sde      8:64   0    5G  0 disk
sr0     11:0    1  2.6G  0 rom
```
> Занулил на всякий случай суперблоки:
```shell
root@vm02:~# mdadm --zero-superblock --force /dev/sd{b,c,d,e}
mdadm: Unrecognised md component device - /dev/sdb
mdadm: Unrecognised md component device - /dev/sdc
mdadm: Unrecognised md component device - /dev/sdd
mdadm: Unrecognised md component device - /dev/sde
```
>Создал RAID5 из 4 дисков:
```shell
root@vm02:~# mdadm --create --verbose /dev/md0 --level=5 --raid-devices=4 /dev/sd{b,c,d,e}
mdadm: layout defaults to left-symmetric
mdadm: layout defaults to left-symmetric
mdadm: chunk size defaults to 512K
mdadm: size set to 5237760K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```
>Проверил состояние массиыв:
```shell
root@vm02:~# mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Wed Sep 24 09:01:27 2025
        Raid Level : raid5
        Array Size : 15713280 (14.99 GiB 16.09 GB)
     Used Dev Size : 5237760 (5.00 GiB 5.36 GB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Wed Sep 24 09:01:36 2025
             State : clean, degraded, recovering
    Active Devices : 3
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 1

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

    Rebuild Status : 21% complete

              Name : vm02:0  (local to host vm02)
              UUID : 2ce350c5:aef90c0a:128bc473:5246ea4a
            Events : 4

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       4       8       64        3      spare rebuilding   /dev/sde

root@vm02:~# cat /proc/mdstat
Personalities : [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md0 : active raid5 sde[4] sdd[2] sdc[1] sdb[0]
      15713280 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/4] [UUUU]
```
>RAID5 собран! 
>>Сгенерирую рандомно на него фалы, подмонтирую в систему , а потом сломаю.
>>Сначало отформатировал под фс ext4, для наглядности:
```shell
root@vm02:~# mkfs.ext4 /dev/md0
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 3928320 4k blocks and 983040 inodes
Filesystem UUID: 441b11f8-3ae1-49a6-8f10-8bbc2441b9c7
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```
>Нашёл UUID массива md0:
```shell
root@vm02:~# lsblk -o NAME,SIZE,TYPE,UUID
NAME    SIZE TYPE  UUID
sda     30G disk
├─sda1    1M part
└─sda2   30G part  635ca116-c0a3-41e2-8edd-a7884c9e7041
sdb       5G disk  2ce350c5-aef9-0c0a-128b-c4735246ea4a
└─md0    15G raid5 441b11f8-3ae1-49a6-8f10-8bbc2441b9c7
sdc       5G disk  2ce350c5-aef9-0c0a-128b-c4735246ea4a
└─md0    15G raid5 441b11f8-3ae1-49a6-8f10-8bbc2441b9c7
sdd       5G disk  2ce350c5-aef9-0c0a-128b-c4735246ea4a
└─md0    15G raid5 441b11f8-3ae1-49a6-8f10-8bbc2441b9c7
sde       5G disk  2ce350c5-aef9-0c0a-128b-c4735246ea4a
└─md0    15G raid5 441b11f8-3ae1-49a6-8f10-8bbc2441b9c7
sr0     2.6G rom   2024-04-23-12-46-09-00

```
>Создадал директорию, куда буду монтировать массив:
```shell
root@vm02:~# mkdir /mnt/u1
```
>Записал в конфигурационный файл, куда будет монтироваться массив после перезагрузки:
```shell
root@vm02:~# uuid=`ls -la /dev/disk/by-uuid/ | fgrep md0 | awk '{print $9}'` && echo "/dev/disk/by-uuid/$uuid /mnt/u1 ext4 defaults 0 1" >> /etc/fstab
root@vm02:~# cat /etc/fstab
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/sda2 during curtin installation
/dev/disk/by-uuid/635ca116-c0a3-41e2-8edd-a7884c9e7041 / ext4 defaults 0 1
/swap.img       none    swap    sw      0       0
#/dev/disk/by-uuid/441b11f8-3ae1-49a6-8f10-8bbc2441b9c7
/dev/disk/by-uuid/441b11f8-3ae1-49a6-8f10-8bbc2441b9c7 /mnt/u1 ext4 defaults 0 1
```
>Создал рандомных файлов:
```shell
root@vm02:~# cd /mnt/u1
root@vm02:/mnt/u1# mkdir test_dir
root@vm02:/mnt/u1# cd ./test_dir/
root@vm02:/mnt/u1/test_dir# ls -la
total 8
root@vm02:/mnt/u1/test_dir# for i in {1..1000}; do dd if=/dev/zero of="test_file_$i.dat" bs=1M count=10 status=none; done
root@vm02:/mnt/u1/test_dir# ls -la
total 10240048
drwxr-xr-x 2 root root    45056 Sep 24 09:20 .
drwxr-xr-x 4 root root     4096 Sep 24 09:18 ..
-rw-r--r-- 1 root root        0 Sep 24 09:19 test_file.txt
-rw-r--r-- 1 root root 10485760 Sep 24 09:20 test_file_1.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:20 test_file_10.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_100.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:22 test_file_1000.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_101.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_102.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_103.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_104.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_105.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_106.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_107.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_108.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_109.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:20 test_file_11.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_110.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_111.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_112.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_113.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_114.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_115.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_116.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_117.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_118.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_119.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:20 test_file_12.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_120.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_121.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_122.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_123.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_124.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_125.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_126.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_127.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_128.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_129.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:20 test_file_13.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_130.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_131.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_132.dat
-rw-r--r-- 1 root root 10485760 Sep 24 09:21 test_file_133.dat
... и.д. там их много
```
>Проверил сколько занимают данные в массиве:
```shell
root@vm02:/mnt/u1/test_dir# df -hT
Filesystem     Type   Size  Used Avail Use% Mounted on
tmpfs          tmpfs  387M  1.1M  386M   1% /run
/dev/sda2      ext4    30G  6.1G   22G  22% /
tmpfs          tmpfs  1.9G     0  1.9G   0% /dev/shm
tmpfs          tmpfs  5.0M     0  5.0M   0% /run/lock
/dev/md127     ext4    15G  9.8G  4.2G  71% /mnt/u1
tmpfs          tmpfs  387M   12K  387M   1% /run/user/1000
```
>Перезагрузил систему, массив подмонтировался нормально теперб он /dev/md127 =):
```shell
root@vm02:/mnt/u1/test_dir# mdadm -D /dev/md127
/dev/md127:
           Version : 1.2
     Creation Time : Wed Sep 24 09:01:27 2025
        Raid Level : raid5
        Array Size : 15713280 (14.99 GiB 16.09 GB)
     Used Dev Size : 5237760 (5.00 GiB 5.36 GB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Wed Sep 24 09:22:11 2025
             State : clean
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : vm02:0  (local to host vm02)
              UUID : 2ce350c5:aef90c0a:128bc473:5246ea4a
            Events : 20

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       4       8       64        3      active sync   /dev/sde
root@vm02:/mnt/u1/test_dir# cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [raid0] [raid1] [raid10]
md127 : active raid5 sdd[2] sde[4] sdc[1] sdb[0]
      15713280 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/4] [UUUU]
```
>Сломал RAID5 массив:
```shell
root@vm02:/mnt/u1/test_dir# mdadm /dev/md127 --fail /dev/sdb
mdadm: set /dev/sdb faulty in /dev/md127

root@vm02:/mnt/u1/test_dir# cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [raid0] [raid1] [raid10]
md127 : active raid5 sdd[2] sde[4] sdc[1] sdb[0](F)
      15713280 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/3] [_UUU]
unused devices: <none>

root@vm02:/mnt/u1/test_dir# mdadm -D /dev/md127
/dev/md127:
           Version : 1.2
     Creation Time : Wed Sep 24 09:01:27 2025
        Raid Level : raid5
        Array Size : 15713280 (14.99 GiB 16.09 GB)
     Used Dev Size : 5237760 (5.00 GiB 5.36 GB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Wed Sep 24 09:25:39 2025
             State : clean, degraded
    Active Devices : 3
   Working Devices : 3
    Failed Devices : 1
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : vm02:0  (local to host vm02)
              UUID : 2ce350c5:aef90c0a:128bc473:5246ea4a
            Events : 22

    Number   Major   Minor   RaidDevice State
       -       0        0        0      removed
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       4       8       64        3      active sync   /dev/sde

       0       8       16        -      faulty   /dev/sdb
```
>Удалил диск:
```shell
root@vm02:/mnt/u1/test_dir# mdadm /dev/md127 --remove /dev/sdb
```
>Починил
>>Подмонтировал новый диск:
```shell
root@vm02:/mnt/u1/test_dir# mdadm --zero-superblock --force /dev/sdb
root@vm02:/mnt/u1/test_dir# mdadm /dev/md127 --add /dev/sdb
```
>Запустился ребилд:
```shell
root@vm02:/mnt/u1/test_dir# cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [raid0] [raid1] [raid10]
md127 : active raid5 sdb[5] sdd[2] sde[4] sdc[1]
      15713280 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/3] [_UUU]
      [=====>...............]  recovery = 26.9% (1409884/5237760) finish=0.3min speed=201412K/sec

```
>Создание, поломка и починка RAID массива на этом закончена:
```shell
root@vm02:~# cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [raid0] [raid1] [raid10]
md127 : active raid5 sdb[5] sdd[2] sde[4] sdc[1]
      15713280 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/4] [UUUU]

unused devices: <none>
root@vm02:~# mdadm -D /dev/md127
/dev/md127:
           Version : 1.2
     Creation Time : Wed Sep 24 09:01:27 2025
        Raid Level : raid5
        Array Size : 15713280 (14.99 GiB 16.09 GB)
     Used Dev Size : 5237760 (5.00 GiB 5.36 GB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Wed Sep 24 09:29:11 2025
             State : clean
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : vm02:0  (local to host vm02)
              UUID : 2ce350c5:aef90c0a:128bc473:5246ea4a
            Events : 42

    Number   Major   Minor   RaidDevice State
       5       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       4       8       64        3      active sync   /dev/sde
```
>После приступил к создаеию GPT таблицы, пяти разделов и смонтировал их в систему.
>>Подготовка:
```shell
oot@vm02:~# umount /mnt/u1
root@vm02:~# ls /mnt/u1
root@vm02:~# apt install parted
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  dmidecode libparted2t64
Suggested packages:
  libparted-dev libparted-i18n parted-doc
The following NEW packages will be installed:
  dmidecode libparted2t64 parted
0 upgraded, 3 newly installed, 0 to remove and 0 not upgraded.
Need to get 268 kB of archives.
After this operation, 758 kB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 dmidecode amd64 3.5-3ubuntu0.1 [73.0 kB]
Get:2 http://ru.archive.ubuntu.com/ubuntu noble/main amd64 libparted2t64 amd64 3.6-4build1 [152 kB]
Get:3 http://ru.archive.ubuntu.com/ubuntu noble/main amd64 parted amd64 3.6-4build1 [43.3 kB]
Fetched 268 kB in 30s (9032 B/s)
debconf: delaying package configuration, since apt-utils is not installed
Selecting previously unselected package dmidecode.
(Reading database ... 73844 files and directories currently installed.)
Preparing to unpack .../dmidecode_3.5-3ubuntu0.1_amd64.deb ...
Unpacking dmidecode (3.5-3ubuntu0.1) ...
Selecting previously unselected package libparted2t64:amd64.
Preparing to unpack .../libparted2t64_3.6-4build1_amd64.deb ...
Adding 'diversion of /lib/x86_64-linux-gnu/libparted.so.2 to /lib/x86_64-linux-gnu/libparted.so.2.usr-is-merged by libparted2t64'
Adding 'diversion of /lib/x86_64-linux-gnu/libparted.so.2.0.5 to /lib/x86_64-linux-gnu/libparted.so.2.0.5.usr-is-merged by libparted2t64'
Unpacking libparted2t64:amd64 (3.6-4build1) ...
Selecting previously unselected package parted.
Preparing to unpack .../parted_3.6-4build1_amd64.deb ...
Unpacking parted (3.6-4build1) ...
Setting up dmidecode (3.5-3ubuntu0.1) ...
Setting up libparted2t64:amd64 (3.6-4build1) ...
Removing 'diversion of /lib/x86_64-linux-gnu/libparted.so.2 to /lib/x86_64-linux-gnu/libparted.so.2.usr-is-merged by libparted2t64'
Removing 'diversion of /lib/x86_64-linux-gnu/libparted.so.2.0.5 to /lib/x86_64-linux-gnu/libparted.so.2.0.5.usr-is-merged by libparted2t64'
Setting up parted (3.6-4build1) ...
Processing triggers for libc-bin (2.39-0ubuntu8.5) ...
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
```
>Создал раздел GPT на RAID массиве
```shell
root@vm02:~# parted -s /dev/md127  mklabel gpt
```
>Разбил на партиции:
```shell
root@vm02:~# parted /dev/md127 mkpart primaruy ext4 0%
End? 20%
Information: You may need to update /etc/fstab.

root@vm02:~# parted /dev/md127 mkpart primaruy ext4 20%
End? 40%
Information: You may need to update /etc/fstab.

root@vm02:~# parted /dev/md127 mkpart primaruy ext4 40%
End? 60%
Information: You may need to update /etc/fstab.

root@vm02:~# parted /dev/md127 mkpart primaruy ext4 60%
End? 80%
Information: You may need to update /etc/fstab.

root@vm02:~# parted /dev/md127 mkpart primaruy ext4 80%
End? 100%

```
>Создал  ФС и подмонтировал в систему:
```shell
root@vm02:~# for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md127p$i; done
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 785280 4k blocks and 196608 inodes
Filesystem UUID: 00759f2a-7f96-4a18-9074-19f433f11d7b
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 785664 4k blocks and 196608 inodes
Filesystem UUID: cf444261-e836-4118-b1a3-9e0daabd6c1d
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 785664 4k blocks and 196608 inodes
Filesystem UUID: c578aab2-2ef8-4aa8-8333-c4616b011f19
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 785664 4k blocks and 196608 inodes
Filesystem UUID: b9b5a648-f0e9-411f-ad3c-2f08261c418a
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 785280 4k blocks and 196608 inodes
Filesystem UUID: 4e6ccb8e-2c0f-4081-bd83-be5ada891342
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```
```shell
root@vm02:~# mkdir -p /raid/part{1,2,3,4,5}
root@vm02:~# for i in $(seq 1 5); do mount /dev/md127p$i /raid/part$i; done
root@vm02:~# ls -la /raid/part*
/raid/part1:
total 24
drwxr-xr-x 3 root root  4096 Sep 24 09:50 .
drwxr-xr-x 7 root root  4096 Sep 24 09:51 ..
drwx------ 2 root root 16384 Sep 24 09:50 lost+found

/raid/part2:
total 24
drwxr-xr-x 3 root root  4096 Sep 24 09:50 .
drwxr-xr-x 7 root root  4096 Sep 24 09:51 ..
drwx------ 2 root root 16384 Sep 24 09:50 lost+found

/raid/part3:
total 24
drwxr-xr-x 3 root root  4096 Sep 24 09:50 .
drwxr-xr-x 7 root root  4096 Sep 24 09:51 ..
drwx------ 2 root root 16384 Sep 24 09:50 lost+found

/raid/part4:
total 24
drwxr-xr-x 3 root root  4096 Sep 24 09:50 .
drwxr-xr-x 7 root root  4096 Sep 24 09:51 ..
drwx------ 2 root root 16384 Sep 24 09:50 lost+found

/raid/part5:
total 24
drwxr-xr-x 3 root root  4096 Sep 24 09:50 .
drwxr-xr-x 7 root root  4096 Sep 24 09:51 ..
```
>Вот что получилось:
```shell
root@vm02:~# lsblk -o NAME,SIZE,TYPE,UUID
NAME         SIZE TYPE  UUID
sda           30G disk
├─sda1         1M part
└─sda2        30G part  635ca116-c0a3-41e2-8edd-a7884c9e7041
sdb            5G disk  2ce350c5-aef9-0c0a-128b-c4735246ea4a
└─md127       15G raid5
  ├─md127p1    3G part  00759f2a-7f96-4a18-9074-19f433f11d7b
  ├─md127p2    3G part  cf444261-e836-4118-b1a3-9e0daabd6c1d
  ├─md127p3    3G part  c578aab2-2ef8-4aa8-8333-c4616b011f19
  ├─md127p4    3G part  b9b5a648-f0e9-411f-ad3c-2f08261c418a
  └─md127p5    3G part  4e6ccb8e-2c0f-4081-bd83-be5ada891342
sdc            5G disk  2ce350c5-aef9-0c0a-128b-c4735246ea4a
└─md127       15G raid5
  ├─md127p1    3G part  00759f2a-7f96-4a18-9074-19f433f11d7b
  ├─md127p2    3G part  cf444261-e836-4118-b1a3-9e0daabd6c1d
  ├─md127p3    3G part  c578aab2-2ef8-4aa8-8333-c4616b011f19
  ├─md127p4    3G part  b9b5a648-f0e9-411f-ad3c-2f08261c418a
  └─md127p5    3G part  4e6ccb8e-2c0f-4081-bd83-be5ada891342
sdd            5G disk  2ce350c5-aef9-0c0a-128b-c4735246ea4a
└─md127       15G raid5
  ├─md127p1    3G part  00759f2a-7f96-4a18-9074-19f433f11d7b
  ├─md127p2    3G part  cf444261-e836-4118-b1a3-9e0daabd6c1d
  ├─md127p3    3G part  c578aab2-2ef8-4aa8-8333-c4616b011f19
  ├─md127p4    3G part  b9b5a648-f0e9-411f-ad3c-2f08261c418a
  └─md127p5    3G part  4e6ccb8e-2c0f-4081-bd83-be5ada891342
sde            5G disk  2ce350c5-aef9-0c0a-128b-c4735246ea4a
└─md127       15G raid5
  ├─md127p1    3G part  00759f2a-7f96-4a18-9074-19f433f11d7b
  ├─md127p2    3G part  cf444261-e836-4118-b1a3-9e0daabd6c1d
  ├─md127p3    3G part  c578aab2-2ef8-4aa8-8333-c4616b011f19
  ├─md127p4    3G part  b9b5a648-f0e9-411f-ad3c-2f08261c418a
  └─md127p5    3G part  4e6ccb8e-2c0f-4081-bd83-be5ada891342
sr0          2.6G rom   2024-04-23-12-46-09-00
```
EOF
