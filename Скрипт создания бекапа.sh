#!/bin/bash

# Параметры
DB_NAME="test"
BACKUP_DIR="/BACKUP"
GPG_PASSPHRASE="qwerty"  # Пароль для расшифровки GPG-файла

# Расшифровка пароля для PostgreSQL
PASSWORD=$(echo "$GPG_PASSPHRASE" | gpg --pinentry-mode loopback --batch --passphrase-fd 0 --decrypt --quiet "password.txt.gpg")
#PASSWORD=$(gpg --batch --pinentry-mode loopback --passphrase-fd 0 -d "password.txt.gpg")
#echo "qwerty" | gpg --batch --passphrase-fd 0 -d encrypted_file.gpg

# Проверка расшифровки ключа
if [ -z "$PASSWORD" ]; then
  echo "Ошибка: не удалось расшифровать ключ."
  exit 1
fi




# Убедитесь, что директория для бэкапов существует
mkdir -p $BACKUP_DIR

# Создание бэкапа
PG_HOST="localhost"
PG_PORT="5432"
PG_USER="replica"
DATE=$(date +%Y-%m-%d)

# Выполнение pg_basebackup с экспортом ключа к постресу
export PGPASSWORD="$PASSWORD"
pg_basebackup -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -D "$BACKUP_DIR/$DATE" -F tar -X stream -P -v

#Проверка выполнения backup
if [ $? -eq 0 ]; then
    echo "Резервное копирование успешно завершено: $BACKUP_DIR/$DATE"
else
    echo "Ошибка при выполнении резервного копирования."
    exit 1
fi

# Удаление старых бэкапов ( старше 7 дней)
find $BACKUP_DIR -type d -name "*" -mtime +7 -exec rm {} \;

echo "Старые бэкапы удалены."

unset PGPASSWORD