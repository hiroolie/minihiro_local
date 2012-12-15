@echo on

set MYSQLDUMP="C:\Program Files\MySQL\MySQL Server 5.5\bin\mysqldump.exe"
set WINRAR="C:\Program Files (x86)\WinRAR\WinRAR.exe"
set BACKUPDIR="D:\Users\hiRo\Documents\My Dropbox\Backup\wordpress\"
set CONFIGFILE="E:\Develop\Scripts\conf\mysql_databases.txt"

rem MySQLデータベースのバックアップと圧縮(前回ファイル上書き)を行う
rem バックアップ対象設定ファイルを1行ずつ読み込む
if not exist %CONFIGFILE% goto ERROR
for /f "usebackq" %%L in ( %CONFIGFILE% ) do call :BACKUP %%L 

goto :EOF

:BACKUP
rem 読み込んだ行を処理
rem mysqldumpの実行
set FILENAME=%~1

%MYSQLDUMP% -u root -phirohome %FILENAME% > %BACKUPDIR%%FILENAME%.sql
if ERRORLEVEL 1 goto :ERROR

REM 取得したdumpファイルの圧縮
REM cd %BACKUPDIR:~1,2%
REM cd %BACKUPDIR%
REM if ERRORLEVEL 1 goto :ERROR
REM %WINRAR% a -afzip %FILENAME% %BACKUPDIR%%FILENAME%.sql
REM if ERRORLEVEL 1 goto :ERROR

exit /b

:ERROR
echo "MySQLバックアップに失敗 %date% %time%" >> D:\Users\hiRo\Desktop\ERROR_bat.txt
