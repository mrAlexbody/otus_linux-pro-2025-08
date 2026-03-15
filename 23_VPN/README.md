# Домашнее задание 23 "VPN"

## Цель:
- Создать домашнюю сетевую лабораторию. Научится настраивать VPN-сервер в Linux-based системах.


## Описание/Пошаговая инструкция выполнения домашнего задания:
### Для выполнения домашнего задания используйте [методичку](https://docs.google.com/document/d/1tJjZQzVccj0UoRlVLa-E-uxQtQDOCuW_sAk2nluiFo4/edit?tab=t.0)

**Что нужно сделать?**

1) Настроить VPN между двумя ВМ в tun/tap режимах, замерить скорость в туннелях, сделать вывод об отличающихся показателях

2) Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на ВМ

**Задание со звездочкой**

3) Самостоятельно изучить и настроить ocserv, подключиться с хоста к ВМ

_P.S, Формат сдачи ДЗ - vagrant + ansible_

---
### Пошаговое выполнение задачи
**Вводные данные:**
- Все дальнейшие действия были проверены при использовании Vagrant 2.4.9
- VirtualBox: 7.0.20 r163906 
- В качестве ОС на хостах установлена Ubuntu 22.04
- Vagrant + Ansible запускается из WSL2 в Windows 11

### Схема

🖥️ **Сервер** (vpn-server)  
├─ eth1: 192.168.56.10  
├─ 🧩 TAP: 10.10.10.1/24  
└─ 🧩 TUN: 10.10.20.1  

💻 **Клиент** (vpn-client)  
├─ eth1: 192.168.56.20  
├─ 🧩 TAP: 10.10.10.2/24  
└─ 🧩 TUN: 10.10.20.2  

🔗 **Внутренняя сеть**: 192.168.56.0/24  

### Таблица интерфейсов с ip 

| Хост         | Интерфейс | Тип сети        | IP-адрес / Подсеть | Описание                          |
|--------------|-----------|-----------------|--------------------|-----------------------------------|
| Server VM    | eth1      | Private Network | 192.168.56.10      | Основной адрес в сети VirtualBox  |
| -            | tap0      | VPN (Задание 1) | 10.10.10.1/24      | L2 туннель (Static Key)           |
| -            | tun0      | VPN (Задание 2) | 10.10.20.1/24      | L3 сервер (PKI / Port 1207)       |
| Client VM    | eth1      | Private Network | 192.168.56.20      | Адрес клиента в сети VirtualBox   |
| -            | tap0      | VPN (Задание 1) | 10.10.10.2/24      | L2 туннель к Server               |
| -            | tun0      | VPN (Задание 2) | 10.10.20.2/24      | L3 клиент (Сертификат client.crt) |
| Host Machine | vboxnet0  | Host-only       | 192.168.56.1       | Доступ к ВМ через WSL2/Windows    |


------------------------------------------------------------------------------------------------------------------
### Конфигурационные файлы
- [Vagrantfile](vagrant_vpn/Vagrantfi)
- [Ansible playbook](vagrant_vpn/ansible/playbook_tap.yml) настройка TAP режима VPN
- [Ansible playbook](vagrant_vpn/ansible/playbook_tun.yml) настройка TUP режима VPN

### Установка и настройка TAP режима VPN
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_vpn$ vagrant up
Bringing machine 'server' up with 'virtualbox' provider...
Bringing machine 'client' up with 'virtualbox' provider...
==> server: Importing base box 'ubuntu/22.04'...
==> server: Matching MAC address for NAT networking...
==> server: Checking if box 'ubuntu/22.04' version '1.0.0' is up to date...
==> server: Setting the name of the VM: vagrant_vpn_server_1773608626166_23299
==> server: Clearing any previously set network interfaces...
==> server: Preparing network interfaces based on configuration...
    server: Adapter 1: nat
    server: Adapter 2: hostonly
==> server: Forwarding ports...
    server: 22 (guest) => 2222 (host) (adapter 1)
    server: 22 (guest) => 2222 (host) (adapter 1)
==> server: Running 'pre-boot' VM customizations...
==> server: Booting VM...
==> server: Waiting for machine to boot. This may take a few minutes...
    server: SSH address: 127.0.0.1:2222
    server: SSH username: vagrant
    server: SSH auth method: private key
    server: Warning: Connection reset. Retrying...
    server:
    server: Vagrant insecure key detected. Vagrant will automatically replace
    server: this with a newly generated keypair for better security.
    server:
    server: Inserting generated public key within guest...
    server: Removing insecure key from the guest if it's present...
    server: Key inserted! Disconnecting and reconnecting using new SSH key...
