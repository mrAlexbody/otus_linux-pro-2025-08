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
## Определить алгоритм с наилучшим сжатием
- определить, какие алгоритмы сжатия поддерживает zfs (gzip, zle, lzjb, lz4);
- создать 4 файловых системы, на каждой применить свой алгоритм сжатия;
- для сжатия использовать либо текстовый файл, либо группу файлов.

> Список всех дисков
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
> Установил пакеты для ZFS
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
> Создал 4-пула из двух дисков в режиме RAID1 
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
> Посмотрим, что получилось
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
> Добавил алгоритмы сжатия в каждую фс:
```shell
root@zfs:~# zfs set compression=lzjb pool_zfs1
root@zfs:~# zfs set compression=lz4 pool_zfs2
root@zfs:~# zfs set compression=gzip-9 pool_zfs3
root@zfs:~# zfs set compression=zle pool_zfs4
```
> Посмотрим что получилось:
```shell
root@zfs:~# zfs get compression
NAME       PROPERTY     VALUE           SOURCE
pool_zfs1  compression  lzjb            local
pool_zfs2  compression  lz4             local
pool_zfs3  compression  gzip-9          local
pool_zfs4  compression  zle             local

```
> Добавил во все пулы файл:
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
> Проверил что получилось:
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
````
> Гляним информацию о пулах и какой метод сжатия:
````shell
root@zfs:~# zfs get all | grep compression
pool_zfs1  compression           lzjb                   local
pool_zfs2  compression           lz4                    local
pool_zfs3  compression           gzip-9                 local
pool_zfs4  compression           zle                    local
root@zfs:~# zpool list
NAME        SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
pool_zfs1  1.88G   285K  1.87G        -         -     0%     0%  1.00x    ONLINE  -
pool_zfs2  1.88G   283K  1.87G        -         -     0%     0%  1.00x    ONLINE  -
pool_zfs3  1.88G   278K  1.87G        -         -     0%     0%  1.00x    ONLINE  -
pool_zfs4  1.88G   282K  1.87G        -         -     0%     0%  1.00x    ONLINE  -

