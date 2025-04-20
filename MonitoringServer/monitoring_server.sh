#!/bin/bash

#parametrs postgresql
DB_NAME="sys_monitoring_db"
DB_USER="monitoring_user"
DB_PASSWORD="qwerty"  

# writing all needed data
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
RAM_USAGE=$(free -m | awk '/Mem:/ {print $3}')
SWAP_USAGE=$(free -m | awk '/Swap:/ {print $3}')
IP_ADDRESS=$(hostname -I | awk '{print $1}') 
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

#Check on null value
[ -z "$CPU_USAGE" ] && CPU_USAGE=0
[ -z "$RAM_USAGE" ] && RAM_USAGE=0
[ -z "$SWAP_USAGE" ] && SWAP_USAGE=0
[ -z "$IP_ADDRESS" ] && IP_ADDRESS="0.0.0.0"

#echo "IP: $IP_ADDRESS, TIMESTAMP: $TIMESTAMP, CPU: $CPU_USAGE, RAM: $RAM_USAGE, SWAP: $SWAP_USAGE"
# Writing in PostgreSQL
export PGPASSWORD="$DB_PASSWORD"
psql -h localhost -U "$DB_USER" -d "$DB_NAME" -c "
INSERT INTO servers_monitoring (addres_server, timestamp, cpu_usage, ram_usage, swap_usage)
VALUES ('$IP_ADDRESS', '$TIMESTAMP', $CPU_USAGE, $RAM_USAGE, $SWAP_USAGE );
"


unset PGPASSWORD
