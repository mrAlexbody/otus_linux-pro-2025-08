# Домашнее задание 21
## Сценарии iptables

### Цель:
- Написать сценарии iptables.


### Описание/Пошаговая инструкция выполнения домашнего задания:
#### Что нужно сделать?

- реализовать knocking port
- centralRouter может попасть на ssh inetrRouter через knock скрипт
- пример в материалах.
- добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост.
- запустить nginx на centralServer.
- пробросить 80й порт на inetRouter2 8080.
- дефолт в инет оставить через inetRouter.

Формат сдачи ДЗ - vagrant + ansible

Реализовать проход на 80й порт без маскарадинга*

---
### Пошаговое выполнение задачи
**Вводные данные:**
- Все дальнейшие действия были проверены при использовании Vagrant 2.4.9
- VirtualBox: 7.0.20 r163906 
- В качестве ОС на хостах установлена Ubuntu 22.04
- Vagrant + Ansible запускается из WSL2 в Windows 11

### Схема сети
````mermaid
graph TD
    Host["💻 Host (Win/Mac/Linux)"] -- "port 8080" --> IR2
    
    subgraph "External/Edge Layer"
        IR1["🌐 inetRouter<br/>192.168.255.1"]
        IR2["🌐 inetRouter2<br/>192.168.255.13"]
    end

    IR1 --- |"router-net"| CR
    IR2 --- |"router2-net"| CR

    subgraph "Core Layer"
        CR["Маршрутизатор centralRouter<br/>.2 | .14 | .1 | .9 | .5"]
    end

    CR --- |"dir-net"| CS["🖥️ centralServer (Nginx)<br/>192.168.0.2"]
    
    subgraph "Office 1"
        CR --- |"office1-central"| O1R["office1Router<br/>192.168.255.10"]
        O1R --- |"managers-net"| O1S["office1Server<br/>192.168.2.130"]
    end

    subgraph "Office 2"
        CR --- |"office2-central"| O2R["office2Router<br/>192.168.255.6"]
        O2R --- |"dev2-net"| O2S["office2Server<br/>192.168.1.2"]
    end
````
### Таблица IP-интерфейсов

| Хост            | Интерфейс       | IP-адрес        | Маска подсети          | Сеть (подсеть)          | Назначение / подключение      |
|-----------------|-----------------|-----------------|------------------------|-------------------------|-------------------------------|
| **inetRouter**  | `enp0s8`        | 192.168.255.1   | 255.255.255.252 (/30)  | router-net              | Связь с centralRouter (.2)    |
| **inetRouter2** | `enp0s8`        | 192.168.255.13  | 255.255.255.252 (/30)  | router2-net             | Связь с centralRouter (.14)   |
|                 | forwarded_port  | –               | –                      | –                       | Проброс порта 8080 → 80       |
| **centralRouter** | `enp0s8`      | 192.168.255.2   | 255.255.255.252 (/30)  | router-net              | Связь с inetRouter (.1)       |
|                 | `enp0s9`        | 192.168.255.14  | 255.255.255.252 (/30)  | router2-net             | Связь с inetRouter2 (.13)     |
|                 | `enp0s10`       | 192.168.0.1     | 255.255.255.240 (/28)  | dir-net                 | Связь с centralServer (.2)    |
|                 | `enp0s16`       | 192.168.255.9   | 255.255.255.252 (/30)  | office1-central         | Связь с office1Router (.10)   |
|                 | `enp0s17`       | 192.168.255.5   | 255.255.255.252 (/30)  | office2-central         | Связь с office2Router (.6)    |
| **centralServer** | `enp0s8`      | 192.168.0.2     | 255.255.255.240 (/28)  | dir-net                 | Связь с centralRouter (.1)    |
| **office1Router** | `enp0s8`      | 192.168.255.10  | 255.255.255.252 (/30)  | office1-central         | Связь с centralRouter (.9)    |
|                 | `enp0s9`        | 192.168.2.129   | 255.255.255.192 (/26)  | managers-net           | Связь с office1Server (.130)  |
| **office1Server** | `enp0s8`      | 192.168.2.130   | 255.255.255.192 (/26)  | managers-net           | Связь с office1Router (.129)  |
| **office2Router** | `enp0s8`      | 192.168.255.6   | 255.255.255.252 (/30)  | office2-central         | Связь с centralRouter (.5)    |
|                 | `enp0s9`        | 192.168.1.1     | 255.255.255.128 (/25)  | dev2-net               | Связь с office2Server (.2)    |
| **office2Server** | `enp0s8`      | 192.168.1.2     | 255.255.255.128 (/25)  | dev2-net               | Связь с office2Router (.1)    |

### Конфигурационные файлы
- [Vagrantfile](vagrant_iptales/Vagrantfile)
- [Ansible playbook](vagrant_iptales/ansible/playbook.yml)