````
> Ещё скачал один файл во все пулы.
```shell
root@zfs:/pool_zfs1# for i in {1..4}; do wget -P /pool_zfs$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
--2025-11-29 11:52:50--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 41189447 (39M) [text/plain]
Saving to: ‘/pool_zfs1/pg2600.converter.log’

pg2600.converter.log                  100%[=======================================================================>]  39.28M  3.03MB/s    in 14s

2025-11-29 11:53:05 (2.73 MB/s) - ‘/pool_zfs1/pg2600.converter.log’ saved [41189447/41189447]

--2025-11-29 11:53:05--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 41189447 (39M) [text/plain]
Saving to: ‘/pool_zfs2/pg2600.converter.log’

pg2600.converter.log                  100%[=======================================================================>]  39.28M  3.36MB/s    in 17s

2025-11-29 11:53:23 (2.25 MB/s) - ‘/pool_zfs2/pg2600.converter.log’ saved [41189447/41189447]

--2025-11-29 11:53:23--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 41189447 (39M) [text/plain]
Saving to: ‘/pool_zfs3/pg2600.converter.log’

pg2600.converter.log                  100%[=======================================================================>]  39.28M  3.42MB/s    in 14s

2025-11-29 11:53:38 (2.84 MB/s) - ‘/pool_zfs3/pg2600.converter.log’ saved [41189447/41189447]

--2025-11-29 11:53:38--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 41189447 (39M) [text/plain]
Saving to: ‘/pool_zfs4/pg2600.converter.log’

pg2600.converter.log                  100%[=======================================================================>]  39.28M  3.51MB/s    in 13s

2025-11-29 11:53:51 (3.11 MB/s) - ‘/pool_zfs4/pg2600.converter.log’ saved [41189447/41189447]
```
> Проверил, что файл был скачен во все пулы:
```shell
root@zfs:/pool_zfs1# ls -la /pool_zfs*
'/pool_zfs$':
total 8
drwxr-xr-x  2 root root 4096 Oct 23 21:03 .
drwxr-xr-x 28 root root 4096 Oct 23 20:39 ..

/pool_zfs1:
total 22121
drwxr-xr-x  2 root root           4 Nov 29 11:52 .
drwxr-xr-x 28 root root        4096 Oct 23 20:39 ..
-rw-r--r--  1 root root 10485760000 Oct 23 21:06 my_test_file.txt
-rw-r--r--  1 root root    41189447 Nov  2 08:31 pg2600.converter.log

/pool_zfs2:
total 18021
drwxr-xr-x  2 root root           4 Nov 29 11:53 .
drwxr-xr-x 28 root root        4096 Oct 23 20:39 ..
-rw-r--r--  1 root root 10485760000 Oct 23 21:06 my_test_file.txt
-rw-r--r--  1 root root    41189447 Nov  2 08:31 pg2600.converter.log

/pool_zfs3:
total 10975
drwxr-xr-x  2 root root           4 Nov 29 11:53 .
drwxr-xr-x 28 root root        4096 Oct 23 20:39 ..
-rw-r--r--  1 root root 10485760000 Oct 23 21:06 my_test_file.txt
-rw-r--r--  1 root root    41189447 Nov  2 08:31 pg2600.converter.log

/pool_zfs4:
total 40260
drwxr-xr-x  2 root root           4 Nov 29 11:53 .
drwxr-xr-x 28 root root        4096 Oct 23 20:39 ..
-rw-r--r--  1 root root 10485760000 Oct 23 21:07 my_test_file.txt
-rw-r--r--  1 root root    41189447 Nov  2 08:31 pg2600.converter.log
```
>> Видно, что самый оптимальный метод сжатия который используется для пула pool_zfs3. Самый эффективный алгоритм сжатия это gzip-9.
````shell
root@zfs:/pool_zfs1# zfs list
NAME        USED  AVAIL  REFER  MOUNTPOINT
pool_zfs1  21.9M  1.73G  21.6M  /pool_zfs1
pool_zfs2  17.9M  1.73G  17.6M  /pool_zfs2
pool_zfs3  11.0M  1.74G  10.7M  /pool_zfs3
pool_zfs4  39.6M  1.71G  39.3M  /pool_zfs4

root@zfs:/pool_zfs1# zfs get all | grep compressratio | grep -v ref
pool_zfs1  compressratio         1.82x                  -
pool_zfs2  compressratio         2.23x                  -
pool_zfs3  compressratio         3.65x                  -
pool_zfs4  compressratio         1.00x                  -
````
## Определить настройки пула.
- С помощью команды zfs import собрать pool ZFS.
> Скачал архив и разархивировал его:
```shell
root@zfs:~# wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'
--2025-11-29 12:18:23--  https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download
Resolving drive.usercontent.google.com (drive.usercontent.google.com)... 142.250.74.33, 2a00:1450:400f:801::2001
Connecting to drive.usercontent.google.com (drive.usercontent.google.com)|142.250.74.33|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 7275140 (6.9M) [application/octet-stream]
Saving to: ‘archive.tar.gz’

archive.tar.gz                        100%[=======================================================================>]   6.94M  8.80MB/s    in 0.8s

2025-11-29 12:18:30 (8.80 MB/s) - ‘archive.tar.gz’ saved [7275140/7275140]

root@zfs:~# tar -xzvf ./archive.tar.gz
root@zfs:~# ls -la
total 7140
drwx------  5 root root    4096 Nov 29 12:19 .
drwxr-xr-x 28 root root    4096 Oct 23 20:39 ..
-rw-------  1 root root    2426 Oct 23 21:14 .bash_history
-rw-r--r--  1 root root    3106 Apr 22  2024 .bashrc
drwx------  3 root root    4096 Sep 15 17:38 .cache
-rw-r--r--  1 root root     161 Apr 22  2024 .profile
drwx------  2 root root    4096 Sep 15 17:38 .ssh
-rw-r--r--  1 root root 7275140 Dec  6  2023 archive.tar.gz
drwxr-xr-x  2 root root    4096 May 15  2020 zpoolexport
```
> Проверил возможности данного каталога в пул: 
```shell
root@zfs:~# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
status: Some supported features are not enabled on the pool.
        (Note that they may be intentionally disabled if the
        'compatibility' property is set.)
 action: The pool can be imported using its name or numeric identifier, though
        some features will not be available without an explicit 'zpool upgrade'.
 config:

        otus                         ONLINE
          mirror-0                   ONLINE
            /root/zpoolexport/filea  ONLINE
            /root/zpoolexport/fileb  ONLINE

```
> Импорт данного пура к себе в систему:
````shell
root@zfs:~# zpool import -d zpoolexport/ otus
````
>> Дальше смотрим настройки
## Командами zfs определить настройки:
- размер хранилища;
- тип pool;
- значение recordsize;
- какое сжатие используется;
- какая контрольная сумма используется.

