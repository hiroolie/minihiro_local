@echo on

set MYSQLDUMP="C:\Program Files\MySQL\MySQL Server 5.5\bin\mysqldump.exe"
set WINRAR="C:\Program Files (x86)\WinRAR\WinRAR.exe"
set BACKUPDIR="D:\Users\hiRo\Documents\My Dropbox\Backup\wordpress\"
set CONFIGFILE="E:\Develop\Scripts\conf\mysql_databases.txt"

rem MySQL�f�[�^�x�[�X�̃o�b�N�A�b�v�ƈ��k(�O��t�@�C���㏑��)���s��
rem �o�b�N�A�b�v�Ώېݒ�t�@�C����1�s���ǂݍ���
if not exist %CONFIGFILE% goto ERROR
for /f "usebackq" %%L in ( %CONFIGFILE% ) do call :BACKUP %%L 

goto :EOF

:BACKUP
rem �ǂݍ��񂾍s������
rem mysqldump�̎��s
set FILENAME=%~1

%MYSQLDUMP% -u root -phirohome %FILENAME% > %BACKUPDIR%%FILENAME%.sql
if ERRORLEVEL 1 goto :ERROR

REM �擾����dump�t�@�C���̈��k
REM cd %BACKUPDIR:~1,2%
REM cd %BACKUPDIR%
REM if ERRORLEVEL 1 goto :ERROR
REM %WINRAR% a -afzip %FILENAME% %BACKUPDIR%%FILENAME%.sql
REM if ERRORLEVEL 1 goto :ERROR

exit /b

:ERROR
echo "MySQL�o�b�N�A�b�v�Ɏ��s %date% %time%" >> D:\Users\hiRo\Desktop\ERROR_bat.txt
