# Домашнее задание 17
## Настраиваем центральный сервер для сбора логов

### Цель:
- научится проектировать централизованный сбор логов;
- рассмотреть особенности разных платформ для сбора логов.

### Описание/Пошаговая инструкция выполнения домашнего задания:
🎯 Что нужно сделать?
- Поднимаем две машины — web и log.
- На web поднимаем nginx.
- Настраиваем центральный лог-сервер на любой системе по выбору:
  - journald;
  - rsyslog;
  - elk.
- Настраиваем аудит, который будет отслеживать изменения конфигураций nginx.
- Все критичные логи с web должны собираться и локально и удаленно.
- Все логи с nginx должны уходить на удаленный сервер (локально только критичные).
- Логи аудита должны также уходить на удаленную систему.

---
## Пошаговое выполнение задания.
> Вот тут файл, который поднимает две машины - web(nginx) и log --> [Vagrantfile](vagrant_log/Vagrantfile)

> Тут все настройки для серверов --> [Ansible](vagrant_log/ansible/playbook.yml)

> Сама установка:
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_log$ vagrant up
Bringing machine 'web' up with 'virtualbox' provider...
Bringing machine 'log' up with 'virtualbox' provider...
==> web: Importing base box 'almalinux/9'...
==> web: Matching MAC address for NAT networking...
==> web: Checking if box 'almalinux/9' version '1.0.0' is up to date...
==> web: Setting the name of the VM: vagrant_log_web_1772912461739_6177
==> web: Clearing any previously set network interfaces...
==> web: Preparing network interfaces based on configuration...
    web: Adapter 1: nat
    web: Adapter 2: hostonly
==> web: Forwarding ports...
    web: 22 (guest) => 2222 (host) (adapter 1)
    web: 22 (guest) => 2222 (host) (adapter 1)
==> web: Running 'pre-boot' VM customizations...
==> web: Booting VM...
==> web: Waiting for machine to boot. This may take a few minutes...
    web: SSH address: 127.0.0.1:2222
    web: SSH username: vagrant
    web: SSH auth method: private key
    web:
    web: Vagrant insecure key detected. Vagrant will automatically replace
    web: this with a newly generated keypair for better security.
    web:
    web: Inserting generated public key within guest...
    web: Removing insecure key from the guest if it's present...
    web: Key inserted! Disconnecting and reconnecting using new SSH key...
==> web: Machine booted and ready!
==> web: Checking for guest additions in VM...
    web: The guest additions on this VM do not match the installed version of
    web: VirtualBox! In most cases this is fine, but in rare cases it can
    web: prevent things such as shared folders from working properly. If you see
    web: shared folder errors, please make sure the guest additions within the
    web: virtual machine match the version of VirtualBox you have installed on
    web: your host and reload your VM.
    web:
    web: Guest Additions Version: 7.1.4
    web: VirtualBox Version: 7.2
==> web: Setting hostname...
==> web: Configuring and enabling network interfaces...
==> web: Mounting shared folders...
    web: /mnt/c/Vagrant/vagrant_log => /vagrant