==> server: Machine booted and ready!
==> server: Checking for guest additions in VM...
    server: The guest additions on this VM do not match the installed version of
    server: VirtualBox! In most cases this is fine, but in rare cases it can
    server: prevent things such as shared folders from working properly. If you see
    server: shared folder errors, please make sure the guest additions within the
    server: virtual machine match the version of VirtualBox you have installed on
    server: your host and reload your VM.
    server:
    server: Guest Additions Version: 6.0.0 r127566
    server: VirtualBox Version: 7.0
==> server: Setting hostname...
==> server: Configuring and enabling network interfaces...
==> server: Mounting shared folders...
    server: /mnt/c/Vagrant/vagrant_vpn => /vagrant
==> server: Running provisioner: ansible...
    server: Running ansible-playbook...
[WARNING]: Deprecation warnings can be disabled by setting `deprecation_warnings=False` in ansible.cfg.
[DEPRECATION WARNING]: The '--inventory-file' argument is deprecated. This feature will be removed from ansible-core version 2.23. Use -i or --inventory instead.

PLAY [Базовая подготовка всех ВМ] **********************************************

TASK [Gathering Facts] *********************************************************
[WARNING]: Host 'server' is using the discovered Python interpreter at '/usr/bin/python3.10', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_discovery.html for more information.
ok: [server]

TASK [Обновление кеша пакетов] *************************************************
changed: [server]

TASK [Установка необходимых пакетов] *******************************************
changed: [server]

PLAY [Настройка сервера (TAP)] *************************************************

TASK [Gathering Facts] *********************************************************
ok: [server]

TASK [Генерация статического ключа] ********************************************
changed: [server]

TASK [Чтение ключа для передачи] ***********************************************
ok: [server]

TASK [Сохранение ключа в факт] *************************************************
ok: [server]

TASK [Конфигурация TAP сервера] ************************************************
changed: [server]

TASK [Запуск TAP на сервере] ***************************************************
changed: [server]

TASK [Запуск iperf3 в фоне] ****************************************************
ok: [server]

PLAY [Настройка клиента (TAP)] *************************************************
skipping: no hosts matched

PLAY RECAP *********************************************************************
server                     : ok=10   changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

==> client: Importing base box 'ubuntu/22.04'...
==> client: Matching MAC address for NAT networking...
==> client: Checking if box 'ubuntu/22.04' version '1.0.0' is up to date...
==> client: Setting the name of the VM: vagrant_vpn_client_1773608724508_32533
==> client: Fixed port collision for 22 => 2222. Now on port 2200.
==> client: Clearing any previously set network interfaces...
==> client: Preparing network interfaces based on configuration...
    client: Adapter 1: nat
    client: Adapter 2: hostonly
==> client: Forwarding ports...
    client: 22 (guest) => 2200 (host) (adapter 1)
    client: 22 (guest) => 2200 (host) (adapter 1)
==> client: Running 'pre-boot' VM customizations...
==> client: Booting VM...
==> client: Waiting for machine to boot. This may take a few minutes...
    client: SSH address: 127.0.0.1:2200
    client: SSH username: vagrant
    client: SSH auth method: private key
    client: Warning: Connection reset. Retrying...
    client:
    client: Vagrant insecure key detected. Vagrant will automatically replace
    client: this with a newly generated keypair for better security.
    client:
    client: Inserting generated public key within guest...
    client: Removing insecure key from the guest if it's present...
    client: Key inserted! Disconnecting and reconnecting using new SSH key...
==> client: Machine booted and ready!
==> client: Checking for guest additions in VM...
    client: The guest additions on this VM do not match the installed version of
    client: VirtualBox! In most cases this is fine, but in rare cases it can
    client: prevent things such as shared folders from working properly. If you see
    client: shared folder errors, please make sure the guest additions within the
    client: virtual machine match the version of VirtualBox you have installed on
    client: your host and reload your VM.
    client:
    client: Guest Additions Version: 6.0.0 r127566
    client: VirtualBox Version: 7.0
==> client: Setting hostname...
==> client: Configuring and enabling network interfaces...
==> client: Mounting shared folders...
    client: /mnt/c/Vagrant/vagrant_vpn => /vagrant
==> client: Running provisioner: ansible...
    client: Running ansible-playbook...
[WARNING]: Deprecation warnings can be disabled by setting `deprecation_warnings=False` in ansible.cfg.
[DEPRECATION WARNING]: The '--inventory-file' argument is deprecated. This feature will be removed from ansible-core version 2.23. Use -i or --inventory instead.

PLAY [Базовая подготовка всех ВМ] **********************************************

TASK [Gathering Facts] *********************************************************
[WARNING]: Host 'server' is using the discovered Python interpreter at '/usr/bin/python3.10', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_discovery.html for more information.
ok: [server]
[WARNING]: Host 'client' is using the discovered Python interpreter at '/usr/bin/python3.10', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_discovery.html for more information.
ok: [client]

