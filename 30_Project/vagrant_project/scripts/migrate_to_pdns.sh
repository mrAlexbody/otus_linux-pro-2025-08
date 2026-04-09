#!/bin/bash
DB_HOST="192.168.77.100"
DB_PORT="5000"
DB_NAME="powerdns"
DB_USER="powerdns"
DB_PASSWORD="$DB_PASSWORD"

ZONES_DIR="/etc/bind/zones"
for zonefile in "$ZONES_DIR"/*.zone; do
    zone=$(basename "$zonefile" .zone)
    named-checkzone "$zone" "$zonefile" || continue
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "DELETE FROM records WHERE domain_id = (SELECT id FROM domains WHERE name = '$zone');"
    pdnsutil load-zone "$zone" "$zonefile"
    pdnsutil increase-serial "$zone"
done