==> web: Running provisioner: shell...
    web: Running: inline script
    web: AlmaLinux 9 - AppStream                          11 MB/s |  16 MB     00:01
    web: AlmaLinux 9 - BaseOS                             14 MB/s |  17 MB     00:01
    web: AlmaLinux 9 - Extras                             40 kB/s |  20 kB     00:00
    web: Package python3-3.9.19-8.el9_5.1.x86_64 is already installed.
    web: Dependencies resolved.
    web: ================================================================================
    web:  Package                   Arch       Version               Repository     Size
    web: ================================================================================
    web: Installing:
    web:  nano                      x86_64     5.6.1-7.el9           baseos        692 k
    web: Upgrading:
    web:  openssl                   x86_64     1:3.5.1-7.el9_7       baseos        1.4 M
    web:  openssl-devel             x86_64     1:3.5.1-7.el9_7       appstream     3.4 M
    web:  openssl-libs              x86_64     1:3.5.1-7.el9_7       baseos        2.3 M
    web:  python3                   x86_64     3.9.25-3.el9_7        baseos         26 k
    web:  python3-libs              x86_64     3.9.25-3.el9_7        baseos        7.5 M
    web: Installing dependencies:
    web:  openssl-fips-provider     x86_64     1:3.5.1-7.el9_7       baseos        812 k
    web:
    web: Transaction Summary
    web: ================================================================================
    web: Install  2 Packages
    web: Upgrade  5 Packages
    web:
    web: Total download size: 16 M
    web: Downloading Packages:
    web: (1/7): openssl-fips-provider-3.5.1-7.el9_7.x86_ 4.5 MB/s | 812 kB     00:00
    web: (2/7): openssl-devel-3.5.1-7.el9_7.x86_64.rpm    16 MB/s | 3.4 MB     00:00
    web: (3/7): openssl-3.5.1-7.el9_7.x86_64.rpm          18 MB/s | 1.4 MB     00:00
    web: (4/7): python3-3.9.25-3.el9_7.x86_64.rpm        390 kB/s |  26 kB     00:00
    web: (5/7): nano-5.6.1-7.el9.x86_64.rpm              1.8 MB/s | 692 kB     00:00
    web: (6/7): python3-libs-3.9.25-3.el9_7.x86_64.rpm    17 MB/s | 7.5 MB     00:00
    web: (7/7): openssl-libs-3.5.1-7.el9_7.x86_64.rpm    4.0 MB/s | 2.3 MB     00:00
    web: --------------------------------------------------------------------------------
    web: Total                                           9.7 MB/s |  16 MB     00:01
    web: Running transaction check
    web: Transaction check succeeded.
    web: Running transaction test
    web: Transaction test succeeded.
    web: Running transaction
    web:   Preparing        :                                                        1/1
    web:   Upgrading        : openssl-libs-1:3.5.1-7.el9_7.x86_64                   1/12
    web:   Installing       : openssl-fips-provider-1:3.5.1-7.el9_7.x86_64          2/12
    web:   Upgrading        : python3-3.9.25-3.el9_7.x86_64                         3/12
    web:   Upgrading        : python3-libs-3.9.25-3.el9_7.x86_64                    4/12
    web:   Upgrading        : openssl-devel-1:3.5.1-7.el9_7.x86_64                  5/12
    web:   Upgrading        : openssl-1:3.5.1-7.el9_7.x86_64                        6/12
    web:   Installing       : nano-5.6.1-7.el9.x86_64                               7/12
    web:   Cleanup          : openssl-devel-1:3.2.2-6.el9_5.x86_64                  8/12
    web:   Cleanup          : openssl-1:3.2.2-6.el9_5.x86_64                        9/12
    web:   Cleanup          : python3-3.9.19-8.el9_5.1.x86_64                      10/12
    web:   Cleanup          : python3-libs-3.9.19-8.el9_5.1.x86_64                 11/12
    web:   Cleanup          : openssl-libs-1:3.2.2-6.el9_5.x86_64                  12/12
    web:   Running scriptlet: openssl-libs-1:3.2.2-6.el9_5.x86_64                  12/12
    web:   Verifying        : nano-5.6.1-7.el9.x86_64                               1/12
    web:   Verifying        : openssl-fips-provider-1:3.5.1-7.el9_7.x86_64          2/12
    web:   Verifying        : openssl-devel-1:3.5.1-7.el9_7.x86_64                  3/12
    web:   Verifying        : openssl-devel-1:3.2.2-6.el9_5.x86_64                  4/12
    web:   Verifying        : openssl-1:3.5.1-7.el9_7.x86_64                        5/12
    web:   Verifying        : openssl-1:3.2.2-6.el9_5.x86_64                        6/12
    web:   Verifying        : openssl-libs-1:3.5.1-7.el9_7.x86_64                   7/12
    web:   Verifying        : openssl-libs-1:3.2.2-6.el9_5.x86_64                   8/12
    web:   Verifying        : python3-3.9.25-3.el9_7.x86_64                         9/12
    web:   Verifying        : python3-3.9.19-8.el9_5.1.x86_64                      10/12
    web:   Verifying        : python3-libs-3.9.25-3.el9_7.x86_64                   11/12
    web:   Verifying        : python3-libs-3.9.19-8.el9_5.1.x86_64                 12/12
    web:
    web: Upgraded:
    web:   openssl-1:3.5.1-7.el9_7.x86_64         openssl-devel-1:3.5.1-7.el9_7.x86_64
    web:   openssl-libs-1:3.5.1-7.el9_7.x86_64    python3-3.9.25-3.el9_7.x86_64
    web:   python3-libs-3.9.25-3.el9_7.x86_64
    web: Installed:
    web:   nano-5.6.1-7.el9.x86_64      openssl-fips-provider-1:3.5.1-7.el9_7.x86_64
    web:
    web: Complete!
==> web: Running provisioner: ansible...
    web: Running ansible-playbook...
[WARNING]: Deprecation warnings can be disabled by setting `deprecation_warnings=False` in ansible.cfg.
[DEPRECATION WARNING]: The '--inventory-file' argument is deprecated. This feature will be removed from ansible-core version 2.23. Use -i or --inventory instead.
[WARNING]: Found both group and host with same name: web

PLAY [Prepare Infrastructure] **************************************************

