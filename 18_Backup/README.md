# Домашнее задание 18
## Настраиваем бэкапы
### Цель:
- Настроить бэкапы.

### Описание/Пошаговая инструкция выполнения домашнего задания:
Для выполнения домашнего задания используйте методичку

**Что нужно сделать?**

Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client.
Настроить удаленный бекап каталога /etc c сервера client при помощи borgbackup. 

#### Резервные копии должны соответствовать следующим критериям:
- директория для резервных копий /var/backup. Это должна быть отдельная точка монтирования. В данном случае для демонстрации размер не принципиален, достаточно будет и 2GB;
- репозиторий дле резервных копий должен быть зашифрован ключом или паролем - на ваше усмотрение;
- имя бекапа должно содержать информацию о времени снятия бекапа;
- глубина бекапа должна быть год, хранить можно по последней копии на конец месяца, кроме последних трех.
- последние три месяца должны содержать копии на каждый день. Т.е. должна быть правильно настроена политика удаления старых бэкапов;
- резервная копия снимается каждые 5 минут. Такой частый запуск в целях демонстрации;
- написан скрипт для снятия резервных копий. Скрипт запускается из соответствующей Cron джобы, либо systemd timer-а - на ваше усмотрение;
- настроено логирование процесса бекапа. Для упрощения можно весь вывод перенаправлять в logger с соответствующим тегом. Если настроите не в syslog, то обязательна ротация логов.

Запустите стенд на 30 минут.

Убедитесь что резервные копии снимаются.

Остановите бекап, удалите (или переместите) директорию /etc и восстановите ее из бекапа.

Для сдачи домашнего задания ожидаем настроенные стенд, логи процесса бэкапа и описание процесса восстановления.

----
### Пошаговое выполнение задачи
**Вводные данные:**
- Все дальнейшие действия были проверены при использовании Vagrant 2.4.9
- VirtualBox: 7.2.6 r172322 (Qt6.8.0 on windows) 
- В качестве ОС на хостах установлена Almalinux 9
- Vagrant + Ansible запускается из WSL2 в Windows 11

**Тестовый стенд:**
- backup_server 192.168.56.10 Almalinux 9
- client 192.168.56.11 Almalinux 9

Файлы настройки:
- [Vagrantfile](vagrant_backup/Vagrantfile)

- [Ansible](vagrant_backup/ansible/playbook.yml)

> Установка
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_backup2$ vagrant up
Bringing machine 'backup_server' up with 'virtualbox' provider...
Bringing machine 'client' up with 'virtualbox' provider...
==> backup_server: Importing base box 'almalinux/9'...
==> backup_server: Matching MAC address for NAT networking...
==> backup_server: Checking if box 'almalinux/9' version '1.0.0' is up to date...
==> backup_server: Setting the name of the VM: vagrant_backup2_backup_server_1772921822288_89341
..................
==> backup_server: Running provisioner: shell...
    backup_server: Running: inline script
    backup_server: Last metadata expiration check: 0:12:53 ago on Sun 08 Mar 2026 08:46:59 PM UTC.
    backup_server: Package python3-3.9.25-3.el9_7.x86_64 is already installed.
    backup_server: Package nano-5.6.1-7.el9.x86_64 is already installed.
    backup_server: Package curl-7.76.1-35.el9_7.3.x86_64 is already installed.
    backup_server: Package wget-1.21.1-8.el9_4.x86_64 is already installed.
    backup_server: Dependencies resolved.
    backup_server: Nothing to do.
    backup_server: Complete!
==> backup_server: Running provisioner: ansible...
    backup_server: Running ansible-playbook...
[WARNING]: Deprecation warnings can be disabled by setting `deprecation_warnings=False` in ansible.cfg.
[DEPRECATION WARNING]: The '--inventory-file' argument is deprecated. This feature will be removed from ansible-core version 2.23. Use -i or --inventory instead.
[WARNING]: Found both group and host with same name: client
[WARNING]: Found both group and host with same name: backup_server

PLAY [Prepare EPEL and Install Borg] *******************************************

TASK [Gathering Facts] *********************************************************
[WARNING]: Host 'backup_server' is using the discovered Python interpreter at '/usr/bin/python3.9', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_discovery.html for more information.
ok: [backup_server]

TASK [Install epel-release] ****************************************************
ok: [backup_server]

TASK [Enable CRB repository (AlmaLinux 9)] *************************************
changed: [backup_server]

