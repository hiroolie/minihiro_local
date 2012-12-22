@echo on
::Demo-Backup.bat
::demonstration script using WBADMIN.EXE on a Windows Server 2008 R2 Server

set MYNAME=%0
set CONF_FILE=%MYNAME:.cmd=.env%

set EVE_INF8=EVENTCREATE /T INFORMATION /ID 778 /L APPLICATION /D
set EVE_ERR8=EVENTCREATE /T ERROR /ID 778 /L APPLICATION /D
set RC=0

rem �����J�n���b�Z�[�W
echo %MYNAME%���J�n���܂��B
%EVE_INF8% "%MYNAME%���J�n���܂��B">nul

rem �ݒ�t�@�C�����ǂ߂Ȃ������瑦�ُ�I���B
IF NOT EXIST %CONF_FILE% (
    set RC=8
    echo �ݒ�t�@�C��^( %CONF_FILE% ^)���ǂݍ��߂܂���B
    %EVE_ERR% "�ݒ�t�@�C��^( %CONF_FILE% ^)���ǂݍ��߂܂���B">nul
    goto :END
)

rem �ݒ�t�@�C������rem�Ŏn�܂�s���R�����g�s�Ƃ��ēǂݔ�΂��ĕϐ���ݒ�
set RESULT=
for /f "usebackq tokens=*" %%i in (`findstr /v "^rem" %CONF_FILE%`) do (
    set %%i
)

rem �o�b�N�A�b�v�T�[�o�[�ɐڑ��ł��Ȃ�������G���[8
echo Connecting backup server
net use %SHARE_DIR% %AUTH_PASS% /user:%AUTH_USER%

set RC=%ERRORLEVEL%
if %RC% neq 0 (
    echo �o�b�N�A�b�v�T�[�o�[�ɐڑ��ł��܂���ł����B
    %EVE_ERR8% "�o�b�N�A�b�v�T�[�o�[�ɐڑ��ł��܂���ł����B">nul
    set /a RC=8
    goto :END
)

rem define date time variables for building the folder name
set m=%date:~5,2%
set d=%date:~8,2%
set y=%date:~0,4%

set newfolder=%SHARE_DIR%\%y%%m%%d%
echo Creating %newfolder%

if EXIST %newfolder% (
    echo �o�b�N�A�b�v��f�B���N�g���͊��ɑ��݂��܂��B
    %EVE_ERR8% "�o�b�N�A�b�v��f�B���N�g���͊��ɑ��݂��܂��B">nul
    set /a RC=4
    goto :END
)

mkdir %newfolder%

set RC=%ERRORLEVEL%
if %RC% neq 1 (
    echo �o�b�N�A�b�v��f�B���N�g�����쐬�ł��܂���ł����B
    %EVE_ERR8% "�o�b�N�A�b�v��f�B���N�g�����쐬�ł��܂���ł����B">nul
    set /a RC=8
    goto :END
)

rem run the backup
echo Backing up %INCLUDE% to %newfolder%
wbadmin start backup -backuptarget:%newfolder% -INCLUDE:%INCLUDE% -allCritical -systemState -vssFull -quiet

set RC=%ERRORLEVEL%
if %RC% neq 0 (
    echo �o�b�N�A�b�v���쐬�ł��܂���ł����B
    %EVE_ERR8% "�o�b�N�A�b�v���쐬�ł��܂���ł����B">nul
    set /a RC=8
    goto :END
)

rem Clear variables
set SHARE_DIR=
set INCLUDE=
set m=
set d=
set y=
set newfolder=

:END
    if %RC% GTR 0 (
        echo %MYNAME%���ُ�I�����܂����B
        %EVE_ERR8% "%MYNAME%���ُ�I�����܂����B">nul
    ) else (
        echo %MYNAME%������I�����܂����B
        %EVE_INF8% "%MYNAME%������I�����܂����B">nul
    )

exit /b %RC%