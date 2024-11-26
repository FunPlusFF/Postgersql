CHCP 1251
SET PGBIN=C:\Program Files\PostgreSQL\16\bin
Set PGHOST=localhost
SET PGPORT=5432
SET PGUSER=postgres
SET PGPASSWORD=1
SET DATETIME=%DATE:~0,2%.%DATE:~3,2%.%DATE:~-4%
SET PGDATABASE=testdb

CALL "%PGBIN%\pg_basebackup.exe" --format=t -v --wal-method=stream --compress=9  --checkpoint=fast -P -R -D D:\Backup\%DATETIME%\

SET Path2Del=D:\Backup
forfiles -p "%Path2Del%" -s -m *.* -d -1 -c "cmd /c del /q @path"

for /f %%D in ('DIR cd "%Path2Del%" /AD/B/S ^| sort /r') do RD "%%D"
 