TASK [Install BorgBackup] ******************************************************
ok: [backup_server]

PLAY [Configure Backup Server] *************************************************

TASK [Gathering Facts] *********************************************************
ok: [backup_server]

TASK [Create partition on /dev/sdb] ********************************************
ok: [backup_server]

TASK [Format disk to EXT4] *****************************************************
ok: [backup_server]

TASK [Mount backup storage] ****************************************************
[DEPRECATION WARNING]: Importing 'to_bytes' from 'ansible.module_utils._text' is deprecated. This feature will be removed from ansible-core version 2.24. Use ansible.module_utils.common.text.converters instead.
ok: [backup_server]
[DEPRECATION WARNING]: Importing 'to_native' from 'ansible.module_utils._text' is deprecated. This feature will be removed from ansible-core version 2.24. Use ansible.module_utils.common.text.converters instead.
[DEPRECATION WARNING]: Passing `warnings` to `exit_json` or `fail_json` is deprecated. This feature will be removed from ansible-core version 2.23. Use `AnsibleModule.warn` instead.

TASK [Create borg user] ********************************************************
ok: [backup_server]

TASK [Create .ssh directory for borg user] *************************************
ok: [backup_server]

TASK [Set permissions on backup directory] *************************************
ok: [backup_server]

PLAY [Configure Client] ********************************************************
skipping: no hosts matched

PLAY RECAP *********************************************************************
backup_server              : ok=11   changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

==> client: Running provisioner: shell...
    client: Running: inline script
    client: Last metadata expiration check: 0:18:13 ago on Sun 08 Mar 2026 08:41:57 PM UTC.
    client: Package python3-3.9.25-3.el9_7.x86_64 is already installed.
    client: Package nano-5.6.1-7.el9.x86_64 is already installed.
    client: Package curl-7.76.1-35.el9_7.3.x86_64 is already installed.
    client: Package wget-1.21.1-8.el9_4.x86_64 is already installed.
    client: Dependencies resolved.
    client: Nothing to do.
    client: Complete!
==> client: Running provisioner: ansible...
    client: Running ansible-playbook...
[WARNING]: Deprecation warnings can be disabled by setting `deprecation_warnings=False` in ansible.cfg.
[DEPRECATION WARNING]: The '--inventory-file' argument is deprecated. This feature will be removed from ansible-core version 2.23. Use -i or --inventory instead.
[WARNING]: Found both group and host with same name: client
[WARNING]: Found both group and host with same name: backup_server

PLAY [Prepare EPEL and Install Borg] *******************************************

TASK [Gathering Facts] *********************************************************
[WARNING]: Host 'client' is using the discovered Python interpreter at '/usr/bin/python3.9', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_discovery.html for more information.
ok: [client]

TASK [Install epel-release] ****************************************************
ok: [client]

TASK [Enable CRB repository (AlmaLinux 9)] *************************************
changed: [client]

TASK [Install BorgBackup] ******************************************************
ok: [client]

PLAY [Configure Backup Server] *************************************************
skipping: no hosts matched

PLAY [Configure Client] ********************************************************

TASK [Gathering Facts] *********************************************************
ok: [client]

TASK [Generate SSH key for root] ***********************************************
ok: [client]

TASK [Authorize client key on backup server] ***********************************
[DEPRECATION WARNING]: Importing 'to_native' from 'ansible.module_utils._text' is deprecated. This feature will be removed from ansible-core version 2.24. Use ansible.module_utils.common.text.converters instead.
ok: [client -> backup_server(127.0.0.1)]

TASK [Check if server is in known_hosts] ***************************************
ok: [client]

TASK [Scan backup server public key] *******************************************
skipping: [client]

TASK [Initialize Borg Repository] **********************************************
changed: [client]

TASK [Create backup script from template] **************************************
changed: [client]

TASK [Create systemd service file (calls the script)] **************************
changed: [client]

TASK [Create systemd timer file (every 5 minutes)] *****************************
ok: [client]

TASK [Start and enable backup timer] *******************************************
ok: [client]

PLAY RECAP *********************************************************************
client                     : ok=13   changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