TASK [Gathering Facts] *********************************************************
[WARNING]: Host 'web' is using the discovered Python interpreter at '/usr/bin/python3.9', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_discovery.html for more information.
ok: [web]

TASK [Disable SELinux] *********************************************************
[WARNING]: SELinux state temporarily changed from 'enforcing' to 'permissive'. State change will take effect next reboot.
changed: [web]

TASK [Ensure SELinux is disabled in config] ************************************
ok: [web]

TASK [Stop and disable Firewalld (to avoid issues in Vagrant)] *****************
[ERROR]: Task failed: Module failed: Could not find the requested service firewalld: host
Origin: /mnt/c/Vagrant/vagrant_log/ansible/playbook.yml:16:7

14         line: 'SELINUX=disabled'
15
16     - name: Stop and disable Firewalld (to avoid issues in Vagrant)
         ^ column 7

fatal: [web]: FAILED! => {"changed": false, "msg": "Could not find the requested service firewalld: host"}
...ignoring

PLAY [Configure Central Log Server] ********************************************
skipping: no hosts matched

PLAY [Configure Web Server] ****************************************************

TASK [Gathering Facts] *********************************************************
ok: [web]

TASK [Install Nginx, rsyslog and auditd] ***************************************
changed: [web]

TASK [Configure Nginx logging in nginx.conf] ***********************************
changed: [web]

TASK [Configure rsyslog for Audit and Critical logs] ***************************
changed: [web]

TASK [Set auditd rules for Nginx configs] **************************************
changed: [web]

TASK [Start services] **********************************************************
changed: [web] => (item=nginx)
ok: [web] => (item=rsyslog)
ok: [web] => (item=auditd)

RUNNING HANDLER [check and restart nginx] **************************************
changed: [web]

RUNNING HANDLER [restart rsyslog] **********************************************
changed: [web]

RUNNING HANDLER [restart auditd] ***********************************************
changed: [web]

PLAY RECAP *********************************************************************
web                        : ok=13   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=1

==> log: Importing base box 'almalinux/9'...
==> log: Matching MAC address for NAT networking...
==> log: Checking if box 'almalinux/9' version '1.0.0' is up to date...
==> log: Setting the name of the VM: vagrant_log_log_1772912544126_73280
==> log: Fixed port collision for 22 => 2222. Now on port 2200.
==> log: Clearing any previously set network interfaces...
==> log: Preparing network interfaces based on configuration...
    log: Adapter 1: nat
    log: Adapter 2: hostonly
==> log: Forwarding ports...
    log: 22 (guest) => 2200 (host) (adapter 1)
    log: 22 (guest) => 2200 (host) (adapter 1)
==> log: Running 'pre-boot' VM customizations...
==> log: Booting VM...
==> log: Waiting for machine to boot. This may take a few minutes...
    log: SSH address: 127.0.0.1:2200
    log: SSH username: vagrant
    log: SSH auth method: private key
    log:
    log: Vagrant insecure key detected. Vagrant will automatically replace
    log: this with a newly generated keypair for better security.
    log:
    log: Inserting generated public key within guest...
    log: Removing insecure key from the guest if it's present...
    log: Key inserted! Disconnecting and reconnecting using new SSH key...
==> log: Machine booted and ready!
==> log: Checking for guest additions in VM...
    log: The guest additions on this VM do not match the installed version of
    log: VirtualBox! In most cases this is fine, but in rare cases it can
    log: prevent things such as shared folders from working properly. If you see
    log: shared folder errors, please make sure the guest additions within the
    log: virtual machine match the version of VirtualBox you have installed on
    log: your host and reload your VM.
    log:
    log: Guest Additions Version: 7.1.4
    log: VirtualBox Version: 7.2
==> log: Setting hostname...
==> log: Configuring and enabling network interfaces...
==> log: Mounting shared folders...
    log: /mnt/c/Vagrant/vagrant_log => /vagrant
