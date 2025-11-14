Домашнее задание 04
=
###"Практические навыки работы с ZFS"

###Цель:
+ научится самостоятельно устанавливать ZFS, настраивать пулы, изучить основные возможности ZFS;


###Описание/Пошаговая инструкция выполнения домашнего задания:

##🎯 Что нужно сделать?
Определить алгоритм с наилучшим сжатием:
+ определить, какие алгоритмы сжатия поддерживает zfs (gzip, zle, lzjb, lz4);
+ создать 4 файловых системы, на каждой применить свой алгоритм сжатия;
+ для сжатия использовать либо текстовый файл, либо группу файлов.

Определить настройки пула.
+ С помощью команды zfs import собрать pool ZFS.

Командами zfs определить настройки:
+ размер хранилища;
+ тип pool;
+ значение recordsize;
+ какое сжатие используется;
+ какая контрольная сумма используется.

Работа со снапшотами:
+ скопировать файл из удаленной директории;
+ восстановить файл локально. zfs receive;
+ найти зашифрованное сообщение в файле secret_message.

---
##Определить алгоритм с наилучшим сжатием
Список всех дисков
```shell
root@zfs:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
fd0      2:0    1    4K  0 disk
sda      8:0    0   20G  0 disk
├─sda1   8:1    0    1M  0 part
└─sda2   8:2    0   20G  0 part /
sdb      8:16   0    1G  0 disk
sdc      8:32   0    1G  0 disk
sdd      8:48   0    1G  0 disk
sde      8:64   0    1G  0 disk
sdf      8:80   0    1G  0 disk
sdg      8:96   0    1G  0 disk
sdh      8:112  0    1G  0 disk
sdi      8:128  0    1G  0 disk
sr0     11:0    1 1024M  0 rom

```
Установил пакеты для ZFS
```shell
root@zfs:~# sudo apt-get install zfsutils-linux
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  libnvpair3linux libuutil3linux libzfs4linux libzpool5linux zfs-zed
Suggested packages:
  nfs-kernel-server samba-common-bin zfs-initramfs | zfs-dracut
The following NEW packages will be installed:
  libnvpair3linux libuutil3linux libzfs4linux libzpool5linux zfs-zed zfsutils-linux
0 upgraded, 6 newly installed, 0 to remove and 133 not upgraded.
Need to get 2355 kB of archives.
After this operation, 7399 kB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 libnvpair3linux amd64 2.2.2-0ubuntu9.4 [62.1 kB]
Get:2 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 libuutil3linux amd64 2.2.2-0ubuntu9.4 [53.2 kB]
Get:3 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 libzfs4linux amd64 2.2.2-0ubuntu9.4 [224 kB]
Get:4 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 libzpool5linux amd64 2.2.2-0ubuntu9.4 [1397 kB]
Get:5 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 zfsutils-linux amd64 2.2.2-0ubuntu9.4 [551 kB]
Get:6 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 zfs-zed amd64 2.2.2-0ubuntu9.4 [67.9 kB]
Fetched 2355 kB in 0s (6372 kB/s)
debconf: delaying package configuration, since apt-utils is not installed
Selecting previously unselected package libnvpair3linux.
(Reading database ... 73032 files and directories currently installed.)
Preparing to unpack .../0-libnvpair3linux_2.2.2-0ubuntu9.4_amd64.deb ...
Unpacking libnvpair3linux (2.2.2-0ubuntu9.4) ...
Selecting previously unselected package libuutil3linux.
Preparing to unpack .../1-libuutil3linux_2.2.2-0ubuntu9.4_amd64.deb ...
Unpacking libuutil3linux (2.2.2-0ubuntu9.4) ...
Selecting previously unselected package libzfs4linux.
Preparing to unpack .../2-libzfs4linux_2.2.2-0ubuntu9.4_amd64.deb ...
Unpacking libzfs4linux (2.2.2-0ubuntu9.4) ...
Selecting previously unselected package libzpool5linux.
Preparing to unpack .../3-libzpool5linux_2.2.2-0ubuntu9.4_amd64.deb ...
....
Processing triggers for libc-bin (2.39-0ubuntu8.5) ...
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.

```
Создал 4-пула из двух дисков в режиме RAID1 
```shell
root@zfs:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
fd0      2:0    1    4K  0 disk
sda      8:0    0   20G  0 disk
├─sda1   8:1    0    1M  0 part
└─sda2   8:2    0   20G  0 part /
sdb      8:16   0    1G  0 disk
sdc      8:32   0    1G  0 disk
sdd      8:48   0    1G  0 disk
sde      8:64   0    1G  0 disk
sdf      8:80   0    1G  0 disk
sdg      8:96   0    1G  0 disk
sdh      8:112  0    1G  0 disk
sdi      8:128  0    1G  0 disk
sr0     11:0    1 1024M  0 rom
root@zfs:~# zpool create pool_zfs1 /dev/sdb /dev/sdc
root@zfs:~# zpool create pool_zfs2 /dev/sdd /dev/sde
root@zfs:~# zpool create pool_zfs3 /dev/sdf /dev/sdg
root@zfs:~# zpool create pool_zfs4 /dev/sdh /dev/sdi

```
Посмотрим, что получилось
```shell
root@zfs:~# zpool status
  pool: pool_zfs1
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        pool_zfs1   ONLINE       0     0     0
          sdb       ONLINE       0     0     0
          sdc       ONLINE       0     0     0

errors: No known data errors

  pool: pool_zfs2
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        pool_zfs2   ONLINE       0     0     0
          sdd       ONLINE       0     0     0
          sde       ONLINE       0     0     0

errors: No known data errors

  pool: pool_zfs3
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        pool_zfs3   ONLINE       0     0     0
          sdf       ONLINE       0     0     0
          sdg       ONLINE       0     0     0

errors: No known data errors

  pool: pool_zfs4
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        pool_zfs4   ONLINE       0     0     0
          sdh       ONLINE       0     0     0
          sdi       ONLINE       0     0     0

errors: No known data errors
root@zfs:~# zpool list
NAME        SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
pool_zfs1  1.88G   120K  1.87G        -         -     0%     0%  1.00x    ONLINE  -
pool_zfs2  1.88G   118K  1.87G        -         -     0%     0%  1.00x    ONLINE  -
pool_zfs3  1.88G   118K  1.87G        -         -     0%     0%  1.00x    ONLINE  -
pool_zfs4  1.88G   118K  1.87G        -         -     0%     0%  1.00x    ONLINE  -

```
Добавил алгоритмы сжатия в каждую фс:
```shell
root@zfs:~# zfs set compression=lzjb pool_zfs1
root@zfs:~# zfs set compression=lz4 pool_zfs2
root@zfs:~# zfs set compression=gzip-9 pool_zfs3
root@zfs:~# zfs set compression=zle pool_zfs4
```
Посмотрим что получилось:
```shell
root@zfs:~# zfs get compression
NAME       PROPERTY     VALUE           SOURCE
pool_zfs1  compression  lzjb            local
pool_zfs2  compression  lz4             local
pool_zfs3  compression  gzip-9          local
pool_zfs4  compression  zle             local

```
Добавил во все пулы файл:
```shell
root@zfs:~# for i in {1..4}; do dd if=/dev/zero of=/pool_zfs$i/my_test_file.txt bs=100M count=100; done
100+0 records in
100+0 records out
10485760000 bytes (10 GB, 9.8 GiB) copied, 7.39607 s, 1.4 GB/s
100+0 records in
100+0 records out
10485760000 bytes (10 GB, 9.8 GiB) copied, 7.02762 s, 1.5 GB/s
100+0 records in
100+0 records out
10485760000 bytes (10 GB, 9.8 GiB) copied, 11.8606 s, 884 MB/s
100+0 records in
100+0 records out
10485760000 bytes (10 GB, 9.8 GiB) copied, 7.25273 s, 1.4 GB/s
```
Проверил что получилось:
```shell
root@zfs:~# ls -l /pool_zfs*
'/pool_zfs$':
total 0

/pool_zfs1:
total 1
-rw-r--r-- 1 root root 10485760000 Oct 23 21:06 my_test_file.txt

/pool_zfs2:
total 1
-rw-r--r-- 1 root root 10485760000 Oct 23 21:06 my_test_file.txt

/pool_zfs3:
total 1
-rw-r--r-- 1 root root 10485760000 Oct 23 21:06 my_test_file.txt

/pool_zfs4:
total 1
-rw-r--r-- 1 root root 10485760000 Oct 23 21:07 my_test_file.txt

root@zfs:~# zfs list
NAME        USED  AVAIL  REFER  MOUNTPOINT
pool_zfs1   279K  1.75G    24K  /pool_zfs1
pool_zfs2   278K  1.75G    25K  /pool_zfs2
pool_zfs3   270K  1.75G    25K  /pool_zfs3 <<<
pool_zfs4   282K  1.75G    25K  /pool_zfs4

root@zfs:~# zfs get all | grep compression
pool_zfs1  compression           lzjb                   local
pool_zfs2  compression           lz4                    local
pool_zfs3  compression           gzip-9                 local
pool_zfs4  compression           zle                    local
```
> Очень сложно смоделировать на виртуалки, но видно, чсто сжатие gzip-9 самое эфективное !!!

 
