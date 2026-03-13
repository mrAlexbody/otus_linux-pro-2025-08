# Проект: «Построение отказоустойчивой инфраструктуры управления DNS на базе PowerDNS и Postgres HA (Patroni) с автоматизацией через Ansible»
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
    User((🌐 Internet)) -->|DNS:53, HTTPS:443| Router{🛡️ Router/FW}
    
    subgraph DMZ_Zone [Segment: 10.0.1.0/24]
        Router --> NS[🌍 PowerDNS + Admin UI]
    end

    subgraph Internal_Zone [Segment: 10.0.2.0/24]
        NS -->|SQL Queries| VIP[🔹 Virtual IP / Patroni]
        VIP --> DB1[(🗄️ PG Master)]
        VIP -.-> DB2[(🗄️ PG Replica)]
        
        DB1 <--> ETCD{🐝 ETCD Cluster}
        DB2 <--> ETCD
    end

    subgraph Management_Zone [Segment: 192.168.56.0/24]
        MGMT[📊 MGMT Server]
        MGMT -.->|Metrics| NS & DB1 & DB2 & Router
        MGMT -.->|Auth| LDAP[(🆔 OpenLDAP)]
        DB2 -->|Backup Dump| MGMT
    end

    style Router fill:#f96,stroke:#333
    style DMZ_Zone fill:#fff5e6,stroke:#f96,stroke-dasharray: 5 5
    style Internal_Zone fill:#e6f3ff,stroke:#007bff,stroke-dasharray: 5 5
    style MGMT fill:#f0fff0,stroke:#28a745

```