==> log: Running provisioner: shell...
    log: Running: inline script
    log: AlmaLinux 9 - AppStream                         7.9 MB/s |  16 MB     00:02
    log: AlmaLinux 9 - BaseOS                             14 MB/s |  17 MB     00:01
    log: AlmaLinux 9 - Extras                             40 kB/s |  20 kB     00:00
    log: Package python3-3.9.19-8.el9_5.1.x86_64 is already installed.
    log: Dependencies resolved.
    log: ================================================================================
    log:  Package                   Arch       Version               Repository     Size
    log: ================================================================================
    log: Installing:
    log:  nano                      x86_64     5.6.1-7.el9           baseos        692 k
    log: Upgrading:
    log:  openssl                   x86_64     1:3.5.1-7.el9_7       baseos        1.4 M
    log:  openssl-devel             x86_64     1:3.5.1-7.el9_7       appstream     3.4 M
    log:  openssl-libs              x86_64     1:3.5.1-7.el9_7       baseos        2.3 M
    log:  python3                   x86_64     3.9.25-3.el9_7        baseos         26 k
    log:  python3-libs              x86_64     3.9.25-3.el9_7        baseos        7.5 M
    log: Installing dependencies:
    log:  openssl-fips-provider     x86_64     1:3.5.1-7.el9_7       baseos        812 k
    log:
    log: Transaction Summary
    log: ================================================================================
    log: Install  2 Packages
    log: Upgrade  5 Packages
    log:
    log: Total download size: 16 M
    log: Downloading Packages:
    log: (1/7): openssl-fips-provider-3.5.1-7.el9_7.x86_ 5.0 MB/s | 812 kB     00:00
    log: (2/7): openssl-devel-3.5.1-7.el9_7.x86_64.rpm    18 MB/s | 3.4 MB     00:00
    log: (3/7): nano-5.6.1-7.el9.x86_64.rpm              3.2 MB/s | 692 kB     00:00
    log: (4/7): python3-3.9.25-3.el9_7.x86_64.rpm        1.4 MB/s |  26 kB     00:00
    log: (5/7): openssl-3.5.1-7.el9_7.x86_64.rpm         8.8 MB/s | 1.4 MB     00:00
    log: (6/7): openssl-libs-3.5.1-7.el9_7.x86_64.rpm     15 MB/s | 2.3 MB     00:00
    log: (7/7): python3-libs-3.9.25-3.el9_7.x86_64.rpm   6.7 MB/s | 7.5 MB     00:01
    log: --------------------------------------------------------------------------------
    log: Total                                           7.2 MB/s |  16 MB     00:02
    log: Running transaction check
    log: Transaction check succeeded.
    log: Running transaction test
    log: Transaction test succeeded.
    log: Running transaction
    log:   Preparing        :                                                        1/1
    log:   Upgrading        : openssl-libs-1:3.5.1-7.el9_7.x86_64                   1/12
    log:   Installing       : openssl-fips-provider-1:3.5.1-7.el9_7.x86_64          2/12
    log:   Upgrading        : python3-3.9.25-3.el9_7.x86_64                         3/12
    log:   Upgrading        : python3-libs-3.9.25-3.el9_7.x86_64                    4/12
    log:   Upgrading        : openssl-devel-1:3.5.1-7.el9_7.x86_64                  5/12
    log:   Upgrading        : openssl-1:3.5.1-7.el9_7.x86_64                        6/12
    log:   Installing       : nano-5.6.1-7.el9.x86_64                               7/12
    log:   Cleanup          : openssl-devel-1:3.2.2-6.el9_5.x86_64                  8/12
    log:   Cleanup          : openssl-1:3.2.2-6.el9_5.x86_64                        9/12
    log:   Cleanup          : python3-3.9.19-8.el9_5.1.x86_64                      10/12
    log:   Cleanup          : python3-libs-3.9.19-8.el9_5.1.x86_64                 11/12
    log:   Cleanup          : openssl-libs-1:3.2.2-6.el9_5.x86_64                  12/12
    log:   Running scriptlet: openssl-libs-1:3.2.2-6.el9_5.x86_64                  12/12
    log:   Verifying        : nano-5.6.1-7.el9.x86_64                               1/12
    log:   Verifying        : openssl-fips-provider-1:3.5.1-7.el9_7.x86_64          2/12
    log:   Verifying        : openssl-devel-1:3.5.1-7.el9_7.x86_64                  3/12
    log:   Verifying        : openssl-devel-1:3.2.2-6.el9_5.x86_64                  4/12
    log:   Verifying        : openssl-1:3.5.1-7.el9_7.x86_64                        5/12
    log:   Verifying        : openssl-1:3.2.2-6.el9_5.x86_64                        6/12
    log:   Verifying        : openssl-libs-1:3.5.1-7.el9_7.x86_64                   7/12
    log:   Verifying        : openssl-libs-1:3.2.2-6.el9_5.x86_64                   8/12
    log:   Verifying        : python3-3.9.25-3.el9_7.x86_64                         9/12
    log:   Verifying        : python3-3.9.19-8.el9_5.1.x86_64                      10/12
    log:   Verifying        : python3-libs-3.9.25-3.el9_7.x86_64                   11/12
    log:   Verifying        : python3-libs-3.9.19-8.el9_5.1.x86_64                 12/12
    log:
    log: Upgraded:
    log:   openssl-1:3.5.1-7.el9_7.x86_64         openssl-devel-1:3.5.1-7.el9_7.x86_64
    log:   openssl-libs-1:3.5.1-7.el9_7.x86_64    python3-3.9.25-3.el9_7.x86_64
    log:   python3-libs-3.9.25-3.el9_7.x86_64
    log: Installed:
    log:   nano-5.6.1-7.el9.x86_64      openssl-fips-provider-1:3.5.1-7.el9_7.x86_64
    log:
    log: Complete!
