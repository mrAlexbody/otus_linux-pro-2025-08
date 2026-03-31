# Домашнее задание 29
## @Репликация postgres

### Цель:
- Научиться настраивать репликацию и создавать резервные копии в СУБД PostgreSQL;

### Описание/Пошаговая инструкция выполнения домашнего задания:
***Для выполнения домашнего задания используйте [методичку](https://docs.google.com/document/d/1EU_KF3x9e2f75sNL4sghDIxib9eMfqex/edit)***

**Что нужно сделать?**
- настроить hot_standby репликацию с использованием слотов
- настроить правильное резервное копирование
---
### Пошаговое выполнение задачи
**Вводные данные:**
- Все дальнейшие действия были проверены при использовании Vagrant 2.4.9
- VirtualBox: 7.2.6 
- В качестве ОС на хостах установлена Ubuntu 22.04
- Vagrant + Ansible запускается из WSL2 в Windows 11

> В задании используются две виртуальные машины (ВМ) под управлением Ubuntu 22.04, развёрнутые с помощью Vagrant.

### Конфигурационные файлы
> - [Vagrantfile](vagrant_postgresql/Vagrantfile)
> - [Ansible playbook](vagrant_postgresql/ansible/provision.yml)

### Установка
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_postgresql$ vagrant reload
==> master: Attempting graceful shutdown of VM...
==> master: Checking if box 'ubuntu/22.04' version '1.0.0' is up to date...
==> master: Clearing any previously set forwarded ports...
==> master: Clearing any previously set network interfaces...
==> master: Preparing network interfaces based on configuration...
    master: Adapter 1: nat
    master: Adapter 2: bridged
==> master: Forwarding ports...
    master: 22 (guest) => 2222 (host) (adapter 1)
    master: 22 (guest) => 2222 (host) (adapter 1)
==> master: Running 'pre-boot' VM customizations...
==> master: Booting VM...
==> master: Waiting for machine to boot. This may take a few minutes...
    master: SSH address: 127.0.0.1:2222
    master: SSH username: vagrant
    master: SSH auth method: private key
    master: Warning: Connection reset. Retrying...
==> master: Machine booted and ready!
==> master: Checking for guest additions in VM...
    master: The guest additions on this VM do not match the installed version of
    master: VirtualBox! In most cases this is fine, but in rare cases it can
    master: prevent things such as shared folders from working properly. If you see
    master: shared folder errors, please make sure the guest additions within the
    master: virtual machine match the version of VirtualBox you have installed on
    master: your host and reload your VM.
    master:
    master: Guest Additions Version: 6.0.0 r127566
    master: VirtualBox Version: 7.2
==> master: Setting hostname...
==> master: Configuring and enabling network interfaces...
==> master: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> master: flag to force provisioning. Provisioners marked to run always will still run.
==> slave: Attempting graceful shutdown of VM...
==> slave: Checking if box 'ubuntu/22.04' version '1.0.0' is up to date...
==> slave: Clearing any previously set forwarded ports...
==> slave: Fixed port collision for 22 => 2222. Now on port 2200.
==> slave: Clearing any previously set network interfaces...
==> slave: Preparing network interfaces based on configuration...
    slave: Adapter 1: nat
    slave: Adapter 2: bridged
==> slave: Forwarding ports...
    slave: 22 (guest) => 2200 (host) (adapter 1)
    slave: 22 (guest) => 2200 (host) (adapter 1)
==> slave: Running 'pre-boot' VM customizations...
==> slave: Booting VM...
==> slave: Waiting for machine to boot. This may take a few minutes...
    slave: SSH address: 127.0.0.1:2200
    slave: SSH username: vagrant
    slave: SSH auth method: private key
    slave: Warning: Connection reset. Retrying...
==> slave: Machine booted and ready!
==> slave: Checking for guest additions in VM...
    slave: The guest additions on this VM do not match the installed version of
    slave: VirtualBox! In most cases this is fine, but in rare cases it can
    slave: prevent things such as shared folders from working properly. If you see
    slave: shared folder errors, please make sure the guest additions within the
    slave: virtual machine match the version of VirtualBox you have installed on
    slave: your host and reload your VM.
    slave:
    slave: Guest Additions Version: 6.0.0 r127566
    slave: VirtualBox Version: 7.2
==> slave: Setting hostname...
==> slave: Configuring and enabling network interfaces...
==> slave: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> slave: flag to force provisioning. Provisioners marked to run always will still run.
==> barman: Attempting graceful shutdown of VM...
==> barman: Checking if box 'ubuntu/22.04' version '1.0.0' is up to date...
==> barman: Clearing any previously set forwarded ports...
==> barman: Fixed port collision for 22 => 2222. Now on port 2201.
==> barman: Clearing any previously set network interfaces...
==> barman: Preparing network interfaces based on configuration...
    barman: Adapter 1: nat
    barman: Adapter 2: bridged
==> barman: Forwarding ports...
    barman: 22 (guest) => 2201 (host) (adapter 1)
    barman: 22 (guest) => 2201 (host) (adapter 1)
==> barman: Running 'pre-boot' VM customizations...
==> barman: Booting VM...
==> barman: Waiting for machine to boot. This may take a few minutes...
    barman: SSH address: 127.0.0.1:2201
    barman: SSH username: vagrant
    barman: SSH auth method: private key
    barman: Warning: Connection reset. Retrying...
    barman: Warning: Connection reset. Retrying...
==> barman: Machine booted and ready!
==> barman: Checking for guest additions in VM...
    barman: The guest additions on this VM do not match the installed version of
    barman: VirtualBox! In most cases this is fine, but in rare cases it can
    barman: prevent things such as shared folders from working properly. If you see
    barman: shared folder errors, please make sure the guest additions within the
    barman: virtual machine match the version of VirtualBox you have installed on
    barman: your host and reload your VM.
    barman:
    barman: Guest Additions Version: 6.0.0 r127566
    barman: VirtualBox Version: 7.2
==> barman: Setting hostname...
==> barman: Configuring and enabling network interfaces...
==> barman: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> barman: flag to force provisioning. Provisioners marked to run always will still run.
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_postgresql$ vagrant provision
==> barman: Running provisioner: ansible...
    barman: Running ansible-playbook...
[WARNING]: Deprecation warnings can be disabled by setting `deprecation_warnings=False` in ansible.cfg.
[DEPRECATION WARNING]: The '--inventory-file' argument is deprecated. This feature will be removed from ansible-core version 2.23. instead.

PLAY [Установка postgres и настройка репликации] *******************************

TASK [Gathering Facts] *********************************************************
[WARNING]: Host 'slave' is using the discovered Python interpreter at '/usr/bin/python3.10', but future installation of another Py cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_d information.
ok: [slave]
[WARNING]: Host 'master' is using the discovered Python interpreter at '/usr/bin/python3.10', but future installation of another Pd cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_e information.
ok: [master]

TASK [install_postgres : install postgresql-server 14] *************************
ok: [master]
ok: [slave]

TASK [install_postgres : enable and start service] *****************************
ok: [master]
ok: [slave]

TASK [postgres_replication : install base tools] *******************************
ok: [slave]
ok: [master]

TASK [postgres_replication : Create replicator user] ***************************
skipping: [slave]
ok: [master]

TASK [postgres_replication : stop postgresql-server on slave] ******************
skipping: [master]
changed: [slave]

TASK [postgres_replication : copy postgresql.conf] *****************************
[DEPRECATION WARNING]: INJECT_FACTS_AS_VARS default to `True` is deprecated, top-level facts will not be auto injected after the cll be removed from ansible-core version 2.24.
Origin: /mnt/c/Vagrant/vagrant_postgresql/ansible/roles/postgres_replication/templates/postgresql.conf.j2

Use `ansible_facts["fact_name"]` (no `ansible_` prefix) instead.

ok: [master]
ok: [slave]

TASK [postgres_replication : copy pg_hba.conf] *********************************
ok: [slave]
ok: [master]

TASK [postgres_replication : restart postgresql-server on master] **************
skipping: [slave]
changed: [master]

TASK [postgres_replication : Remove files from data catalog on slave] **********
skipping: [master]
changed: [slave]

TASK [postgres_replication : copy files from master to slave (pg_basebackup)] ***
skipping: [master]
changed: [slave]

TASK [postgres_replication : start postgresql-server on slave] *****************
skipping: [master]
changed: [slave]

PLAY [Настройка резервного копирования (Barman)] *******************************

TASK [Gathering Facts] *********************************************************
ok: [slave]
ok: [master]
[WARNING]: Host 'barman' is using the discovered Python interpreter at '/usr/bin/python3.10', but future installation of another Pd cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_e information.
ok: [barman]

TASK [install_barman : install base tools] *************************************
ok: [slave]
ok: [master]
ok: [barman]

TASK [install_barman : install barman and postgresql packages on barman] *******
skipping: [master]
skipping: [slave]
ok: [barman]

TASK [install_barman : install barman-cli on nodes] ****************************
skipping: [barman]
ok: [master]
ok: [slave]

TASK [install_barman : generate SSH key for postgres] **************************
skipping: [slave]
skipping: [barman]
[WARNING]: Found existing ssh key private file "/var/lib/postgresql/.ssh/id_rsa", no force, so skipping ssh-keygen generation
ok: [master]

TASK [install_barman : generate SSH key for barman] ****************************
skipping: [master]
skipping: [slave]
[WARNING]: Found existing ssh key private file "/var/lib/barman/.ssh/id_rsa", no force, so skipping ssh-keygen generation
ok: [barman]

TASK [install_barman : fetch all public ssh keys master] ***********************
skipping: [slave]
skipping: [barman]
changed: [master]

TASK [install_barman : transfer public key to barman] **************************
skipping: [slave]
skipping: [barman]
[DEPRECATION WARNING]: Importing 'to_native' from 'ansible.module_utils._text' is deprecated. This feature will be removed from an4. Use ansible.module_utils.common.text.converters instead.
ok: [master -> barman(192.168.77.152)]

TASK [install_barman : fetch all public ssh keys barman] ***********************
skipping: [master]
skipping: [slave]
changed: [barman]

TASK [install_barman : transfer public key to master] **************************
skipping: [master]
skipping: [slave]
ok: [barman -> master(192.168.77.150)]

TASK [install_barman : Create barman user in postgres] *************************
skipping: [slave]
skipping: [barman]
ok: [master]

TASK [install_barman : restart postgresql-server on master] ********************
skipping: [slave]
skipping: [barman]
changed: [master]

TASK [install_barman : Create DB for backup] ***********************************
skipping: [slave]
skipping: [barman]
ok: [master]

TASK [install_barman : Add tables to otus_backup] ******************************
skipping: [slave]
skipping: [barman]
[DEPRECATION WARNING]: Alias 'db' is deprecated. See the module docs for more information. This feature will be removed from colleresql' version 5.0.0.
ok: [master]

TASK [install_barman : copy .pgpass] *******************************************
skipping: [master]
skipping: [slave]
ok: [barman]

TASK [install_barman : copy barman.conf] ***************************************
skipping: [master]
skipping: [slave]
ok: [barman]

TASK [install_barman : copy master.conf] ***************************************
skipping: [master]
skipping: [slave]
ok: [barman]

TASK [install_barman : barman switch-wal master] *******************************
skipping: [master]
skipping: [slave]
changed: [barman]

TASK [install_barman : barman cron] ********************************************
skipping: [master]
skipping: [slave]
changed: [barman]

PLAY RECAP *********************************************************************
barman                     : ok=11   changed=3    unreachable=0    failed=0    skipped=8    rescued=0    ignored=0
master                     : ok=18   changed=3    unreachable=0    failed=0    skipped=13   rescued=0    ignored=0
slave                      : ok=13   changed=4    unreachable=0    failed=0    skipped=18   rescued=0    ig
```

### Проверка
>  Проверка репликации (Master - Slave)
> 
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_postgresql$ vagrant ssh master
Welcome to Ubuntu 22.04.2 LTS (GNU/Linux 5.15.0-173-generic x86_64)
...
 
Last login: Tue Mar 31 11:04:59 2026 from 192.168.77.5
vagrant@master:~$ sudo -u postgres psql
could not change directory to "/home/vagrant": Permission denied
psql (14.22 (Ubuntu 14.22-0ubuntu0.22.04.1))
Type "help" for help.

postgres=# \l
                              List of databases
   Name    |  Owner   | Encoding | Collate |  Ctype  |   Access privileges
-----------+----------+----------+---------+---------+-----------------------
 otus      | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 postgres  | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 template0 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
 template1 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
(4 rows)

postgres=# CREATE DATABASE test_replication;
CREATE DATABASE
postgres=# \l
                                 List of databases
       Name       |  Owner   | Encoding | Collate |  Ctype  |   Access privileges
------------------+----------+----------+---------+---------+-----------------------
 otus             | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 postgres         | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 template0        | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
                  |          |          |         |         | postgres=CTc/postgres
 template1        | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
                  |          |          |         |         | postgres=CTc/postgres
 test_replication | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
(5 rows)

postgres=#

```
> Проверка статуса репликаци на Master
```shell
vagrant@master:~$ sudo -u postgres psql
ostgres=# SELECT * FROM pg_stat_replication;

pid  | usesysid |   usename   |  application_name  |  client_addr   | client_hostname | client_port |         backend_start         | backend_xmin |   state   |  sent_lsn  | write_lsn  | flush_lsn  | replay_lsn |    write_lag    |    flush_lag    |   replay_lag    | sync_priority | sync_state |          reply_time
------+----------+-------------+--------------------+----------------+-----------------+-------------+-------------------------------+--------------+-----------+------------+------------+------------+------------+-----------------+-----------------+-----------------+---------------+------------+-------------------------------
 9168 |    16384 | replication | walreceiver        | 192.168.77.151 |                 |       52562 | 2026-03-31 08:05:01.376963-03 |          740 | streaming | 0/24000000 | 0/24000000 | 0/24000000 | 0/24000000 |                 |                 |                 |             0 | async      | 2026-03-31 08:17:58.009362-03
 9174 |    16385 | barman      | barman_receive_wal | 192.168.77.152 |                 |       51840 | 2026-03-31 08:05:01.999905-03 |              | streaming | 0/24000000 | 0/24000000 | 0/24000000 |            | 00:00:06.081986 | 00:00:06.081986 | 00:13:01.933048 |             0 | async      | 2026-03-31 08:18:03.944682-03
(2 rows)

```
> Проверка что с репликацией на Slave 
>>  Вывод, это означает, что сервер находится в режиме горячего резерва (Hot Standby) и не принимает запись напрямую. ВСё ок.
```shell
vagrant@slave:~$ sudo -u postgres psql
could not change directory to "/home/vagrant": Permission denied
psql (14.22 (Ubuntu 14.22-0ubuntu0.22.04.1))
Type "help" for help.

postgres=# \l
                                 List of databases
       Name       |  Owner   | Encoding | Collate |  Ctype  |   Access privileges
------------------+----------+----------+---------+---------+-----------------------
 otus             | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 postgres         | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 template0        | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
                  |          |          |         |         | postgres=CTc/postgres
 template1        | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
                  |          |          |         |         | postgres=CTc/postgres
 test_replication | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
(5 rows)

postgres=# SELECT pg_is_in_recovery();
 pg_is_in_recovery
-------------------
 t
(1 row)

```
> Проверка резервного копирования (Barman)
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_postgresql$ vagrant ssh barman
Welcome to Ubuntu 22.04.2 LTS (GNU/Linux 5.15.0-173-generic x86_64)

vagrant@barman:~$ sudo -u barman -i
barman@barman:~$ barman backup master
Starting backup using postgres method for server master in /var/lib/barman/master/base/20260331T110725
Backup start at LSN: 0/1E000060 (00000001000000000000001E, 00000060)
Starting backup copy via pg_basebackup for 20260331T110725
WARNING: pg_basebackup does not copy the PostgreSQL configuration files that reside outside PGDATA. Please manually backup the following files:
        /etc/postgresql/14/main/postgresql.conf
        /etc/postgresql/14/main/pg_hba.conf
        /etc/postgresql/14/main/pg_ident.conf

Copy done (time: 4 seconds)
Finalising the backup.
This is the first backup for server master
WAL segments preceding the current backup have been found:
        000000010000000000000008 from server master has been removed
        000000010000000000000009 from server master has been removed
        00000001000000000000000A from server master has been removed
        00000001000000000000000B from server master has been removed
        00000001000000000000000C from server master has been removed
        00000001000000000000000D from server master has been removed
        00000001000000000000000E from server master has been removed
        00000001000000000000000F from server master has been removed
        000000010000000000000010 from server master has been removed
        000000010000000000000011 from server master has been removed
        000000010000000000000012 from server master has been removed
        000000010000000000000013 from server master has been removed
        000000010000000000000014 from server master has been removed
        000000010000000000000015 from server master has been removed
        000000010000000000000016 from server master has been removed
        000000010000000000000017 from server master has been removed
        000000010000000000000018 from server master has been removed
        000000010000000000000019 from server master has been removed
        00000001000000000000001A from server master has been removed
        00000001000000000000001B from server master has been removed
        00000001000000000000001C from server master has been removed
        00000001000000000000001D from server master has been removed
Backup size: 41.8 MiB
Backup end at LSN: 0/20000000 (00000001000000000000001F, 00000000)
Backup completed (start time: 2026-03-31 11:07:25.778770, elapsed time: 4 seconds)
Processing xlog segments from streaming for master
        00000001000000000000001E
        00000001000000000000001F
barman@barman:~$ barman check master
Server master:
        empty incoming directory: FAILED ('/var/lib/barman/master/incoming' must be empty when archiver=off)
        PostgreSQL: OK
        superuser or standard user with backup privileges: OK
        PostgreSQL streaming: OK
        wal_level: OK
        replication slot: OK
        directories: OK
        retention policy settings: OK
        backup maximum age: OK (interval provided: 4 days, latest backup age: 4 seconds)
        backup minimum size: OK (41.8 MiB)
        wal maximum age: OK (no last_wal_maximum_age provided)
        wal size: OK (0 B)
        compression settings: OK
        failed backups: OK (there are 0 failed backups)
        minimum redundancy requirements: OK (have 1 backups, expected at least 1)
        pg_basebackup: OK
        pg_basebackup compatible: OK
        pg_basebackup supports tablespaces mapping: OK
        systemid coherence: OK
        pg_receivexlog: OK
        pg_receivexlog compatible: OK
        receive-wal running: OK
        archiver errors: OK

```
> Проверка восстановления 
>> Создал имитацию сбоя на Master, удалил БД
```shell
vagrant@master:~$ sudo -u postgres psql
could not change directory to "/home/vagrant": Permission denied
psql (14.22 (Ubuntu 14.22-0ubuntu0.22.04.1))
Type "help" for help.

postgres=# \l
                                 List of databases
       Name       |  Owner   | Encoding | Collate |  Ctype  |   Access privileges
------------------+----------+----------+---------+---------+-----------------------
 otus             | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 postgres         | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 template0        | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
                  |          |          |         |         | postgres=CTc/postgres
 template1        | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
                  |          |          |         |         | postgres=CTc/postgres
 test_replication | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
(5 rows)

postgres=# DROP DATABASE test_replication;
DROP DATABASE
postgres=# \l
                              List of databases
   Name    |  Owner   | Encoding | Collate |  Ctype  |   Access privileges
-----------+----------+----------+---------+---------+-----------------------
 otus      | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 postgres  | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 template0 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
 template1 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
(4 rows)

postgres=#

```
> На сервере Barman
```shell
vagrant@barman:~$ sudo -u barman -i
barman@barman:~$ barman list-backups master
master 20260331T115501 - Tue Mar 31 08:55:05 2026 - Size: 41.8 MiB - WAL Size: 16.1 KiB
master 20260331T110725 - Tue Mar 31 08:07:29 2026 - Size: 41.8 MiB - WAL Size: 113.4 KiB
barman@barman:~$ barman recover master latest /var/lib/postgresql/14/main/ --remote-ssh-command "ssh postgres@192.168.77.150"
The authenticity of host '192.168.77.150 (192.168.77.150)' can't be established.
ED25519 key fingerprint is SHA256:5CdCirwUggORsr48vJJOtnS30yBN4VnBqetdkZ27GRA.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Starting remote restore for server master using backup 20260331T115501
Destination directory: /var/lib/postgresql/14/main/
Remote command: ssh postgres@192.168.77.150
Copying the base backup.
Copying required WAL segments.
Generating archive status files
Identify dangerous settings in destination directory.

WARNING
The following configuration files have not been saved during backup, hence they have not been restored.
You need to manually restore them in order to start the recovered PostgreSQL instance:

    postgresql.conf
    pg_hba.conf
    pg_ident.conf

Recovery completed (start time: 2026-03-31 11:59:57.550233, elapsed time: 8 seconds)

Your PostgreSQL server has been successfully prepared for recovery!

```
> Проверка восстановления БД 
```shell
vagrant@master:~$ sudo -u postgres psql
could not change directory to "/home/vagrant": Permission denied
psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: No such file or directory
        Is the server running locally and accepting connections on that socket?
vagrant@master:~$ sudo systemctl restart postgresql
vagrant@master:~$ sudo systemctl status postgresql
● postgresql.service - PostgreSQL RDBMS
     Loaded: loaded (/lib/systemd/system/postgresql.service; enabled; vendor preset: enabled)
     Active: active (exited) since Tue 2026-03-31 12:03:07 UTC; 5s ago
    Process: 10924 ExecStart=/bin/true (code=exited, status=0/SUCCESS)
   Main PID: 10924 (code=exited, status=0/SUCCESS)
        CPU: 2ms

Mar 31 12:03:07 master systemd[1]: Starting PostgreSQL RDBMS...
Mar 31 12:03:07 master systemd[1]: Finished PostgreSQL RDBMS.
vagrant@master:~$ sudo -u postgres psql
could not change directory to "/home/vagrant": Permission denied
psql (14.22 (Ubuntu 14.22-0ubuntu0.22.04.1))
Type "help" for help.

postgres=# \l
                                 List of databases
       Name       |  Owner   | Encoding | Collate |  Ctype  |   Access privileges
------------------+----------+----------+---------+---------+-----------------------
 otus             | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 postgres         | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 template0        | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
                  |          |          |         |         | postgres=CTc/postgres
 template1        | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
                  |          |          |         |         | postgres=CTc/postgres
 test_replication | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
(5 rows)

postgres=# \q

```
>> БД "test_replication" была восстановлена. Всё работает. 