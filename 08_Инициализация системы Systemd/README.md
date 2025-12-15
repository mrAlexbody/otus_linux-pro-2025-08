# Домашнее задание 08
## Systemd - создание unit-файла

### Цель:
Научиться редактировать существующие и создавать новые unit-файлы;

### Выполнить следующие задания :
+ Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/default).
+ Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта (https://gist.github.com/cea2k/1318020).
+ Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно.
---
### Написать service
> Создал файл с конфигурацией для сервиса в директории /etc/default
```shell

root@otus-systemd:/etc/default# cat /etc/default/watchlog
# Configuration file for my watchlog service
# Place it to /etc/default

# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log

```
> Создал файл файл /var/log/watchlog.log и добавил туда строки
```shell
root@otus-systemd:/etc/default# ls
amd64-microcode  cron        grub           intel-microcode  mdadm                open-iscsi  ssh      useradd
apport           cryptdisks  grub.d         keyboard         motd-news            pollinate   sysstat
console-setup    dbus        grub.ucf-dist  locale           networkd-dispatcher  rsync       ufw
root@otus-systemd:/etc/default# nano watchlog
root@otus-systemd:/etc/default# touch /var/log/watchlog.log
root@otus-systemd:/etc/default# ls -la /var/log/watchlog.log
-rw-r--r-- 1 root root 1380529254 Dec 14 19:38 /var/log/watchlog.log
root@otus-systemd:/etc/default# more /var/log/watchlog.log
...
Dec 14 17:57:33 otus-systemd kernel: vmwgfx 0000:00:02.0: [drm] *ERROR* vmwgfx seems to be running on an unsupported hypervisor.
Dec 14 17:57:33 otus-systemd kernel: vmwgfx 0000:00:02.0: [drm] *ERROR* This configuration is likely broken.
Dec 14 17:57:33 otus-systemd kernel: vmwgfx 0000:00:02.0: [drm] *ERROR* Please switch to a supported graphics device to avoid problems.
Dec 11 08:09:14 otus-boot kernel: vmwgfx 0000:00:02.0: [drm] *ALERT* vmwgfx seems to be running on an unsupported hypervisor.
Dec 11 08:09:14 otus-boot kernel: vmwgfx 0000:00:02.0: [drm] *ALERT* This configuration is likely broken.
Dec 11 08:09:14 otus-boot kernel: vmwgfx 0000:00:02.0: [drm] *ALERT* Please switch to a supported graphics device to avoid problems.
-- Boot 0d565f37512249eca4da4d5be5505aab --
Dec 14 16:13:35 otus-boot kernel: vmwgfx 0000:00:02.0: [drm] *ALERT* vmwgfx seems to be running on an unsupported hypervisor.
Dec 14 16:13:35 otus-boot kernel: vmwgfx 0000:00:02.0: [drm] *ALERT* This configuration is likely broken.
Dec 14 16:13:35 otus-boot kernel: vmwgfx 0000:00:02.0: [drm] *ALERT* Please switch to a supported graphics device to avoid problems.
Dec 14 16:13:52 otus-boot login[891]: PAM unable to dlopen(pam_lastlog.so): /usr/lib/security/pam_lastlog.so: cannot open shared object f
ile: No such file or directory
Dec 14 16:13:52 otus-boot login[891]: PAM adding faulty module: pam_lastlog.so
-- Boot b1ac43fe51da482ebab600a96704a2c5 --
Dec 14 16:23:25 otus-boot kernel: vmwgfx 0000:00:02.0: [drm] *ALERT* vmwgfx seems to be running on an unsupported hypervisor.
Dec 14 16:23:25 otus-boot kernel: vmwgfx 0000:00:02.0: [drm] *ALERT* This configuration is likely broken.
Dec 14 16:23:25 otus-boot kernel: vmwgfx 0000:00:02.0: [drm] *ALERT* Please switch to a supported graphics device to avoid problems.
Dec 14 16:23:50 otus-boot login[832]: PAM unable to dlopen(pam_lastlog.so): /usr/lib/security/pam_lastlog.so: cannot open shared object f
ile: No such file or directory
Dec 14 16:23:50 otus-boot login[832]: PAM adding faulty module: pam_lastlog.so
Dec 14 16:27:10 otus-boot sudo[983]: pam_unix(sudo-i:auth): conversation failed
Dec 14 16:27:10 otus-boot sudo[983]: pam_unix(sudo-i:auth): auth could not identify password for [amyskin]
-- Boot 293f4dd70b9949ee908cfd5c323e9ca8 --
Dec 14 16:25:54 otus-boot kernel: vmwgfx 0000:00:02.0: [drm] *ALERT* vmwgfx seems to be running on an unsupported hypervisor.
Dec 14 16:25:54 otus-boot kernel: vmwgfx 0000:00:02.0: [drm] *ALERT* This configuration is likely broken.
....
```
> Далее создал скрипт /opt/watchlog.sh
```shell
root@otus-systemd:/etc/default# nano /opt/watchlog.sh && chmod +x /opt/watchlog.sh
root@otus-systemd:/etc/default# ls -la /opt/*
-rwxr-xr-x 1 root root 131 Dec 14 19:43 /opt/watchlog.sh
root@otus-systemd:/etc/default# cat /opt/watchlog.sh
#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi
```
> Длее создал unit для сервиса и таймера:
+ service
```shell
root@otus-systemd:/# ls -la /etc/systemd/system/watchlog.service
-rw-r--r-- 1 root root 139 Dec 14 19:45 /etc/systemd/system/watchlog.service
root@otus-systemd:/# cat /etc/systemd/system/watchlog.service
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/default/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
```
+ timer
```shell
root@otus-systemd:/# nano /etc/systemd/system/watchlog.timer
root@otus-systemd:/# ls -la /etc/systemd/system/watchlog.timer
-rw-r--r-- 1 root root 165 Dec 14 19:47 /etc/systemd/system/watchlog.timer
root@otus-systemd:/# cat /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target

```
> Потом запустил только timer:
```shell
root@otus-systemd:/# systemctl start watchlog.timer
root@otus-systemd:/# systemctl enable watchlog.timer
Created symlink /etc/systemd/system/multi-user.target.wants/watchlog.timer → /etc/systemd/system/watchlog.timer.
root@otus-systemd:/# systemctl status watchlog.timer
● watchlog.timer - Run watchlog script every 30 second
     Loaded: loaded (/etc/systemd/system/watchlog.timer; enabled; preset: enabled)
     Active: active (elapsed) since Sun 2025-12-14 19:49:04 UTC; 19s ago
    Trigger: n/a
   Triggers: ● watchlog.service

Dec 14 19:49:04 otus-systemd systemd[1]: Started watchlog.timer - Run watchlog script every 30 second.

```
> Проверка
```shell
Dec 14 19:49:04 otus-systemd systemd[1]: Started watchlog.timer - Run watchlog script every 30 second.
root@otus-systemd:/# tail -n 1000 /var/log/syslog  | grep word
2025-12-14T18:04:51.414376+00:00 otus-systemd systemd[1]: Started systemd-ask-password-console.path - Dispatch Password Requests to Console Directory Watch.
2025-12-14T18:04:51.414382+00:00 otus-systemd systemd[1]: systemd-ask-password-plymouth.path - Forward Password Requests to Plymouth Directory Watch was skipped because of an unmet condition check (ConditionPathExists=/run/plymouth/pid).
2025-12-14T18:04:51.418783+00:00 otus-systemd kernel: systemd[1]: Started systemd-ask-password-wall.path - Forward Password Requests to Wall Directory Watch.
2025-12-14T18:04:51.418972+00:00 otus-systemd kernel: audit: type=1400 audit(1765735053.384:3): apparmor="STATUS" operation="profile_load" profile="unconfined" name="1password" pid=571 comm="apparmor_parser"
```
### Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта
+ **spawn-fcgi** — это утилита для запуска FastCGI-приложений в качестве демонов (фоновых процессов). Она является частью проекта lighttpd (легковесного веб-сервера), но может использоваться независимо с другими веб-серверами (Nginx, Apache и т.д.).
> Для выполнения данной задачи, нужно установить некоторые пакеты:
```shell
root@otus-systemd:/# apt install spawn-fcgi php php-cgi php-cli apache2 libapache2-mod-fcgid -y
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  apache2-bin apache2-data apache2-utils libapache2-mod-php8.3 libapr1t64 libaprutil1-dbd-sqlite3 libaprutil1-ldap libaprutil1t64
  liblua5.4-0 php-common php8.3 php8.3-cgi php8.3-cli php8.3-common php8.3-opcache php8.3-readline ssl-cert
Suggested packages:
  apache2-doc apache2-suexec-pristine | apache2-suexec-custom www-browser php-pear
The following NEW packages will be installed:
  apache2 apache2-bin apache2-data apache2-utils libapache2-mod-fcgid libapache2-mod-php8.3 libapr1t64 libaprutil1-dbd-sqlite3
  libaprutil1-ldap libaprutil1t64 liblua5.4-0 php php-cgi php-cli php-common php8.3 php8.3-cgi php8.3-cli php8.3-common php8.3-opcache
  php8.3-readline spawn-fcgi ssl-cert
0 upgraded, 23 newly installed, 0 to remove and 170 not upgraded.
Need to get 8,963 kB of archives.
After this operation, 42.2 MB of additional disk space will be used.
Get:1 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 libapr1t64 amd64 1.7.2-3.1ubuntu0.1 [108 kB]
Get:2 http://ru.archive.ubuntu.com/ubuntu noble/main amd64 libaprutil1t64 amd64 1.6.3-1.1ubuntu7 [91.9 kB]
Get:3 http://ru.archive.ubuntu.com/ubuntu noble/main amd64 libaprutil1-dbd-sqlite3 amd64 1.6.3-1.1ubuntu7 [11.2 kB]
Get:4 http://ru.archive.ubuntu.com/ubuntu noble/main amd64 libaprutil1-ldap amd64 1.6.3-1.1ubuntu7 [9,116 B]
Get:5 http://ru.archive.ubuntu.com/ubuntu noble/main amd64 liblua5.4-0 amd64 5.4.6-3build2 [166 kB]
Get:6 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 apache2-bin amd64 2.4.58-1ubuntu8.8 [1,331 kB]
Get:7 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 apache2-data all 2.4.58-1ubuntu8.8 [163 kB]
Get:8 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 apache2-utils amd64 2.4.58-1ubuntu8.8 [97.7 kB]
Get:9 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 apache2 amd64 2.4.58-1ubuntu8.8 [90.2 kB]
Get:10 http://ru.archive.ubuntu.com/ubuntu noble/universe amd64 libapache2-mod-fcgid amd64 1:2.3.9-4 [64.9 kB]
Get:11 http://ru.archive.ubuntu.com/ubuntu noble/main amd64 php-common all 2:93ubuntu2 [13.9 kB]
...
```
+ Скачал скрипт от сюда: <https://gist.github.com/cea2k/1318020>

> Скачаал файл
```shell
root@otus-systemd:~# wget https://gist.github.com/cea2k/1318020/archive/6563444afbaa82c75019023162afce3368f02f29.zip
--2025-12-15 21:53:24--  https://gist.github.com/cea2k/1318020/archive/6563444afbaa82c75019023162afce3368f02f29.zip
Resolving gist.github.com (gist.github.com)... 4.225.11.194
Connecting to gist.github.com (gist.github.com)|4.225.11.194|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://codeload.github.com/gist/1318020/zip/6563444afbaa82c75019023162afce3368f02f29 [following]
--2025-12-15 21:53:24--  https://codeload.github.com/gist/1318020/zip/6563444afbaa82c75019023162afce3368f02f29
Resolving codeload.github.com (codeload.github.com)... 4.225.11.198
Connecting to codeload.github.com (codeload.github.com)|4.225.11.198|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1206 (1.2K) [application/zip]
Saving to: ‘6563444afbaa82c75019023162afce3368f02f29.zip’

6563444afbaa82c75019023162afce3368 100%[=============================================================>]   1.18K  --.-KB/s    in 0s

2025-12-15 21:53:25 (17.8 MB/s) - ‘6563444afbaa82c75019023162afce3368f02f29.zip’ saved [1206/1206]



root@otus-systemd:~# ls -la ./php_cgi
-rw-r--r-- 1 root root 1629 Oct 26  2011 ./php_cgi

```
> Cоздал файл /etc/spawn-fcgi/fcgi.conf
```shell
root@otus-systemd:~# cat /etc/spawn-fcgi/fcgi.conf
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u www-data -g www-data -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"

```
> Далее создал юнит-файл
```shell
root@otus-systemd:~# cat /etc/systemd/system/spawn-fcgi.service
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/spawn-fcgi/fcgi.conf
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target

```
> Проверил запуск
```shell
root@otus-systemd:~# systemctl start spawn-fcgi
root@otus-systemd:~# systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
     Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; preset: enabled)
     Active: active (running) since Mon 2025-12-15 22:02:11 UTC; 4s ago
   Main PID: 11338 (php-cgi)
      Tasks: 33 (limit: 4605)
     Memory: 14.5M (peak: 14.8M)
        CPU: 97ms
     CGroup: /system.slice/spawn-fcgi.service
             ├─11338 /usr/bin/php-cgi
             ├─11345 /usr/bin/php-cgi
             ├─11346 /usr/bin/php-cgi
             ├─11347 /usr/bin/php-cgi
             ├─11349 /usr/bin/php-cgi
             ├─11350 /usr/bin/php-cgi
             ├─11351 /usr/bin/php-cgi
             ├─11352 /usr/bin/php-cgi
             ├─11353 /usr/bin/php-cgi
             ├─11354 /usr/bin/php-cgi
             ├─11355 /usr/bin/php-cgi
             ├─11356 /usr/bin/php-cgi
             ├─11358 /usr/bin/php-cgi
             ├─11359 /usr/bin/php-cgi
             ├─11360 /usr/bin/php-cgi
             ├─11362 /usr/bin/php-cgi
             ├─11363 /usr/bin/php-cgi
             ├─11365 /usr/bin/php-cgi
             ├─11367 /usr/bin/php-cgi
             ├─11368 /usr/bin/php-cgi
             ├─11370 /usr/bin/php-cgi
             ├─11372 /usr/bin/php-cgi
             ├─11374 /usr/bin/php-cgi
             ├─11375 /usr/bin/php-cgi
             ├─11377 /usr/bin/php-cgi
             ├─11380 /usr/bin/php-cgi
             ├─11381 /usr/bin/php-cgi
             ├─11382 /usr/bin/php-cgi
             ├─11383 /usr/bin/php-cgi
             ├─11385 /usr/bin/php-cgi
             ├─11386 /usr/bin/php-cgi
             ├─11387 /usr/bin/php-cgi
             └─11388 /usr/bin/php-cgi

Dec 15 22:02:11 otus-systemd systemd[1]: Started spawn-fcgi.service - Spawn-fcgi startup service by Otus.

```
### Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно
> Установил NGINX
```shell
root@otus-systemd:~# apt install nginx -y
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  nginx-common
Suggested packages:
  fcgiwrap nginx-doc
The following NEW packages will be installed:
  nginx nginx-common
0 upgraded, 2 newly installed, 0 to remove and 170 not upgraded.
Need to get 564 kB of archives.
After this operation, 1,596 kB of additional disk space will be used.
Get:1 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 nginx-common all 1.24.0-2ubuntu7.5 [43.4 kB]
Get:2 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 nginx amd64 1.24.0-2ubuntu7.5 [520 kB]
Fetched 564 kB in 0s (2,966 kB/s)
Preconfiguring packages ...
Selecting previously unselected package nginx-common.
(Reading database ... 85811 files and directories currently installed.)
Preparing to unpack .../nginx-common_1.24.0-2ubuntu7.5_all.deb ...
Unpacking nginx-common (1.24.0-2ubuntu7.5) ...
Selecting previously unselected package nginx.
Preparing to unpack .../nginx_1.24.0-2ubuntu7.5_amd64.deb ...
Unpacking nginx (1.24.0-2ubuntu7.5) ...
Setting up nginx-common (1.24.0-2ubuntu7.5) ...
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
Could not execute systemctl:  at /usr/bin/deb-systemd-invoke line 148.
Setting up nginx (1.24.0-2ubuntu7.5) ...
Not attempting to start NGINX, port 80 is already in use.
Processing triggers for man-db (2.12.0-4build2) ...
Processing triggers for ufw (0.36.2-6) ...
Scanning processes...
Scanning candidates...
Scanning linux images...

Running kernel seems to be up-to-date.

Restarting services...

Service restarts being deferred:
 systemctl restart unattended-upgrades.service

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.

```
> Создал новый Unit для работы с шаблонами (/etc/systemd/system/nginx@.service)
```shell
root@otus-systemd:~# cat /etc/systemd/system/nginx@.service
# Stop dance for nginx
# =======================
#
# ExecStop sends SIGSTOP (graceful stop) to the nginx process.
# If, after 5s (--retry QUIT/5) nginx is still running, systemd takes control
# and sends SIGTERM (fast shutdown) to the main process.
# After another 5s (TimeoutStopSec=5), and if nginx is alive, systemd sends
# SIGKILL to all the remaining processes in the process group (KillMode=mixed).
#
# nginx signals reference doc:
# http://nginx.org/en/docs/control.html
#
[Unit]
Description=A high performance web server and a reverse proxy server
Documentation=man:nginx(8)
After=network.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx-%I.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-%I.conf -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx-%I.pid
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target

```
> Создание базовых конфигурационных файлов
```shell
# Создал копию оригинального конфига для первого nginx
root@otus-systemd:~# cp /etc/nginx/nginx.conf /etc/nginx/nginx-first.conf

# Создал копию для второго nginx
root@otus-systemd:~# cp /etc/nginx/nginx.conf /etc/nginx/nginx-second.conf
```
> Отредактировал первый файл _/etc/nginx/nginx-first.conf_
```shell

```