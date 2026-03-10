#!/bin/bash

echo "=== Проверка сети: $(hostname) ==="

# Берем первый попавшийся шлюз
GW=$(ip route show default | grep -v "10.0.2.2" | awk '{print $3}' | head -n 1)
[ -z "$GW" ] && GW=$(ip route show default | awk '{print $3}' | head -n 1)

if [ -n "$GW" ] && ping -c 1 -W 1 "$GW" > /dev/null; then
    echo "[OK] Шлюз $GW отвечает"
else
    echo "[FAIL] Шлюз не отвечает"
fi

# Пинг центрального роутера
ping -c 1 -W 1 192.168.255.2 > /dev/null \
    && echo "[OK] CentralRouter доступен" \
    || echo "[FAIL] CentralRouter недоступен"

# Пинг соседа (Office 2)
ping -c 1 -W 1 192.168.1.2 > /dev/null \
    && echo "[OK] Office 2 Server доступен" \
    || echo "[FAIL] Office 2 Server недоступен"

# Пинг интернета
ping -c 1 -W 1 8.8.8.8 > /dev/null \
    && echo "[OK] Интернет (8.8.8.8) есть" \
    || echo "[FAIL] Интернета нет"

echo "------------The END!!!------------------------"
ip route | grep default