TASK [Обновление кеша пакетов] *************************************************
ok: [server]
changed: [client]

TASK [Установка необходимых пакетов] *******************************************
ok: [server]
changed: [client]

PLAY [Настройка сервера (TAP)] *************************************************

TASK [Gathering Facts] *********************************************************
ok: [server]

TASK [Генерация статического ключа] ********************************************
ok: [server]

TASK [Чтение ключа для передачи] ***********************************************
ok: [server]

TASK [Сохранение ключа в факт] *************************************************
ok: [server]

TASK [Конфигурация TAP сервера] ************************************************
ok: [server]

TASK [Запуск TAP на сервере] ***************************************************
changed: [server]

TASK [Запуск iperf3 в фоне] ****************************************************
ok: [server]

PLAY [Настройка клиента (TAP)] *************************************************

TASK [Gathering Facts] *********************************************************
ok: [client]

TASK [Установка OpenVPN] *******************************************************
ok: [client]

TASK [Копирование ключа с сервера] *********************************************
changed: [client]

TASK [Конфигурация TAP клиента] ************************************************
changed: [client]

TASK [Запуск TAP на клиенте] ***************************************************
changed: [client]

TASK [Пауза для инициализации соединений] **************************************
Pausing for 5 seconds
ok: [client]

TASK [Пинг сервера через TAP (10.10.10.1)] *************************************
changed: [client]

TASK [debug] *******************************************************************
ok: [client] => {
    "msg": [
        "TAP Status: OK"
    ]
}

TASK [Вывод логов TAP при ошибке] **********************************************
skipping: [client]

TASK [Замер скорости в TAP режиме] *********************************************
changed: [client]

TASK [Сохранить результаты TAP замера в общую папку] ***************************
changed: [client]

PLAY RECAP *********************************************************************
client                     : ok=13   changed=8    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
server                     : ok=10   changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```
> Вывод проверок TAP режима VPN
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_vpn$ cat ./iperf_tap.log
Connecting to host 10.10.10.1, port 5201
[  5] local 10.10.10.2 port 57766 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-5.00   sec  18.0 MBytes  30.2 Mbits/sec   36    222 KBytes
[  5]   5.00-10.00  sec  16.9 MBytes  28.4 Mbits/sec   47    142 KBytes
[  5]  10.00-15.00  sec  16.7 MBytes  28.1 Mbits/sec    9    166 KBytes
[  5]  15.00-20.00  sec  17.2 MBytes  28.8 Mbits/sec   49    138 KBytes
[  5]  20.00-25.00  sec  16.7 MBytes  28.1 Mbits/sec   19   96.8 KBytes
[  5]  25.00-30.00  sec  16.7 MBytes  28.0 Mbits/sec    0    181 KBytes
[  5]  30.00-35.00  sec  16.9 MBytes  28.3 Mbits/sec   23    141 KBytes
[  5]  35.00-40.00  sec  16.8 MBytes  28.2 Mbits/sec    9    170 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-40.00  sec   136 MBytes  28.5 Mbits/sec  192             sender
[  5]   0.00-40.09  sec   135 MBytes  28.3 Mbits/sec                  receiver

iperf Done.

```

### Установка и настройка TUN режима VPN
> В Vagrantfile меняем на TUN
```shell
....
   config.vm.provision "ansible" do |ansible|
#     ansible.playbook = "ansible/playbook_tap.yml" 
#    после TAP запускаем TUN
     ansible.playbook = "ansible/playbook_tun.yml" 
     ansible.groups = {
       "vpn_server" => ["server"],
       "vpn_client" => ["client"]
     }
	 ansible.limit = "all"
   end
end
```
> Запустил установку
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_vpn$ vagrant provision
==> server: Running provisioner: ansible...
    server: Running ansible-playbook...
[WARNING]: Deprecation warnings can be disabled by setting `deprecation_warnings=False` in ansible.cfg.
[DEPRECATION WARNING]: The '--inventory-file' argument is deprecated. This feature will be removed from ansible-core version 2.23. Use -i or --inventory instead.

PLAY [Базовая подготовка всех ВМ] **********************************************

TASK [Gathering Facts] *********************************************************
[WARNING]: Host 'client' is using the discovered Python interpreter at '/usr/bin/python3.10', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_discovery.html for more information.
ok: [client]
[WARNING]: Host 'server' is using the discovered Python interpreter at '/usr/bin/python3.10', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_discovery.html for more information.
ok: [server]

TASK [Обновление кеша пакетов] *************************************************
ok: [server]
ok: [client]

TASK [Установка необходимых пакетов] *******************************************
ok: [server]
ok: [client]

PLAY [Очистка старых конфигураций] *********************************************

TASK [Gathering Facts] *********************************************************
ok: [server]
ok: [client]

