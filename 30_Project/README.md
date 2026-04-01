# Проект: «Построение отказоустойчивой инфраструктуры управления DNS на базе PowerDNS и Postgres HA с автоматизацией через Ansible»
## Цель:
- Закрепить и продемонстрировать полученные знания и навыки;
- Создать веб-проект;
- Подготовить портфолио для работодателя;

### Описание:
- Создание автоматизированного отказоустойчивого стенда, включающего 
в себя распределенную базу данных, веб-интерфейс управления DNS и систему глубокого мониторинга. 
Инфраструктура разворачивается «одной кнопкой» через Vagrant и Ansible.

### Веб проект с развертыванием нескольких виртуальных машин должен отвечать следующим требованиям:
- **Включен HTTPS**
- **Основная инфраструктура в DMZ зоне**
- **Файрвалл на входе**
- **Сбор метрик и настроенный алертинг**
- **Организован централизованный сбор логов**
- **Организован Backup**

---

---

### Схема сети 

```mermaid
graph TD
    Client[Клиент / Admin] -->|DNS Запрос :53| VIP_LB
    Client -->|Web Admin :80| VIP_LB

    subgraph "Frontend Layer"
        LB1[HAProxy + Keepalived\n192.168.77.10\niptables]
        LB2[HAProxy + Keepalived\n192.168.77.11]
        VIP_LB[Virtual IP (VIP)\n192.168.77.100]
    end

    subgraph "DNS Layer"
        DNS_Split[Bind9 (Split-DNS)\n192.168.77.20]
        PDNS[PowerDNS Authoritative\n192.168.77.30\nPort 5300]
        PDNS_Admin[PowerDNS-Admin\nDocker/Flask]
    end

    subgraph "Database Cluster (HA)"
        PG1[Patroni + Postgres + etcd\n192.168.77.31]
        PG2[Patroni + Postgres + etcd\n192.168.77.32]
        PG3[Patroni + Postgres + etcd\n192.168.77.33]
    end

    subgraph "Monitoring & Backup"
        Zabbix[Zabbix Server\n192.168.77.40]
        Backup[Barman + Config Backup\n192.168.77.50]
    end

    %% Логика связей
    VIP_LB --> LB1
    VIP_LB --> LB2
    
    DNS_Split -->|Forward internal zones| PDNS
    
    LB1 -->|TCP 5000 (Write)| PG1
    LB1 -->|TCP 5001 (Read)| PG2
    LB1 -->|API Check :8008| PG1 & PG2 & PG3
    
    PDNS -->|Connect to DB| VIP_LB
    
    Zabbix -->|Monitor Agents| LB1 & DNS_Split & PDNS & PG1 & Backup
    Backup -->|SSH/WAL| PG1
    
```