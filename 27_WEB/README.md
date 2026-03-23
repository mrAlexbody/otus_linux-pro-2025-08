# Домашнее задание 27
## @Развертывание веб приложения

## Цель:
- Получить практические навыки в настройке инфраструктуры с помощью манифестов и конфигураций;
- Отточить навыки использования ansible/vagrant/docker;


## Описание/Пошаговая инструкция выполнения домашнего задания:
**Для выполнения домашнего задания используйте [методичку]()**

**Что нужно сделать?**

### Варианты стенда:
- nginx + php-fpm (laravel/wordpress) + python (flask/django) + js(react/angular);
- nginx + java (tomcat/jetty/netty) + go + ruby;
- можно свои комбинации.

### Реализации на выбор:
- на хостовой системе через конфиги в /etc;
- деплой через docker-compose

---
### Пошаговое выполнение задачи
**Вводные данные:**
- Все дальнейшие действия были проверены при использовании Vagrant 2.4.9
- VirtualBox: 7.2.6 
- В качестве ОС на хостах установлена Almalinux9
- Vagrant + Ansible запускается из WSL2 в Windows 11

### Схема 
```mermaid
graph TD
    subgraph Host_Machine ["Хостовая машина (Windows/Mac/Linux)"]
        Browser["🌐 Браузер (localhost:8081-8083)"]
    end

    subgraph Vagrant_VM ["Vagrant VM (Ubuntu 22.04) - 192.168.77.2"]
        direction TB
        VB_Ports["📥 VirtualBox Port Forwarding (8081-8083)"]
        
        subgraph Docker_Engine ["Docker Engine"]
            direction TB
            
            NGINX["Proxy: Nginx Container (Port 8081, 8082, 8083)"]
            
            subgraph App_Network ["Docker Network (app-network)"]
                direction LR
                DJANGO["App: Django (Python 3.10) - Port 8000"]
                NODE["App: Node.js (Port 3000)"]
                WP["App: WordPress (PHP-FPM) - Port 9000"]
                DB[("DB: MySQL 8.0")]
            end
        end
    end

    %% Трафик
    Browser -->|Port Forward| VB_Ports
    VB_Ports --> NGINX

    %% Распределение Nginx
    NGINX -->|Proxy Pass :8081| DJANGO
    NGINX -->|Proxy Pass :8082| NODE
    NGINX -->|FastCGI :8083| WP

    %% Связи с БД
    DJANGO -.->|SQLite/MySQL| DB
    WP -.->|TCP 3306| DB

    %% Volumes
    DJANGO --- V1[(Local Wheels & Src)]
    WP --- V2[(Shared HTML Vol)]
    NGINX --- V3[(nginx.conf Vol)]

```