> Вывод показывает имя пула otus и его тип.

```shell
root@zfs:~# zpool status
  pool: otus
 state: ONLINE
status: Some supported and requested features are not enabled on the pool.
        The pool can still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done,
        the pool may no longer be accessible by software that does not support
        the features. See zpool-features(7) for details.
config:

        NAME                         STATE     READ WRITE CKSUM
        otus                         ONLINE       0     0     0
          mirror-0                   ONLINE       0     0     0
            /root/zpoolexport/filea  ONLINE       0     0     0
            /root/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors

root@zfs:~# zfs get all otus
NAME  PROPERTY              VALUE                  SOURCE
otus  type                  filesystem             -
otus  creation              Fri May 15  4:00 2020  -
otus  used                  2.04M                  -
otus  available             350M                   -
otus  referenced            24K                    -
otus  compressratio         1.00x                  -
otus  mounted               yes                    -
otus  quota                 none                   default
otus  reservation           none                   default
otus  recordsize            128K                   local
otus  mountpoint            /otus                  default
otus  sharenfs              off                    default
otus  checksum              sha256                 local
otus  compression           zle                    local
otus  atime                 on                     default
otus  devices               on                     default
otus  exec                  on                     default
otus  setuid                on                     default
otus  readonly              off                    default
otus  zoned                 off                    default
otus  snapdir               hidden                 default
otus  aclmode               discard                default
otus  aclinherit            restricted             default
otus  createtxg             1                      -
otus  canmount              on                     default
otus  xattr                 on                     default
otus  copies                1                      default
otus  version               5                      -
otus  utf8only              off                    -
otus  normalization         none                   -
otus  casesensitivity       sensitive              -
otus  vscan                 off                    default
otus  nbmand                off                    default
otus  sharesmb              off                    default
otus  refquota              none                   default
otus  refreservation        none                   default
otus  guid                  14592242904030363272   -
otus  primarycache          all                    default
otus  secondarycache        all                    default
otus  usedbysnapshots       0B                     -
otus  usedbydataset         24K                    -
otus  usedbychildren        2.01M                  -
otus  usedbyrefreservation  0B                     -
otus  logbias               latency                default
otus  objsetid              54                     -
otus  dedup                 off                    default
otus  mlslabel              none                   default
otus  sync                  standard               default
otus  dnodesize             legacy                 default
otus  refcompressratio      1.00x                  -
otus  written               24K                    -
otus  logicalused           1020K                  -
otus  logicalreferenced     12K                    -
otus  volmode               default                default
otus  filesystem_limit      none                   default
otus  snapshot_limit        none                   default
otus  filesystem_count      none                   default
otus  snapshot_count        none                   default
otus  snapdev               hidden                 default
otus  acltype               off                    default
otus  context               none                   default
otus  fscontext             none                   default
otus  defcontext            none                   default
otus  rootcontext           none                   default
otus  relatime              on                     default
otus  redundant_metadata    all                    default
otus  overlay               on                     default
otus  encryption            off                    default
otus  keylocation           none                   default
otus  keyformat             none                   default
otus  pbkdf2iters           0                      default
otus  special_small_blocks  0                      default
```
> Определим основные параметры
>> Размер:
```shell
root@zfs:~# zfs get available otus
NAME  PROPERTY   VALUE  SOURCE
otus  available  350M   -
```
>> Тип ФС:
```shell
root@zfs:~# zfs get readonly otus
NAME  PROPERTY  VALUE   SOURCE
otus  readonly  off     default
```
>> Размер блока данных:
```shell
root@zfs:~# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local
```
>> Тип сжатия:
```shell
root@zfs:~# zfs get compression otus
NAME  PROPERTY     VALUE           SOURCE
otus  compression  zle             local
```
>> Тип контрольной суммы:
```shell
root@zfs:~# zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
```
## Работа со снапшотами:
- скопировать файл из удаленной директории;
- восстановить файл локально. zfs receive;
- найти зашифрованное сообщение в файле secret_message.