### Проверка
>  Проверка Port Knocking
>> Убедиться, что SSH на inetRouter закрыт и открывается только после «стука».
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_iptables$ vagrant ssh centralRouter
Welcome to Ubuntu 22.04.2 LTS (GNU/Linux 5.15.0-71-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Thu Mar 12 17:36:46 UTC 2026

  System load:     0.0546875         IPv4 address for enp0s10: 192.168.0.1
  Usage of /:      4.8% of 38.70GB   IPv4 address for enp0s16: 192.168.255.9
  Memory usage:    24%               IPv4 address for enp0s17: 192.168.255.5
  Swap usage:      0%                IPv4 address for enp0s3:  10.0.2.15
  Processes:       95                IPv4 address for enp0s8:  192.168.255.2
  Users logged in: 0                 IPv4 address for enp0s9:  192.168.255.14

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

282 updates can be applied immediately.
193 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

1 additional security update can be applied with ESM Apps.
Learn more about enabling ESM Apps service at https://ubuntu.com/esm

New release '24.04.4 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Thu Mar 12 17:34:28 2026 from 10.0.2.2

vagrant@centralRouter:~$ ssh 192.168.255.1
^C - не смог зайти !!!


vagrant@centralRouter:~$ /usr/local/bin/knock_inet.sh 192.168.255.1
Welcome to Ubuntu 22.04.2 LTS (GNU/Linux 5.15.0-71-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Thu Mar 12 17:40:43 UTC 2026

  System load:  0.0               Processes:               96
  Usage of /:   5.8% of 38.70GB   Users logged in:         0
  Memory usage: 26%               IPv4 address for enp0s3: 10.0.2.15
  Swap usage:   0%                IPv4 address for enp0s8: 192.168.255.1

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

106 updates can be applied immediately.
1 of these updates is a standard security update.
To see these additional updates run: apt list --upgradable

1 additional security update can be applied with ESM Apps.
Learn more about enabling ESM Apps service at https://ubuntu.com/esm

New release '24.04.4 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


*** System restart required ***
Last login: Thu Mar 12 17:33:43 2026 from 10.0.2.2
``` 
> Проверим правила iptables
```shell
 vagrant@inetRouter:~$ sudo iptables -L INPUT -n | grep 192.168.255.2
ACCEPT     tcp  --  192.168.255.2        0.0.0.0/0            tcp dpt:22
    
```
> Проверка доступности nginx через проброшенный порт
```shell
vagrant@centralRouter:~$ curl http://192.168.255.13:8080
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

```
> Проверка маршрутов
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_iptables$ vagrant ssh centralRouter -- ip route show default
default via 192.168.255.1 dev enp0s8
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100

amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_iptables$ vagrant ssh centralServer -- ip route show default
default via 192.168.0.1 dev enp0s8
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100

amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_iptables$ vagrant ssh inetRouter -- ip route show default
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100


```
>  Проверка доступности интернета через inetRouter
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_iptables$ vagrant ssh inetRouter -- ping -c 3 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=107 time=19.8 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=107 time=19.5 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=107 time=19.5 ms

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 19.478/19.603/19.796/0.138 ms

```
>> Что покажет tcpdump
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_iptables$ vagrant ssh office2Router -- ping -c 10 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=52 time=43.4 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=52 time=43.3 ms
64 bytes from 1.1.1.1: icmp_seq=3 ttl=52 time=42.9 ms
64 bytes from 1.1.1.1: icmp_seq=4 ttl=52 time=42.8 ms
64 bytes from 1.1.1.1: icmp_seq=5 ttl=52 time=43.3 ms
64 bytes from 1.1.1.1: icmp_seq=6 ttl=52 time=43.2 ms
64 bytes from 1.1.1.1: icmp_seq=7 ttl=52 time=43.2 ms
64 bytes from 1.1.1.1: icmp_seq=8 ttl=52 time=43.1 ms
64 bytes from 1.1.1.1: icmp_seq=9 ttl=52 time=43.1 ms
64 bytes from 1.1.1.1: icmp_seq=10 ttl=52 time=43.3 ms

--- 1.1.1.1 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9017ms
rtt min/avg/max/mdev = 42.785/43.157/43.440/0.199 ms


```
>> и...
```shell
amyskin@otus-vagrant:/mnt/c/Vagrant/vagrant_iptables$ vagrant ssh inetRouter -- sudo tcpdump
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s3, link-type EN10MB (Ethernet), snapshot length 262144 bytes
19:46:16.247661 IP inetRouter.ssh > _gateway.47906: Flags [P.], seq 2974261694:2974261802, ack 2120460293, win 62780, length 108
19:46:16.247905 IP _gateway.47906 > inetRouter.ssh: Flags [.], ack 108, win 65535, length 0
19:46:16.248261 IP inetRouter.ssh > _gateway.47906: Flags [P.], seq 108:160, ack 1, win 62780, length 52
19:46:16.248631 IP _gateway.47906 > inetRouter.ssh: Flags [.], ack 160, win 65535, length 0
19:46:16.248740 IP inetRouter.ssh > _gateway.47906: Flags [P.], seq 160:220, ack 1, win 62780, length 60
19:46:16.248962 IP _gateway.47906 > inetRouter.ssh: Flags [.], ack 220, win 65535, length 0
19:46:16.249318 IP inetRouter.ssh > _gateway.47906: Flags [P.], seq 220:288, ack 1, win 62780, length 68
19:46:16.249564 IP _gateway.47906 > inetRouter.ssh: Flags [.], ack 288, win 65535, length 0
19:46:17.248586 IP inetRouter.56100 > 10.0.2.3.domain: 44390+ [1au] PTR? 2.2.0.10.in-addr.arpa. (50)
19:46:17.300093 IP 10.0.2.3.domain > inetRouter.56100: 44390 NXDomain* 0/1/1 (109)
19:46:17.300234 IP inetRouter.56100 > 10.0.2.3.domain: 44390+ PTR? 2.2.0.10.in-addr.arpa. (39)
19:46:17.350797 IP 10.0.2.3.domain > inetRouter.56100: 44390 NXDomain* 0/1/0 (98)
19:46:17.351212 IP inetRouter.52152 > 10.0.2.3.domain: 59269+ [1au] PTR? 15.2.0.10.in-addr.arpa. (51)
19:46:17.401952 IP 10.0.2.3.domain > inetRouter.52152: 59269 NXDomain* 0/1/1 (110)
19:46:17.402101 IP inetRouter.52152 > 10.0.2.3.domain: 59269+ PTR? 15.2.0.10.in-addr.arpa. (40)
19:46:17.452473 IP 10.0.2.3.domain > inetRouter.52152: 59269 NXDomain* 0/1/0 (99)
19:46:18.272214 IP inetRouter.50338 > 10.0.2.3.domain: 38788+ [1au] PTR? 3.2.0.10.in-addr.arpa. (50)
19:46:18.323665 IP 10.0.2.3.domain > inetRouter.50338: 38788 NXDomain* 0/1/1 (109)
19:46:18.323850 IP inetRouter.50338 > 10.0.2.3.domain: 38788+ PTR? 3.2.0.10.in-addr.arpa. (39)
19:46:18.374717 IP 10.0.2.3.domain > inetRouter.50338: 38788 NXDomain* 0/1/0 (98)
19:46:22.399352 ARP, Request who-has 10.0.2.3 tell inetRouter, length 28
19:46:22.399650 ARP, Reply 10.0.2.3 is-at 52:54:00:12:35:03 (oui Unknown), length 46
19:47:36.247583 IP inetRouter.60295 > prod-ntp-5.ntp1.ps5.canonical.com.ntp: NTPv4, Client, length 48
19:47:36.299456 IP prod-ntp-5.ntp1.ps5.canonical.com.ntp > inetRouter.60295: NTPv4, Server, length 48
19:47:37.119711 IP inetRouter.50457 > 10.0.2.3.domain: 56094+ [1au] PTR? 58.190.125.185.in-addr.arpa. (56)
19:47:37.232679 IP 10.0.2.3.domain > inetRouter.50457: 56094 2/0/1 PTR prod-ntp-5.ntp1.ps5.canonical.com., PTR prod-ntp-5.ntp4.ps5.canonical.com. (133)
19:47:41.503320 ARP, Request who-has _gateway tell inetRouter, length 28
19:47:41.503929 ARP, Reply _gateway is-at 52:54:00:12:35:02 (oui Unknown), length 46
19:47:42.271134 ARP, Request who-has 10.0.2.3 tell inetRouter, length 28
19:47:42.271426 ARP, Reply 10.0.2.3 is-at 52:54:00:12:35:03 (oui Unknown), length 46
19:47:58.401888 IP inetRouter > one.one.one.one: ICMP echo request, id 1, seq 1, length 64
19:47:58.443870 IP one.one.one.one > inetRouter: ICMP echo reply, id 1, seq 1, length 64
19:47:58.623713 IP inetRouter.58522 > 10.0.2.3.domain: 10471+ [1au] PTR? 1.1.1.1.in-addr.arpa. (49)
19:47:58.675117 IP 10.0.2.3.domain > inetRouter.58522: 10471 1/0/1 PTR one.one.one.one. (78)
19:47:59.403216 IP inetRouter > one.one.one.one: ICMP echo request, id 1, seq 2, length 64
19:47:59.445001 IP one.one.one.one > inetRouter: ICMP echo reply, id 1, seq 2, length 64
19:48:00.404227 IP inetRouter > one.one.one.one: ICMP echo request, id 1, seq 3, length 64
19:48:00.445856 IP one.one.one.one > inetRouter: ICMP echo reply, id 1, seq 3, length 64
19:48:01.406895 IP inetRouter > one.one.one.one: ICMP echo request, id 1, seq 4, length 64
19:48:01.448253 IP one.one.one.one > inetRouter: ICMP echo reply, id 1, seq 4, length 64
19:48:02.409354 IP inetRouter > one.one.one.one: ICMP echo request, id 1, seq 5, length 64
19:48:02.451344 IP one.one.one.one > inetRouter: ICMP echo reply, id 1, seq 5, length 64
19:48:03.411450 IP inetRouter > one.one.one.one: ICMP echo request, id 1, seq 6, length 64

```
