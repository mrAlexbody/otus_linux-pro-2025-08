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