> Скачал файл для задания:
```shell
root@zfs:~# wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download
[1] 43320
root@zfs:~#
Redirecting output to ‘wget-log’.

[1]+  Done wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI

root@zfs:~# ls -la
total 12452
drwx------  5 root root    4096 Nov 29 13:03 .
drwxr-xr-x 29 root root    4096 Nov 29 12:31 ..
-rw-------  1 root root    2426 Oct 23 21:14 .bash_history
-rw-r--r--  1 root root    3106 Apr 22  2024 .bashrc
drwx------  3 root root    4096 Sep 15 17:38 .cache
-rw-r--r--  1 root root     161 Apr 22  2024 .profile
drwx------  2 root root    4096 Sep 15 17:38 .ssh
-rw-r--r--  1 root root 7275140 Dec  6  2023 archive.tar.gz
-rw-r--r--  1 root root 5432736 Dec  6  2023 otus_task2.file
-rw-r--r--  1 root root    1290 Nov 29 13:03 wget-log
drwxr-xr-x  2 root root    4096 May 15  2020 zpoolexport
```
> Восстановим фаловую систему из снапшот и проверим:

```shell
root@zfs:~# zfs receive otus/test@today < otus_task2.file
root@zfs:~# ls -la /otus/
hometask2/ test/
root@zfs:~# ls -la /otus/test/
total 2591
drwxr-xr-x 3 root    root         11 May 15  2020 .
drwxr-xr-x 4 root    root          4 Nov 29 13:05 ..
-rw-r--r-- 1 root    root          0 May 15  2020 10M.file
-rw-r--r-- 1 root    root     309987 May 15  2020 Limbo.txt
-rw-r--r-- 1 root    root     509836 May 15  2020 Moby_Dick.txt
-rw-r--r-- 1 root    root    1209374 May  6  2016 War_and_Peace.txt
-rw-r--r-- 1 root    root     727040 May 15  2020 cinderella.tar
-rw-r--r-- 1 root    root         65 May 15  2020 for_examaple.txt
-rw-r--r-- 1 root    root          0 May 15  2020 homework4.txt
drwxr-xr-x 3 amyskin amyskin       4 Dec 18  2017 task1
-rw-r--r-- 1 root    root     398635 May 15  2020 world.sql
root@zfs:~# cat /otus/test/homework4.txt
root@zfs:~# find /otus/test -name "secret_message"
/otus/test/task1/file_mess/secret_message
root@zfs:~# cat /otus/test/task1/file_mess/secret_message
https://otus.ru/lessons/linux-hl/

```
>> The end!
