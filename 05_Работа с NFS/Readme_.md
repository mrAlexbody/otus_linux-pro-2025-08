Домашнее задание 05
=
## "Работа с NFS"

### Цель:
+ научиться самостоятельно разворачивать сервис NFS и подключать к нему клиентов;


### Описание/Пошаговая инструкция выполнения домашнего задания:
### 🎯 Что нужно сделать?

+ запустить 2 виртуальных машины (сервер NFS и клиента);
+ на сервере NFS должна быть подготовлена и экспортирована директория;
+ в экспортированной директории должна быть поддиректория с именем upload с правами на запись в неё;
+ экспортированная директория должна автоматически монтироваться на клиенте при старте виртуальной машины (systemd, autofs или fstab — любым способом);
+ монтирование и работа NFS на клиенте должна быть организована с использованием NFSv3.

### ⭐️ Задание со звездочкой*
+ настроить аутентификацию через KERBEROS с использованием NFSv4
---

### Виртуальные машины:
+ NFS Server (nfs-server) - 172.31.134.60
+ NFS Client (nfs-client) - 172.31.140.41

### Настройка NFS Server
> Установка пакета:
```shell
root@nfs-server:~# apt install nfs-kernel-server
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  keyutils libnfsidmap1 nfs-common rpcbind
Suggested packages:
  watchdog
The following NEW packages will be installed:
  keyutils libnfsidmap1 nfs-common nfs-kernel-server rpcbind
0 upgraded, 5 newly installed, 0 to remove and 0 not upgraded.
Need to get 569 kB of archives.
After this operation, 2,022 kB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 libnfsidmap1 amd64 1:2.6.4-3ubuntu5.1 [48.3 kB]
Get:2 http://ru.archive.ubuntu.com/ubuntu noble/main amd64 rpcbind amd64 1.2.6-7ubuntu2 [46.5 kB]
Get:3 http://ru.archive.ubuntu.com/ubuntu noble/main amd64 keyutils amd64 1.6.3-3build1 [56.8 kB]
Get:4 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 nfs-common amd64 1:2.6.4-3ubuntu5.1 [248 kB]
Get:5 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 nfs-kernel-server amd64 1:2.6.4-3ubuntu5.1 [169 kB]
Fetched 569 kB in 0s (3,947 kB/s)
Selecting previously unselected package libnfsidmap1:amd64.
(Reading database ... 87329 files and directories currently installed.)
Preparing to unpack .../libnfsidmap1_1%3a2.6.4-3ubuntu5.1_amd64.deb ...
... и т.д.

Creating config file /etc/exports with new version

Creating config file /etc/default/nfs-kernel-server with new version
Processing triggers for man-db (2.12.0-4build2) ...
Processing triggers for libc-bin (2.39-0ubuntu8.6) ...
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
```
> Проверил после установки
```shell
root@nfs-server:~# netstat -putnl
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:48513           0.0.0.0:*               LISTEN      2063/rpc.mountd
tcp        0      0 127.0.0.1:6010          0.0.0.0:*               LISTEN      1251/sshd: amyskin@
tcp        0      0 0.0.0.0:43973           0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      830/systemd-resolve
tcp        0      0 0.0.0.0:41469           0.0.0.0:*               LISTEN      2053/rpc.statd
tcp        0      0 0.0.0.0:47371           0.0.0.0:*               LISTEN      2063/rpc.mountd
tcp        0      0 0.0.0.0:35003           0.0.0.0:*               LISTEN      2063/rpc.mountd
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1/init
tcp        0      0 0.0.0.0:2049            0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.54:53           0.0.0.0:*               LISTEN      830/systemd-resolve
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/init
tcp6       0      0 :::40953                :::*                    LISTEN      2053/rpc.statd
tcp6       0      0 :::39637                :::*                    LISTEN      -
tcp6       0      0 :::37283                :::*                    LISTEN      2063/rpc.mountd
tcp6       0      0 :::47399                :::*                    LISTEN      2063/rpc.mountd
tcp6       0      0 :::55631                :::*                    LISTEN      2063/rpc.mountd
tcp6       0      0 ::1:6010                :::*                    LISTEN      1251/sshd: amyskin@
tcp6       0      0 :::22                   :::*                    LISTEN      1/init
tcp6       0      0 :::2049                 :::*                    LISTEN      -
tcp6       0      0 :::111                  :::*                    LISTEN      1/init
udp        0      0 127.0.0.1:957           0.0.0.0:*                           2053/rpc.statd
udp        0      0 0.0.0.0:46094           0.0.0.0:*                           -
udp        0      0 0.0.0.0:48476           0.0.0.0:*                           2063/rpc.mountd
udp        0      0 0.0.0.0:50878           0.0.0.0:*                           2063/rpc.mountd
udp        0      0 0.0.0.0:40751           0.0.0.0:*                           2053/rpc.statd
udp        0      0 0.0.0.0:59284           0.0.0.0:*                           2063/rpc.mountd
udp        0      0 127.0.0.54:53           0.0.0.0:*                           830/systemd-resolve
udp        0      0 127.0.0.53:53           0.0.0.0:*                           830/systemd-resolve
udp        0      0 172.31.134.60:68        0.0.0.0:*                           664/systemd-network
udp        0      0 0.0.0.0:111             0.0.0.0:*                           1/init
udp6       0      0 :::43901                :::*                                2063/rpc.mountd
udp6       0      0 :::34026                :::*                                2053/rpc.statd
udp6       0      0 :::50508                :::*                                2063/rpc.mountd
udp6       0      0 :::36843                :::*                                -
udp6       0      0 :::111                  :::*                                1/init
udp6       0      0 :::35423                :::*                                2063/rpc.mountd

root@nfs-server:~# ps aux |grep rpc
_rpc        1553  0.0  0.5   7968  3584 ?        Ss   17:50   0:00 /sbin/rpcbind -f -w
root        1965  0.0  0.0      0     0 ?        I<   17:50   0:00 [kworker/R-rpcio]
root        2052  0.0  0.3   3016  2052 ?        Ss   17:50   0:00 /usr/sbin/rpc.idmapd
statd       2053  0.0  0.2   4560  1668 ?        Ss   17:50   0:00 /usr/sbin/rpc.statd
root        2063  0.0  0.1  43212  1196 ?        Ss   17:50   0:00 /usr/sbin/rpc.mountd
root        2719  0.0  0.3   6544  2304 pts/1    S+   20:51   0:00 grep --color=auto rpc
```
> Создал директорию .
```shell
root@nfs-server:~# mkdir -p /srv/share/upload
root@nfs-server:~# ls -la /srv/
total 12
drwxr-xr-x  3 root root 4096 Nov 30 20:55 .
drwxr-xr-x 23 root root 4096 Nov 29 13:26 ..
drwxr-xr-x  3 root root 4096 Nov 30 20:55 share
root@nfs-server:~# ls -la /srv/share/
total 12
drwxr-xr-x 3 root root 4096 Nov 30 20:55 .
drwxr-xr-x 3 root root 4096 Nov 30 20:55 ..
drwxr-xr-x 2 root root 4096 Nov 30 20:55 upload
root@nfs-server:~# chown -R nobody:nogroup /srv/share
root@nfs-server:~# chmod 0777 /srv/share/upload
```
> Прописал структуру в файле /etc/exports
```shell
root@nfs-server:~# cat /etc/exports
# /etc/exports: the access control list for filesystems which may be exported
#               to NFS clients.  See exports(5).
#
# Example for NFSv2 and NFSv3:
# /srv/homes       hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
#
# Example for NFSv4:
# /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
# /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
#
/srv/share 172.31.140.41/20(rw,sync,root_squash,no_subtree_check)

````
> Далее,  переэкспортировал все файловые системы, указанные в /etc/exports, а потом проверил
```shell
root@nfs-server:~# exportfs -r
root@nfs-server:~# exportfs -s
/srv/share  172.31.140.41/20(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
````
>> Если не указать опцию subtree_check или no_subtree_check в файле /etc/exports, то будет ошибка!
```shell
root@nfs-server:~# exportfs -r
exportfs: /etc/exports [1]: Neither 'subtree_check' or 'no_subtree_check' specified for export "172.31.140.41/20:/srv/share".
  Assuming default behaviour ('no_subtree_check').
  NOTE: this default has changed since nfs-utils version 1.0.x
```

### Настройка NFS Client
> Установил пакет для работы с nfs
```shell
root@nfs-client:~# sudo apt install -y nfs-common
Чтение списков пакетов… Готово
Построение дерева зависимостей… Готово
Чтение информации о состоянии… Готово
Следующие пакеты устанавливались автоматически и больше не требуются:
  libflashrom1 libftdi1-2
Для их удаления используйте «sudo apt autoremove».
Будут установлены следующие дополнительные пакеты:
  keyutils libnfsidmap1 rpcbind
Предлагаемые пакеты:
  watchdog
Следующие НОВЫЕ пакеты будут установлены:
  keyutils libnfsidmap1 nfs-common rpcbind
Обновлено 0 пакетов, установлено 4 новых пакетов, для удаления отмечено 0 пакетов, и 8 пакетов не обновлено.
Необходимо скачать 381 kB архивов.
После данной операции объём занятого дискового пространства возрастёт на 1 447 kB.
Пол:1 http://ru.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libnfsidmap1 amd64 1:2.6.1-1ubuntu1.2 [42,9 kB]
Пол:2 http://ru.archive.ubuntu.com/ubuntu jammy/main amd64 rpcbind amd64 1.2.6-2build1 [46,6 kB]
Пол:3 http://ru.archive.ubuntu.com/ubuntu jammy/main amd64 keyutils amd64 1.6.1-2ubuntu3 [50,4 kB]
Пол:4 http://ru.archive.ubuntu.com/ubuntu jammy-updates/main amd64 nfs-common amd64 1:2.6.1-1ubuntu1.2 [241 kB]
Получено 381 kB за 0с (3 989 kB/s)
Выбор ранее не выбранного пакета libnfsidmap1:amd64.
(Чтение базы данных … на данный момент установлено 75572 файла и каталога.)
Подготовка к распаковке …/libnfsidmap1_1%3a2.6.1-1ubuntu1.2_amd64.deb …
Распаковывается libnfsidmap1:amd64 (1:2.6.1-1ubuntu1.2) …
Выбор ранее не выбранного пакета rpcbind.
Подготовка к распаковке …/rpcbind_1.2.6-2build1_amd64.deb …
Распаковывается rpcbind (1.2.6-2build1) …
Выбор ранее не выбранного пакета keyutils.
Подготовка к распаковке …/keyutils_1.6.1-2ubuntu3_amd64.deb …
Распаковывается keyutils (1.6.1-2ubuntu3) …
Выбор ранее не выбранного пакета nfs-common.
Подготовка к распаковке …/nfs-common_1%3a2.6.1-1ubuntu1.2_amd64.deb …
Распаковывается nfs-common (1:2.6.1-1ubuntu1.2) …
Настраивается пакет libnfsidmap1:amd64 (1:2.6.1-1ubuntu1.2) …
Настраивается пакет rpcbind (1.2.6-2build1) …
Created symlink /etc/systemd/system/multi-user.target.wants/rpcbind.service → /lib/systemd/system/rpcbind.service.
Created symlink /etc/systemd/system/sockets.target.wants/rpcbind.socket → /lib/systemd/system/rpcbind.socket.
Настраивается пакет keyutils (1.6.1-2ubuntu3) …
Настраивается пакет nfs-common (1:2.6.1-1ubuntu1.2) …

Creating config file /etc/idmapd.conf with new version

Creating config file /etc/nfs.conf with new version
Adding system user `statd' (UID 115) ...
Adding new user `statd' (UID 115) with group `nogroup' ...
Not creating home directory `/var/lib/nfs'.
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-client.target → /lib/systemd/system/nfs-client.target.
Created symlink /etc/systemd/system/remote-fs.target.wants/nfs-client.target → /lib/systemd/system/nfs-client.target.
auth-rpcgss-module.service is a disabled or a static unit, not starting it.
nfs-idmapd.service is a disabled or a static unit, not starting it.
nfs-utils.service is a disabled or a static unit, not starting it.
proc-fs-nfsd.mount is a disabled or a static unit, not starting it.
rpc-gssd.service is a disabled or a static unit, not starting it.
rpc-statd-notify.service is a disabled or a static unit, not starting it.
rpc-statd.service is a disabled or a static unit, not starting it.
rpc-svcgssd.service is a disabled or a static unit, not starting it.
rpc_pipefs.target is a disabled or a static unit, not starting it.
var-lib-nfs-rpc_pipefs.mount is a disabled or a static unit, not starting it.
Обрабатываются триггеры для man-db (2.10.2-1) …
Обрабатываются триггеры для libc-bin (2.35-0ubuntu3.11) …
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.
```
> Прописал в /etc/fstab
```shell
root@nfs-client:~# cat /etc/fstab
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/ubuntu-vg/ubuntu-lv during curtin installation
/dev/disk/by-id/dm-uuid-LVM-61jM7UCiI4duQYXYcZnoPeMju9cCjGxjKfU8RcID7273Tnf3tmG9OhreJreILp1z / ext4 defaults 0 1
# /boot was on /dev/sda2 during curtin installation
/dev/disk/by-uuid/d7e78c4e-3ff7-4581-ae42-6d36b4d88f2e /boot ext4 defaults 0 1
/swap.img       none    swap    sw      0       0
172.31.134.60:/srv/share/ /mnt nfs vers=3,noauto,x-systemd.automount 0 0
```
> Сообщил системному менеджеру systemd, что нужно перезагрузить свою конфигурацию.
```shell
root@nfs-client:~# systemctl daemon-reload
root@nfs-client:~# systemctl restart remote-fs.target
```
> Проверил что получилось 
```shell
root@nfs-client:~# mount
root@nfs-client:/mnt/upload# mount
... вот тут 
sunrpc on /run/rpc_pipefs type rpc_pipefs (rw,relatime)
systemd-1 on /mnt type autofs (rw,relatime,fd=44,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=38914)
172.31.134.60:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=172.31.134.60,mountvers=3,mountport=48476,mountproto=udp,local_lock=none,addr=172.31.134.60)
```
> На коиенте создал файл 
```shell
root@nfs-client:~# cd /mnt/upload/
root@nfs-client:/mnt/upload# ls -la
total 8
drwxrwxrwx 2 nobody nogroup 4096 ноя 30 20:55 .
drwxr-xr-x 3 nobody nogroup 4096 ноя 30 20:55 ..
root@nfs-client:/mnt/upload# touch test.txt
root@nfs-client:/mnt/upload# ls -la
total 8
drwxrwxrwx 2 nobody nogroup 4096 ноя 30 21:42 .
drwxr-xr-x 3 nobody nogroup 4096 ноя 30 20:55 ..
-rw-r--r-- 1 nobody nogroup    0 ноя 30 21:42 test.txt
```
> Потом создал файл на сервере и проверил что там.
```shell
root@nfs-server:/srv/share/upload# exportfs -s
/srv/share  172.31.140.41/20(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
root@nfs-server:~# cd /srv/share/upload/
root@nfs-server:/srv/share/upload# ls -la
total 8
drwxrwxrwx 2 nobody nogroup 4096 Nov 30 21:42 .
drwxr-xr-x 3 nobody nogroup 4096 Nov 30 20:55 ..
-rw-r--r-- 1 nobody nogroup    0 Nov 30 21:42 test.txt
root@nfs-server:/srv/share/upload# touch check_file.txt
root@nfs-server:/srv/share/upload# ls -la
total 8
drwxrwxrwx 2 nobody nogroup 4096 Nov 30 21:47 .
drwxr-xr-x 3 nobody nogroup 4096 Nov 30 20:55 ..
-rw-r--r-- 1 root   root       0 Nov 30 21:47 check_file.txt
-rw-r--r-- 1 nobody nogroup    0 Nov 30 21:42 test.txt

root@nfs-server:~# showmount -e localhost
Export list for localhost:
/srv/share *
```
> Проверил что на клиенте
```shell
amyskin@nfs-client:/mnt/upload$ echo "1" > ./client_check_file.txt
amyskin@nfs-client:/mnt/upload$ ls -la
total 12
drwxrwxrwx 2 nobody  nogroup 4096 ноя 30 21:51 .
drwxr-xr-x 3 nobody  nogroup 4096 ноя 30 20:55 ..
-rw-r--r-- 1 root    root       0 ноя 30 21:47 check_file.txt
-rw-rw-r-- 1 amyskin amyskin    2 ноя 30 21:51 client_check_file.txt
-rw-r--r-- 1 nobody  nogroup    0 ноя 30 21:42 test.txt

amyskin@nfs-client:/mnt/upload$ showmount -a 172.31.134.60
All mount points on 172.31.134.60:
172.31.140.41:/srv/share

root@nfs-client:~# df -h
Filesystem                         Size  Used Avail Use% Mounted on
tmpfs                              391M  1,2M  390M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv  9,8G  5,1G  4,2G  55% /
tmpfs                              2,0G     0  2,0G   0% /dev/shm
tmpfs                              5,0M     0  5,0M   0% /run/lock
/dev/sda2                          1,7G  130M  1,5G   8% /boot
172.31.134.60:/srv/share/          9,8G  4,5G  4,8G  49% /mnt
tmpfs                              391M  4,0K  391M   1% /run/user/1000
root@nfs-client:~# mount | grep nfs
172.31.134.60:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=172.31.134.60,mountvers=3,mountport=60226,mountproto=udp,local_lock=none,addr=172.31.134.60)
```
