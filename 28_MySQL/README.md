# Домашнее задание 28
## @Репликация MySQL

### Цель:
- Поработать с реаликацией MySQL.


### Описание/Пошаговая инструкция выполнения домашнего задания:
 _Для выполнения домашнего задания используйте [методичку](https://drive.google.com/file/d/139irfqsbAxNMjVcStUN49kN7MXAJr_z9/view)_

**Что нужно сделать?**

- В материалах приложены ссылки на вагрант для репликации и дамп базы bet.dmp
- Базу развернуть на мастере и настроить так, чтобы реплицировались таблицы:
  - bookmaker          
  - competition        
  - market              
  - odds               
  - outcome
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

    subgraph Database_Servers [Сервера MySQL]
        Master[Master DB<br/>192.168.77.150]
        Slave[Slave DB<br/>192.168.77.151]
    end

    Master -->|Репликация (binlog)| Slave

    style User fill:#f0f0f0,stroke:#333,stroke-width:1px,color:#000
    style Master fill:#e0e0e0,stroke:#333,stroke-width:1px,color:#000
    style Slave fill:#e0e0e0,stroke:#333,stroke-width:1px,color:#000
    
```
