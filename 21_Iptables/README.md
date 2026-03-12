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