```
### Проверка бэкапа
> Проверка списка созданных архивов c сервера backup-server
```shell
[root@backup-server ~]# borg list /var/backup/client_etc/
etc-2026-03-08_22:22:14              Sun, 2026-03-08 22:22:14 [1462eef2338621cf7a421e3399c82c597a7dd3076fd6eec5c2cd8840acef139a]
etc-2026-03-08_23:56:47              Sun, 2026-03-08 23:56:48 [e475c6ab5798509faba1ec38fbdfb524799e542f887406408164d2377703562c]
etc-2026-03-09_08:37:33                Mon, 2026-03-09 08:37:34 [e5bd59e2782fa7b4ea3509de1e473eef77bd55362df48abd1a769ad62d6d2bed]
[root@backup-server ~]#
```
> Провера списка созданных архивов с client
```shell
[root@client ~]# borg list  borg@192.168.56.10:/var/backup/client_etc
Enter passphrase for key ssh://borg@192.168.56.10/var/backup/client_etc:
etc-2026-03-08_22:22:14              Sun, 2026-03-08 22:22:14 [1462eef2338621cf7a421e3399c82c597a7dd3076fd6eec5c2cd8840acef139a]
etc-2026-03-08_23:56:47              Sun, 2026-03-08 23:56:48 [e475c6ab5798509faba1ec38fbdfb524799e542f887406408164d2377703562c]
etc-2026-03-09_08:37:33                Mon, 2026-03-09 08:37:34 [e5bd59e2782fa7b4ea3509de1e473eef77bd55362df48abd1a769ad62d6d2bed]
[root@client ~]#
````
> Что в логах на client машине?
>> Информация в логах есть.
```shell
[root@client ~]# grep borg-backup /var/log/messages
Mar  8 22:22:08 localhost python3.9[10287]: ansible-ansible.legacy.stat Invoked with path=/usr/local/bin/borg-backup.sh follow=False get_checksum=True get_size=False checksum_algorithm=sha1 get_mime=True get_attributes=True get_selinux_context=False
Mar  8 22:22:09 localhost python3.9[10375]: ansible-ansible.legacy.copy Invoked with dest=/usr/local/bin/borg-backup.sh mode=0755 src=/home/vagrant/.ansible/tmp/ansible-tmp-1773008527.4833329-7952-152812228068164/.source.sh follow=False _original_basename=borg-backup.sh.j2 checksum=9c0586d2be4fd2af80b65db350191c302578be60 backup=False force=True remote_src=False unsafe_writes=False content=NOT_LOGGING_PARAMETER validate=None directory_mode=None local_follow=None owner=None group=None seuser=None serole=None selevel=None setype=None attributes=None
Mar  8 22:22:10 localhost python3.9[10485]: ansible-ansible.legacy.stat Invoked with path=/etc/systemd/system/borg-backup.service follow=False get_checksum=True get_size=False checksum_algorithm=sha1 get_mime=True get_attributes=True get_selinux_context=False
Mar  8 22:22:10 localhost python3.9[10573]: ansible-ansible.legacy.copy Invoked with dest=/etc/systemd/system/borg-backup.service src=/home/vagrant/.ansible/tmp/ansible-tmp-1773008529.898023-7969-12031137755053/.source.service _original_basename=.r0j6m9mi follow=False checksum=ab66e251e278600e16b9df35ded40bedf4285240 backup=False force=True remote_src=False unsafe_writes=False content=NOT_LOGGING_PARAMETER validate=None directory_mode=None local_follow=None mode=None owner=None group=None seuser=None serole=None selevel=None setype=None attributes=None
Mar  8 22:22:11 localhost python3.9[10683]: ansible-ansible.legacy.stat Invoked with path=/etc/systemd/system/borg-backup.timer follow=False get_checksum=True get_size=False checksum_algorithm=sha1 get_mime=True get_attributes=True get_selinux_context=False
Mar  8 22:22:12 localhost python3.9[10771]: ansible-ansible.legacy.copy Invoked with dest=/etc/systemd/system/borg-backup.timer src=/home/vagrant/.ansible/tmp/ansible-tmp-1773008531.2201087-7986-201619734723004/.source.timer _original_basename=.q5fvvul5 follow=False checksum=cf65b566b33f3f400923ca6769b42e9800a3a799 backup=False force=True remote_src=False unsafe_writes=False content=NOT_LOGGING_PARAMETER validate=None directory_mode=None local_follow=None mode=None owner=None group=None seuser=None serole=None selevel=None setype=None attributes=None
Mar  8 22:22:13 localhost python3.9[10881]: ansible-systemd Invoked with daemon_reload=True enabled=True name=borg-backup.timer state=started daemon_reexec=False scope=system no_block=False force=None masked=None
Mar  8 22:22:13 localhost borg-backup[10936]: Starting Borg backup of /etc
Mar  8 22:22:16 localhost borg-backup[10936]: ------------------------------------------------------------------------------
Mar  8 22:22:16 localhost borg-backup[10936]: Repository: ssh://borg@192.168.56.10/var/backup/client_etc
Mar  8 22:22:16 localhost borg-backup[10936]: Archive name: etc-2026-03-08_22:22:14
Mar  8 22:22:16 localhost borg-backup[10936]: Archive fingerprint: 1462eef2338621cf7a421e3399c82c597a7dd3076fd6eec5c2cd8840acef139a
Mar  8 22:22:16 localhost borg-backup[10936]: Time (start): Sun, 2026-03-08 22:22:14
Mar  8 22:22:16 localhost borg-backup[10936]: Time (end):   Sun, 2026-03-08 22:22:15
Mar  8 22:22:16 localhost borg-backup[10936]: Duration: 1.02 seconds
Mar  8 22:22:16 localhost borg-backup[10936]: Number of files: 545
Mar  8 22:22:16 localhost borg-backup[10936]: Utilization of max. archive size: 0%
Mar  8 22:22:16 localhost borg-backup[10936]: ------------------------------------------------------------------------------
Mar  8 22:22:16 localhost borg-backup[10936]:                       Original size      Compressed size    Deduplicated size
Mar  8 22:22:16 localhost borg-backup[10936]: This archive:               20.89 MB              7.32 MB              7.31 MB
Mar  8 22:22:16 localhost borg-backup[10936]: All archives:               20.88 MB              7.32 MB              7.37 MB
Mar  8 22:22:16 localhost borg-backup[10936]:
Mar  8 22:22:16 localhost borg-backup[10936]:                       Unique chunks         Total chunks
Mar  8 22:22:16 localhost borg-backup[10936]: Chunk index:                     532                  538
Mar  8 22:22:16 localhost borg-backup[10936]: ------------------------------------------------------------------------------
Mar  8 22:22:16 localhost borg-backup[10936]: Backup successfully created. Pruning old archives...
Mar  8 22:22:16 localhost borg-backup[10936]: Keeping archive (rule: daily #1):            etc-2026-03-08_22:22:14              Sun, 2026-03-08 22:22:14 [1462eef2338621cf7a421e3399c82c597a7dd3076fd6eec5c2cd8840acef139a]
Mar  8 22:22:16 localhost borg-backup[10936]: ------------------------------------------------------------------------------

```
> Попробуем запуск бэкапа
```shell
[root@client ~]# borg create --stats borg@192.168.56.10:/var/backup/client_etc::"test-{now:%Y-%m-%d_%H:%M:%S}" /etc
Enter passphrase for key ssh://borg@192.168.56.10/var/backup/client_etc:
Enter passphrase for key ssh://borg@192.168.56.10/var/backup/client_etc:
Enter passphrase for key ssh://borg@192.168.56.10/var/backup/client_etc:
------------------------------------------------------------------------------
Repository: ssh://borg@192.168.56.10/var/backup/client_etc
Archive name: test-2026-03-09_09:13:09
Archive fingerprint: df0b4d357d86989233402ee0204afb036d58c02b5c3c3b89aac7cf0379be06b2
Time (start): Mon, 2026-03-09 09:13:28
Time (end):   Mon, 2026-03-09 09:13:28
Duration: 0.12 seconds
Number of files: 545
Utilization of max. archive size: 0%
------------------------------------------------------------------------------
                       Original size      Compressed size    Deduplicated size
This archive:               20.89 MB              7.32 MB                574 B
All archives:               83.54 MB             29.27 MB              7.43 MB

                       Unique chunks         Total chunks
Chunk index:                     538                 2150
------------------------------------------------------------------------------

[root@client ~]# borg create --stats borg@192.168.56.10:/var/backup/client_etc::"home-{now:%Y-%m-%d_%H:%M:%S}" /home
Enter passphrase for key ssh://borg@192.168.56.10/var/backup/client_etc:
------------------------------------------------------------------------------
Repository: ssh://borg@192.168.56.10/var/backup/client_etc
Archive name: home-2026-03-09_09:16:50
Archive fingerprint: 6ee811713e479c5017f45ca91830aaac82d7e4e676f983f7237ce01fb3b797d8
Time (start): Mon, 2026-03-09 09:16:56
Time (end):   Mon, 2026-03-09 09:16:56
Duration: 0.03 seconds
Number of files: 8
Utilization of max. archive size: 0%
------------------------------------------------------------------------------
                       Original size      Compressed size    Deduplicated size
This archive:                3.24 kB              3.43 kB              2.77 kB
All archives:               83.54 MB             29.27 MB              7.43 MB

                       Unique chunks         Total chunks
Chunk index:                     545                 2160
------------------------------------------------------------------------------

````
> Смотрим что получилось
```shell
[root@client ~]# borg list borg@192.168.56.10:/var/backup/client_etc
Enter passphrase for key ssh://borg@192.168.56.10/var/backup/client_etc:
etc-2026-03-08_22:22:14              Sun, 2026-03-08 22:22:14 [1462eef2338621cf7a421e3399c82c597a7dd3076fd6eec5c2cd8840acef139a]
etc-2026-03-08_23:56:47              Sun, 2026-03-08 23:56:48 [e475c6ab5798509faba1ec38fbdfb524799e542f887406408164d2377703562c]
etc-2026-03-09_08:37:33              Mon, 2026-03-09 08:37:34 [e5bd59e2782fa7b4ea3509de1e473eef77bd55362df48abd1a769ad62d6d2bed]
test-2026-03-09_09:13:09             Mon, 2026-03-09 09:13:28 [df0b4d357d86989233402ee0204afb036d58c02b5c3c3b89aac7cf0379be06b2]
home-2026-03-09_09:16:50             Mon, 2026-03-09 09:16:56 [6ee811713e479c5017f45ca91830aaac82d7e4e676f983f7237ce01fb3b797d8]
```
> Достаем файл из бекапа
```shell
[root@client ~]# ls -la
total 20
dr-xr-x---.  5 root root 132 Mar  8 22:22 .
dr-xr-xr-x. 19 root root 250 Mar  8 22:21 ..
-rw-r--r--.  1 root root  18 Feb 11  2022 .bash_logout
-rw-r--r--.  1 root root 141 Feb 11  2022 .bash_profile
-rw-r--r--.  1 root root 429 Feb 11  2022 .bashrc
drwx------.  3 root root  18 Mar  8 22:22 .cache
drwx------.  3 root root  18 Mar  8 22:22 .config
-rw-r--r--.  1 root root 100 Feb 11  2022 .cshrc
drwx------.  2 root root  57 Mar  8 22:22 .ssh
-rw-r--r--.  1 root root 129 Feb 11  2022 .tcshrc
[root@client ~]# borg extract borg@192.168.56.10:/var/backup/client_etc::test-2026-03-09_09:13:09 etc/hostname
Enter passphrase for key ssh://borg@192.168.56.10/var/backup/client_etc:
[root@client ~]# ls -la
total 20
dr-xr-x---.  6 root root 143 Mar  9 09:22 .
dr-xr-xr-x. 19 root root 250 Mar  8 22:21 ..
-rw-r--r--.  1 root root  18 Feb 11  2022 .bash_logout
-rw-r--r--.  1 root root 141 Feb 11  2022 .bash_profile
-rw-r--r--.  1 root root 429 Feb 11  2022 .bashrc
drwx------.  3 root root  18 Mar  8 22:22 .cache
drwx------.  3 root root  18 Mar  8 22:22 .config
-rw-r--r--.  1 root root 100 Feb 11  2022 .cshrc
drwx------.  2 root root  22 Mar  9 09:22 etc
drwx------.  2 root root  57 Mar  8 22:22 .ssh
-rw-r--r--.  1 root root 129 Feb 11  2022 .tcshrc
[root@client ~]# cat ~/etc/hostname
client
[root@client ~]#

```
> Проверка работы таймера
```shell
[root@client ~]# systemctl list-timers --all
NEXT                        LEFT       LAST                        PASSED       UNIT                         ACTIVATES
Mon 2026-03-09 09:46:28 UTC 23min left Mon 2026-03-09 08:12:47 UTC 1h 10min ago dnf-makecache.timer          dnf-makecache.service
Mon 2026-03-09 22:35:49 UTC 13h left   Sun 2026-03-08 22:35:49 UTC 10h ago      systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
Tue 2026-03-10 00:00:00 UTC 14h left   Mon 2026-03-09 00:00:03 UTC 9h ago       logrotate.timer              logrotate.service
-                           -          Mon 2026-03-09 08:42:48 UTC 40min ago    borg-backup.timer            borg-backup.service

4 timers listed.
[root@client ~]#

```
The End!