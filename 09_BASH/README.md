# Домашнее задание 09
## Пишем скрипт

### Цель: 
Написать bash-скрипт, который ежечасно формирует и отправляет на email отчёт о работе веб-сервера;

### Описание/Пошаговая инструкция выполнения домашнего задания:
**🎯Что нужно сделать?**

Написать скрипт для CRON, который раз в час формирует отчёт и отправляет его на заданную почту.

#### Отчёт должен содержать:

+ IP-адреса с наибольшим числом запросов (с момента последнего запуска);
+ Запрашиваемые URL с наибольшим числом запросов (с момента последнего запуска);
+ Ошибки веб-сервера/приложения (с момента последнего запуска);
+ HTTP-коды ответов с указанием их количества (с момента последнего запуска).

Скрипт должен предотвращать одновременный запуск нескольких копий, до его завершения.

В письме должен быть прописан обрабатываемый временной диапазон.

---
### Подготовка сервера:
````shell
root@otus-bash:~# apt install -y msmtp msmtp-mta mailutils nginx
````

### Подготовка скрипта:
```shell
root@otus-bash:/usr/local/bin# cat ./web_report.sh
#!/bin/bash

readonly LOG_DIR="/var/log/nginx"
readonly LOG_PATTERN="access*.log"
readonly EMAIL="admin@gmail.com"
readonly LOCKFILE="/tmp/web_report.lock"
readonly STATE_FILE="/var/tmp/web_report.state"
readonly REPORT_FILE="/tmp/web_report_$(date +%Y%m%d_%H%M%S).txt"
readonly TIMESTAMP_FORMAT="%d/%b/%Y:%H:%M:%S"

cleanup() {
    local exit_code=$?
    echo "Очистка ресурсов..."
    rm -f "$LOCKFILE" 2>/dev/null
    # Удаляем временные отчеты старше 2 часов
    find /tmp -name "web_report_*.txt" -mmin +120 -delete 2>/dev/null
    exit $exit_code
}

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&2
}

check_dependencies() {
    local deps=("mail" "flock" "awk" "sed" "find")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            log_message "Ошибка: $dep не установлен"
            return 1
        fi
    done

    if [ ! -d "$LOG_DIR" ]; then
        log_message "Ошибка: директория логов не существует: $LOG_DIR"
        return 1
    fi
}

find_log_files() {
    find "$LOG_DIR" -name "$LOG_PATTERN" -type f -mmin -120 2>/dev/null | sort
}

extract_log_data() {
    local log_files=$1
    local start_time=$2
    local end_time=$3

    awk -v start="$start_time" -v end="$end_time" '
    function parse_time(str) {
        # Преобразование времени
        gsub(/\[/, "", str)
        return str
    }
    {
        # Извлекаем время из лога (4-е поле в nginx)
        log_time = parse_time($4)
        if (log_time >= start && log_time <= end) {
            print $0
        }
    }' $log_files
}

generate_report() {
    local data=$1
    local start_time=$2
    local end_time=$3

    cat <<EOF > "$REPORT_FILE"
Отчет о работе веб-сервера
Временной диапазон: $start_time - $end_time
Сгенерирован: $(date '+%Y-%m-%d %H:%M:%S')
==================================================

1. ТОП-10 IP-адресов по количеству запросов:
$(echo "$data" | awk '{print $1}' | sort | uniq -c | sort -rn | head -10 | awk '{printf "%s\t%s\n", $1, $2}')

2. ТОП-10 запрашиваемых URL:
$(echo "$data" | awk '{print $7}' | sort | uniq -c | sort -rn | head -10 | awk '{printf "%s\t%s\n", $1, $2}')

3. Ошибки веб-сервера (4xx и 5xx):
$(echo "$data" | awk '$9 ~ /^[45][0-9][0-9]$/ {print $1, $4, $7, $9}' | head -20)

4. Распределение HTTP-кодов ответов:
$(echo "$data" | awk '{code=$9; if (code ~ /^[0-9][0-9][0-9]$/) codes[code]++} END {for (c in codes) printf "%s: %d\n", c, codes[c]}' | sort -rn)

5. Статистика по методам запросов:
$(echo "$data" | awk '{print $6}' | sed 's/"//g' | sort | uniq -c | sort -rn)

==================================================
Общее количество запросов: $(echo "$data" | wc -l)
EOF
}

trap cleanup EXIT INT TERM

if ! check_dependencies; then
    exit 1
fi

exec 9>"$LOCKFILE"
if ! flock -n 9; then
    log_message "Скрипт уже выполняется. Выход."
    exit 1
fi

START_TIME=$(date -d "1 hour ago" "+$TIMESTAMP_FORMAT")
END_TIME=$(date "+$TIMESTAMP_FORMAT")

log_message "Начало формирования отчета за период: $START_TIME - $END_TIME"

LOG_FILES=$(find_log_files)
if [ -z "$LOG_FILES" ]; then
    log_message "Не найдены лог-файлы для обработки"
    exit 0
fi

log_message "Найдены лог-файлы: $(echo $LOG_FILES | tr '\n' ' ')"

LOG_DATA=$(extract_log_data "$LOG_FILES" "$START_TIME" "$END_TIME")

if [ -z "$LOG_DATA" ]; then
    log_message "Нет данных за указанный период"
    exit 0
fi

log_message "Обработано строк: $(echo "$LOG_DATA" | wc -l)"

generate_report "$LOG_DATA" "$START_TIME" "$END_TIME"

if [ -s "$REPORT_FILE" ]; then
    mail -s "Отчет веб-сервера $(date '+%Y-%m-%d %H:%M')" \
         -a "From: webserver-report@$(hostname)" \
         "$EMAIL" < "$REPORT_FILE"

    if [ $? -eq 0 ]; then
        log_message "Отчет успешно отправлен на $EMAIL"
    else
        log_message "Ошибка при отправке отчета"
        exit 1
    fi
fi

log_message "Скрипт успешно завершен"
```
### Настройка прав для запуска скрипта:
```shell
root@otus-bash:~#  chmod +x /usrlocal/bin/web_repor.sh
root@otus-bash:~# ls -la /usr/local/bin/web_report.sh
-rwxr-xr-x 1 root root 5484 Jan 14 18:57 /usr/local/bin/web_report.sh
```
### Добавление в crontab:
```shell
root@otus-bash:~#  crontab -e


# Edit this file to introduce tasks to be run by cron.
#
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
#
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
#
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
#
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
#
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
0 * * * * /usr/local/bin/web_report.sh  >> /var/log/web_report.log 2>&1
```