TASK [Остановка всех сервисов OpenVPN] *****************************************
ok: [client] => (item=openvpn@server-tun)
ok: [server] => (item=openvpn@server-tun)
ok: [client] => (item=openvpn@client-tun)
ok: [server] => (item=openvpn@client-tun)
ok: [client] => (item=openvpn@server-tap)
changed: [server] => (item=openvpn@server-tap)
changed: [client] => (item=openvpn@client-tap)
ok: [server] => (item=openvpn@client-tap)

TASK [Удаление старых файлов] **************************************************
ok: [client] => (item=server-tun.conf)
ok: [server] => (item=server-tun.conf)
ok: [client] => (item=client-tun.conf)
ok: [server] => (item=client-tun.conf)
changed: [client] => (item=static.key)
changed: [server] => (item=static.key)
changed: [server] => (item=server-tap.conf)
ok: [client] => (item=server-tap.conf)
ok: [server] => (item=client-tap.conf)
changed: [client] => (item=client-tap.conf)

PLAY [Настройка Сервера (TUN + Сертификаты)] ***********************************

TASK [Gathering Facts] *********************************************************
ok: [server]

TASK [Инициализация PKI и CA] **************************************************
changed: [server]

TASK [Генерация DH и сертификатов сервера] *************************************
changed: [server]

TASK [Генерация сертификата клиента] *******************************************
changed: [server]

TASK [Чтение сертификатов для передачи] ****************************************
ok: [server] => (item=pki/ca.crt)
ok: [server] => (item=pki/issued/client.crt)
ok: [server] => (item=pki/private/client.key)

TASK [Сохранение сертификатов в факты] *****************************************
....

TASK [Подготовка лог-файла] ****************************************************
changed: [server]

TASK [Создание конфигурации сервера] *******************************************
changed: [server]

TASK [Запуск сервера] **********************************************************
changed: [server]

TASK [Запуск iperf3 в фоне] ****************************************************
ok: [server]

PLAY [Настройка Клиента] *******************************************************

TASK [Gathering Facts] *********************************************************
ok: [client]

TASK [Создание папок для сертификатов] *****************************************
ok: [client]

TASK [Раскладка сертификатов] **************************************************
changed: [client] => (item={'src': 'pki/ca.crt', 'dest': 'pki/ca.crt', 'mode': '0644'})
changed: [client] => (item={'src': 'pki/issued/client.crt', 'dest': 'pki/client.crt', 'mode': '0644'})
changed: [client] => (item={'src': 'pki/private/client.key', 'dest': 'pki/client.key', 'mode': '0600'})

TASK [Создание конфигурации клиента] *******************************************
changed: [client]

TASK [Запуск клиенте] **********************************************************
changed: [client]

TASK [Пауза 10 сек.] ***********************************************************
Pausing for 10 seconds
ok: [client]

TASK [Проверка пинга] **********************************************************
changed: [client]

TASK [Замер iperf3 если пинг прошел] *******************************************
changed: [client]

TASK [Копирование отчета в общую папку] ****************************************
changed: [client]

TASK [Диагностика(вот тут я запарился!!! ): почему не работает?] ***************
skipping: [client]

TASK [debug] *******************************************************************
skipping: [client]

PLAY RECAP *********************************************************************
client                     : ok=15   changed=8    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
server                     : ok=16   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```
> Вывод проверок TUN режима VPN
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_vpn$ cat ./iperf_tun.log
Connecting to host 10.10.20.1, port 5201
[  5] local 10.10.20.2 port 45902 connected to 10.10.20.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  4.02 MBytes  33.7 Mbits/sec    0    210 KBytes
[  5]   1.00-2.00   sec  4.74 MBytes  39.8 Mbits/sec    0    414 KBytes
[  5]   2.00-3.00   sec  4.19 MBytes  35.1 Mbits/sec    0    608 KBytes
[  5]   3.00-4.00   sec  3.94 MBytes  33.0 Mbits/sec  137    338 KBytes
[  5]   4.00-5.00   sec  4.00 MBytes  33.6 Mbits/sec    2    261 KBytes
[  5]   5.00-6.00   sec  4.00 MBytes  33.6 Mbits/sec    0    278 KBytes
[  5]   6.00-7.00   sec  4.00 MBytes  33.6 Mbits/sec    0    286 KBytes
[  5]   7.00-8.00   sec  3.20 MBytes  26.8 Mbits/sec    0    289 KBytes
[  5]   8.00-9.00   sec  4.00 MBytes  33.6 Mbits/sec   10    214 KBytes
[  5]   9.00-10.00  sec  4.00 MBytes  33.6 Mbits/sec    0    250 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  40.1 MBytes  33.6 Mbits/sec  149             sender
[  5]   0.00-10.10  sec  38.6 MBytes  32.1 Mbits/sec                  receiver

iperf Done.

```
