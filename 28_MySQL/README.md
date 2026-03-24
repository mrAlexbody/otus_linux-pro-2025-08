# Домашнее задание 28
## @Репликация MySQL

### Цель:
- Поработать с реаликацией MySQL.


### Описание/Пошаговая инструкция выполнения домашнего задания:
 _Для выполнения домашнего задания используйте [методичку](https://drive.google.com/file/d/139irfqsbAxNMjVcStUN49kN7MXAJr_z9/view)_

**Что нужно сделать?**

- В материалах приложены ссылки на вагрант для репликации и дамп базы bet.dmp
- Базу развернуть на мастере и настроить так, чтобы реплицировались таблицы:

```mermaid
graph TD
    subgraph SourceData [Справочники]
        Bookmaker[bookmaker<br/>id PK, name]
        Competition[competition<br/>id PK, bookmaker_id FK, name]
    end

    subgraph MarketStructure [Рыночная структура]
        Market[market<br/>id PK, competition_id FK, name]
        Odds[odds<br/>id PK, market_id FK, value, timestamp]
    end

    subgraph Results [Результаты]
        Outcome[outcome<br/>id PK, odds_id FK, result]
    end

    Bookmaker -->|один ко многим| Competition
    Competition -->|один ко многим| Market
    Market -->|один ко многим| Odds
    Odds -->|один ко многим| Outcome

    style Bookmaker fill:#f5f5f5,stroke:#333,stroke-width:1px,color:#000
    style Competition fill:#f5f5f5,stroke:#333,stroke-width:1px,color:#000
    style Market fill:#f5f5f5,stroke:#333,stroke-width:1px,color:#000
    style Odds fill:#f5f5f5,stroke:#333,stroke-width:1px,color:#000
    style Outcome fill:#f5f5f5,stroke:#333,stroke-width:1px,color:#000
    style SourceData fill:none,stroke:#666,stroke-dasharray:5 5
    style MarketStructure fill:none,stroke:#666,stroke-dasharray:5 5
    style Results fill:none,stroke:#666,stroke-dasharray:5 5

```
- Настроить GTID репликацию

### Варианты которые принимаются к сдаче:
- рабочий вагрантафайл
- скрины или логи SHOW TABLES
- конфиги*
- пример в логе изменения строки и появления строки на реплике*
 
---

### Схема взаимодействия
```mermaid
graph TD
    User((Пользователь)) -->|SSH-подключение| Master
    User -->|SSH-подключение| Slave

    subgraph Database_Servers [Серверы баз данных]
        Master[Master DB<br/>192.168.77.150]
        Slave[Slave DB<br/>192.168.77.151]
    end

    Master -->|Репликация (binlog)| Slave

    style User fill:#f0f0f0,stroke:#333,stroke-width:1px,color:#000
    style Master fill:#e0e0e0,stroke:#333,stroke-width:1px,color:#000
    style Slave fill:#e0e0e0,stroke:#333,stroke-width:1px,color:#000
    style Database_Servers fill:none,stroke:#666,stroke-dasharray: 5 5
    
```
