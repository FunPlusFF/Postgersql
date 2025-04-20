#!/bin/bash

# Параметры PostgreSQL
DB_NAME="sys_monitoring_db"
DB_USER="monitoring_user"
DB_PASSWORD="qwerty"

# Путь к JSON-файлу
JSON_FILE="/var/www/html/monitoring.json"

# Получаем последние метрики из БД
export PGPASSWORD="$DB_PASSWORD"
METRICS_JSON=$(psql -h localhost -U "$DB_USER" -d "$DB_NAME" -t -c "
SELECT json_build_object(
    'timestamp', timestamp,
    'cpu_usage', cpu_usage,
    'ram_usage', ram_usage,
    'swap_usage', swap_usage,
    'ip_address', addres_server
) 
FROM servers_monitoring 
ORDER BY timestamp DESC 
LIMIT 1;" | jq -s '.[0]')

# Записываем в JSON-файл
echo "$METRICS_JSON" > "$JSON_FILE"
unset PGPASSWORD

# Права для Nginx
chown www-data:www-data "$JSON_FILE"
chmod 644 "$JSON_FILE"