==> log: Running provisioner: ansible...
    log: Running ansible-playbook...
[WARNING]: Deprecation warnings can be disabled by setting `deprecation_warnings=False` in ansible.cfg.
[DEPRECATION WARNING]: The '--inventory-file' argument is deprecated. This feature will be removed from ansible-core version 2.23. Use -i or --inventory instead.
[WARNING]: Found both group and host with same name: log
[WARNING]: Found both group and host with same name: web

PLAY [Prepare Infrastructure] **************************************************

TASK [Gathering Facts] *********************************************************
[WARNING]: Host 'log' is using the discovered Python interpreter at '/usr/bin/python3.9', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_discovery.html for more information.
ok: [log]

TASK [Disable SELinux] *********************************************************
[WARNING]: SELinux state temporarily changed from 'enforcing' to 'permissive'. State change will take effect next reboot.
changed: [log]

TASK [Ensure SELinux is disabled in config] ************************************
ok: [log]

TASK [Stop and disable Firewalld (to avoid issues in Vagrant)] *****************
[ERROR]: Task failed: Module failed: Could not find the requested service firewalld: host
Origin: /mnt/c/Vagrant/vagrant_log/ansible/playbook.yml:16:7

14         line: 'SELINUX=disabled'
15
16     - name: Stop and disable Firewalld (to avoid issues in Vagrant)
         ^ column 7

fatal: [log]: FAILED! => {"changed": false, "msg": "Could not find the requested service firewalld: host"}
...ignoring

PLAY [Configure Central Log Server] ********************************************

TASK [Gathering Facts] *********************************************************
ok: [log]

TASK [Install rsyslog] *********************************************************
ok: [log]

TASK [Enable UDP and TCP reception in rsyslog.conf] ****************************
changed: [log] => (item={'regexp': '^[#\\s]*module\\(load="imudp"\\)', 'line': 'module(load="imudp")'})
changed: [log] => (item={'regexp': '^[#\\s]*input\\(type="imudp" port="514"\\)', 'line': 'input(type="imudp" port="514")'})
changed: [log] => (item={'regexp': '^[#\\s]*module\\(load="imtcp"\\)', 'line': 'module(load="imtcp")'})
changed: [log] => (item={'regexp': '^[#\\s]*input\\(type="imtcp" port="514"\\)', 'line': 'input(type="imtcp" port="514")'})

TASK [Add remote logging rules to the end of rsyslog.conf] *********************
changed: [log]

TASK [Ensure rsyslog is started] ***********************************************
ok: [log]

RUNNING HANDLER [restart rsyslog] **********************************************
changed: [log]

PLAY [Configure Web Server] ****************************************************
skipping: no hosts matched

PLAY RECAP *********************************************************************
log                        : ok=10   changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=1


```

> Проверка Web сервера
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_log$ vagrant ssh web
Last login: Sat Mar  7 19:42:17 2026 from 10.0.2.2

[vagrant@web ~]$ date
Sat Mar  7 07:46:21 PM UTC 2026

[vagrant@web ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: disabled)
     Active: active (running) since Sat 2026-03-07 19:42:15 UTC; 4min 13s ago
    Process: 13153 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 13154 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 13155 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 13156 (nginx)
      Tasks: 3 (limit: 5566)
     Memory: 3.0M
        CPU: 29ms
     CGroup: /system.slice/nginx.service
             ├─13156 "nginx: master process /usr/sbin/nginx"
             ├─13157 "nginx: worker process"
             └─13158 "nginx: worker process"

[vagrant@web ~]$ cat /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;
# BEGIN ANSIBLE MANAGED BLOCK
# Настройка удаленного логирования Access
access_log syslog:server=192.168.56.15:514,tag=nginx_access combined;

# Настройка Error логов: локально (только crit+) и удаленно (все по умолчанию)
error_log /var/log/nginx/error.log crit;
error_log syslog:server=192.168.56.15:514,tag=nginx_error;
# END ANSIBLE MANAGED BLOCK

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }

# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        error_page 404 /404.html;
#            location = /40x.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#            location = /50x.html {
#        }
#    }

}
```
![img.png](img.png)

> Проверка Log Сервера
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_log$ vagrant ssh log
Last login: Sat Mar  7 19:43:34 2026 from 10.0.2.2

[vagrant@log ~]$ sudo -i

[root@log ~]# date
Sat Mar  7 07:48:44 PM UTC 2026

[root@log ~]# systemctl status rsyslog
● rsyslog.service - System Logging Service
     Loaded: loaded (/usr/lib/systemd/system/rsyslog.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-03-07 19:43:35 UTC; 5min ago
       Docs: man:rsyslogd(8)
             https://www.rsyslog.com/doc/
   Main PID: 10244 (rsyslogd)
      Tasks: 9 (limit: 5566)
     Memory: 4.1M
        CPU: 61ms
     CGroup: /system.slice/rsyslog.service
             └─10244 /usr/sbin/rsyslogd -n

Mar 07 19:43:35 log systemd[1]: Starting System Logging Service...
Mar 07 19:43:35 log systemd[1]: Started System Logging Service.
Mar 07 19:43:35 log rsyslogd[10244]: warning: ~ action is deprecated, consider using the 'stop' statement instead [v8.2310.0-4.el9 try https://www.rsyslog.com/e/2307 ]
Mar 07 19:43:35 log rsyslogd[10244]: [origin software="rsyslogd" swVersion="8.2310.0-4.el9" x-pid="10244" x-info="https://www.rsyslog.com"] start
Mar 07 19:43:35 log rsyslogd[10244]: imjournal: journal files changed, reloading...  [v8.2310.0-4.el9 try https://www.rsyslog.com/e/0 ]

[root@log ~]# cat /etc/rsyslog.conf
# rsyslog configuration file

# For more information see /usr/share/doc/rsyslog-*/rsyslog_conf.html
# or latest version online at http://www.rsyslog.com/doc/rsyslog_conf.html
# If you experience problems, see http://www.rsyslog.com/doc/troubleshoot.html

#### GLOBAL DIRECTIVES ####

# Where to place auxiliary files
global(workDirectory="/var/lib/rsyslog")

# Use default timestamp format
module(load="builtin:omfile" Template="RSYSLOG_TraditionalFileFormat")

#### MODULES ####

module(load="imuxsock"    # provides support for local system logging (e.g. via logger command)
       SysSock.Use="off") # Turn off message reception via local log socket;
                          # local messages are retrieved through imjournal now.
module(load="imjournal"             # provides access to the systemd journal
       UsePid="system" # PID nummber is retrieved as the ID of the process the journal entry originates from
       FileCreateMode="0644" # Set the access permissions for the state file
       StateFile="imjournal.state") # File to store the position in the journal
#module(load="imklog") # reads kernel messages (the same are read from journald)
#module(load="immark") # provides --MARK-- message capability

# Include all config files in /etc/rsyslog.d/
include(file="/etc/rsyslog.d/*.conf" mode="optional")

# Provides UDP syslog reception
# for parameters see http://www.rsyslog.com/doc/imudp.html
module(load="imudp")
input(type="imudp" port="514")

# Provides TCP syslog reception
# for parameters see http://www.rsyslog.com/doc/imtcp.html
module(load="imtcp")
input(type="imtcp" port="514")

#### RULES ####

# Log all kernel messages to the console.
# Logging much else clutters up the screen.
#kern.*                                                 /dev/console

# Log anything (except mail) of level info or higher.
# Don't log private authentication messages!
*.info;mail.none;authpriv.none;cron.none                /var/log/messages

# The authpriv file has restricted access.
authpriv.*                                              /var/log/secure

# Log all the mail messages in one place.
mail.*                                                  -/var/log/maillog


# Log cron stuff
cron.*                                                  /var/log/cron

# Everybody gets emergency messages
*.emerg                                                 :omusrmsg:*

# Save news errors of level crit and higher in a special file.
uucp,news.crit                                          /var/log/spooler

# Save boot messages also to boot.log
local7.*                                                /var/log/boot.log

# Правила приёма сообщений от хостов
$template RemoteLogs,"/var/log/rsyslog/%HOSTNAME%/%PROGRAMNAME%.log"
*.* ?RemoteLogs
& ~
# END ANSIBLE MANAGED BLOCK

[root@log ~]# ls -la /var/log/rsyslog/
total 4
drwx------. 4 root root   28 Mar  7 19:43 .
drwxr-xr-x. 9 root root 4096 Mar  7 19:45 ..
drwx------. 2 root root  122 Mar  7 19:44 log
drwx------. 2 root root   48 Mar  7 19:45 web

[root@log ~]# ls -la /var/log/rsyslog/log/
total 28
drwx------. 2 root root  122 Mar  7 19:44 .
drwx------. 4 root root   28 Mar  7 19:43 ..
-rw-------. 1 root root   97 Mar  7 19:44 chronyd.log
-rw-------. 1 root root  610 Mar  7 19:43 rsyslogd.log
-rw-------. 1 root root  632 Mar  7 19:47 sshd.log
-rw-------. 1 root root  299 Mar  7 19:47 sudo.log
-rw-------. 1 root root 4397 Mar  7 19:50 systemd.log
-rw-------. 1 root root  380 Mar  7 19:47 systemd-logind.log

[root@log ~]# ls -la /var/log/rsyslog/web/
total 20
drwx------. 2 root root    48 Mar  7 19:45 .
drwx------. 4 root root    28 Mar  7 19:43 ..
-rw-------. 1 root root 12988 Mar  7 19:46 auditd.log
-rw-------. 1 root root  1550 Mar  7 19:45 nginx_access.log

[root@log ~]# cat /var/log/rsyslog/web/nginx_access.log
Mar  7 19:45:42 web nginx_access: 192.168.56.1 - - [07/Mar/2026:19:45:42 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
Mar  7 19:45:46 web nginx_access: 192.168.56.1 - - [07/Mar/2026:19:45:46 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
Mar  7 19:45:46 web nginx_access: 192.168.56.1 - - [07/Mar/2026:19:45:46 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
Mar  7 19:45:46 web nginx_access: 192.168.56.1 - - [07/Mar/2026:19:45:46 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
Mar  7 19:45:47 web nginx_access: 192.168.56.1 - - [07/Mar/2026:19:45:47 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
Mar  7 19:45:47 web nginx_access: 192.168.56.1 - - [07/Mar/2026:19:45:47 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
Mar  7 19:45:49 web nginx_access: 192.168.56.1 - - [07/Mar/2026:19:45:49 +0000] "GET / HTTP/1.1" 200 5760 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"

[root@log ~]# cat /var/log/rsyslog/web/auditd.log
Mar  7 19:43:35 web auditd type=CRYPTO_KEY_USER msg=audit(1772912615.286:1733): pid=2438 uid=0 auid=1000 ses=3 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=destroy kind=session fp=? direction=both spid=2441 suid=1000 rport=46330 laddr=10.0.2.15 lport=22  exe="/usr/sbin/sshd" hostname=? addr=10.0.2.2 terminal=? res=success'#035UID="root" AUID="vagrant" SUID="vagrant"
Mar  7 19:43:35 web auditd type=CRYPTO_KEY_USER msg=audit(1772912615.286:1734): pid=2438 uid=0 auid=1000 ses=3 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=destroy kind=server fp=SHA256:ed:2e:cf:f8:a9:4d:a7:6a:80:e8:b3:c6:8a:89:e3:61:fb:78:6f:5c:db:7b:f9:24:f2:c8:b4:09:aa:49:15:e6 direction=? spid=2441 suid=1000  exe="/usr/sbin/sshd" hostname=? addr=? terminal=? res=success'#035UID="root" AUID="vagrant" SUID="vagrant"
Mar  7 19:43:35 web auditd type=USER_END msg=audit(1772912615.289:1735): pid=2438 uid=0 auid=1000 ses=3 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=PAM:session_close grantors=pam_selinux,pam_loginuid,pam_selinux,pam_namespace,pam_keyinit,pam_keyinit,pam_limits,pam_systemd,pam_unix,pam_umask,pam_lastlog acct="vagrant" exe="/usr/sbin/sshd" hostname=10.0.2.2 addr=10.0.2.2 terminal=ssh res=success'#035UID="root" AUID="vagrant"
Mar  7 19:43:35 web auditd type=CRED_DISP msg=audit(1772912615.290:1736): pid=2438 uid=0 auid=1000 ses=3 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=PAM:setcred grantors=pam_env,pam_unix acct="vagrant" exe="/usr/sbin/sshd" hostname=10.0.2.2 addr=10.0.2.2 terminal=ssh res=success'#035UID="root" AUID="vagrant"
...
```
> Сгенерировал ошибку на Web и посмотрел что на сервере Log
```shell
[root@web ~]# mv /usr/share/nginx/html/index.html /tmp/
```
```shell
[root@log ~]# cd /var/log/rsyslog/web/

[root@log web]# ls -la
total 24
drwx------. 2 root root    71 Mar  7 19:59 .
drwx------. 4 root root    28 Mar  7 19:43 ..
-rw-------. 1 root root 15382 Mar  7 19:59 auditd.log
-rw-------. 1 root root  3111 Mar  7 19:59 nginx_access.log
-rw-------. 1 root root  1519 Mar  7 19:59 nginx_error.log

[root@log web]# cat ./nginx_error.log
Mar  7 19:59:45 web nginx_error: 2026/03/07 19:59:45 [error] 13157#13157: *3 directory index of "/usr/share/nginx/html/" is forbidden, client: 192.168.56.1, server: _, request: "GET / HTTP/1.1", host: "192.168.56.11"
Mar  7 19:59:46 web nginx_error: 2026/03/07 19:59:46 [error] 13157#13157: *3 directory index of "/usr/share/nginx/html/" is forbidden, client: 192.168.56.1, server: _, request: "GET / HTTP/1.1", host: "192.168.56.11"
Mar  7 19:59:46 web nginx_error: 2026/03/07 19:59:46 [error] 13157#13157: *3 directory index of "/usr/share/nginx/html/" is forbidden, client: 192.168.56.1, server: _, request: "GET / HTTP/1.1", host: "192.168.56.11"
Mar  7 19:59:46 web nginx_error: 2026/03/07 19:59:46 [error] 13157#13157: *3 directory index of "/usr/share/nginx/html/" is forbidden, client: 192.168.56.1, server: _, request: "GET / HTTP/1.1", host: "192.168.56.11"
Mar  7 19:59:47 web nginx_error: 2026/03/07 19:59:47 [error] 13157#13157: *3 directory index of "/usr/share/nginx/html/" is forbidden, client: 192.168.56.1, server: _, request: "GET / HTTP/1.1", host: "192.168.56.11"
Mar  7 19:59:47 web nginx_error: 2026/03/07 19:59:47 [error] 13157#13157: *3 directory index of "/usr/share/nginx/html/" is forbidden, client: 192.168.56.1, server: _, request: "GET / HTTP/1.1", host: "192.168.56.11"
Mar  7 19:59:48 web nginx_error: 2026/03/07 19:59:48 [error] 13157#13157: *3 directory index of "/usr/share/nginx/html/" is forbidden, client: 192.168.56.1, server: _, request: "GET / HTTP/1.1", host: "192.168.56.11"

```
> Установка с 3 машиной тут: 
- [Vagrantfile](vagrant_log2/Vagrantfile)
- [Ansible](vagrant_log2/ansible/playbook.yml)

> Проверка №1 
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_log2$ vagrant ssh log2
Last login: Sat Mar  7 20:17:58 2026 from 10.0.2.2
[vagrant@log2 ~]$ ls -R /var/log/rsyslog/
ls: cannot open directory '/var/log/rsyslog/': Permission denied
[vagrant@log2 ~]$ sudo -i
[root@log2 ~]# ls -R /var/log/rsyslog/
/var/log/rsyslog/:
log  log2  web

/var/log/rsyslog/log:
auditd.log  sshd.log  systemd.log  systemd-logind.log

/var/log/rsyslog/log2:
auditctl.log  chronyd.log  python3.9.log  rsyslogd.log  sshd.log  sudo.log  systemd.log  systemd-logind.log

/var/log/rsyslog/web:
auditd.log  chronyd.log  sshd.log  systemd.log  systemd-logind.log

```
> Изменил конфиг на Web
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_log2$ vagrant ssh web
Last login: Sat Mar  7 20:14:56 2026 from 10.0.2.2
[vagrant@web ~]$ sudo -i

[root@web ~]# nano /etc/nginx/nginx.conf

[root@web ~]# systemctl restart nginx

[root@web ~]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

[root@web ~]# cat /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

    server {
        listen       8080;
        listen       [::]:8080;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }


}


```
> Смотрим что в Log2
```shell
[root@log2 ~]# cat /var/log/rsyslog/web/auditd.log | grep nginx_conf
# тест после изменений

[root@log2 ~]# cat /var/log/rsyslog/web/auditd.log | grep nginx_conf
Mar  7 20:24:56 web auditd type=SYSCALL msg=audit(1772915096.716:1633): arch=c000003e syscall=257 success=yes exit=3 a0=ffffff9c a1=55a1590c2b70 a2=241 a3=1b6 items=2 ppid=13031 pid=13054 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=5 comm="nano" exe="/usr/bin/nano" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="nginx_conf"#035ARCH=x86_64 SYSCALL=openat AUID="vagrant" UID="root" GID="root" EUID="root" SUID="root" FSUID="root" EGID="root" SGID="root" FSGID="root"
Mar  7 20:24:56 web auditd type=SYSCALL msg=audit(1772915096.716:1633): arch=c000003e syscall=257 success=yes exit=3 a0=ffffff9c a1=55a1590c2b70 a2=241 a3=1b6 items=2 ppid=13031 pid=13054 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=5 comm="nano" exe="/usr/bin/nano" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="nginx_conf"#035ARCH=x86_64 SYSCALL=openat AUID="vagrant" UID="root" GID="root" EUID="root" SUID="root" FSUID="root" EGID="root" SGID="root" FSGID="root"

```
The END!