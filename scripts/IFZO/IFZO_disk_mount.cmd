@echo off

set MYNAME=%0
set CONF_FILE=%MYNAME:.cmd=.env%

set EVE_INF8=EVENTCREATE /T INFORMATION /ID 778 /L APPLICATION /D
set EVE_ERR8=EVENTCREATE /T ERROR /ID 778 /L APPLICATION /D
set RC=0

setlocal enabledelayedexpansion

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

rem �ݒ�t�@�C������rem�Ŏn�܂�s���R�����g�s�Ƃ��ēǂݔ�΂��ĕϐ�RESULT�Ɋi�[
set RESULT=
for /f "usebackq tokens=*" %%i in (`findstr /v "^rem" %CONF_FILE%`) do (
    set RESULT=!RESULT!^

    %%i
)

rem ��RESULT����1�J�����ڂ��h���C�u���^�[�ɁA2�J�����ڂ��}�E���g�|�C���g�ɐݒ�
for /f "tokens=1,2" %%a in ("!RESULT!") do (

    set DRIVE_LETER=%%a
    set MOUNT_POINT=%%b

    rem �����ɂ���ď����𕪊�
        if "%1" == "mount" (
        set PROCESS=�A���}�E���g
        call :MOUNT
    ) else if "%1" == "unmount" (
        set PROCESS=�A���}�E���g
        call :UNMOUNT
    ) else (
        set RC=4
        echo �����̎w�肪�Ԉ���Ă��܂��B(%MYNAME% [mount^|unmount])
        %EVE_ERR8% "�����̎w�肪�Ԉ���Ă��܂��B(%MYNAME% [mount^|unmount])">nul
        goto :END
    )
    rem �������ʕ\��
    if %RC% neq 0 (
        echo �O���f�B�X�N^(%MOUNT_POINT%^)��%PROCESS%���ɃG���[���������܂����B
        %EVE_ERR8% "�O���f�B�X�N^(%MOUNT_POINT%^)��%PROCESS%���ɃG���[���������܂����B">nul
        set /a RC=8
    )

)
rem �I�������ցB
goto :END

:MOUNT 
    echo ^(%DRIVE_LETER%^)�ɊO���f�B�X�N^(%MOUNT_POINT%^)���}�E���g���܂��B
    %EVE_INF8% "^(%DRIVE_LETER%^)�ɊO���f�B�X�N^(%MOUNT_POINT%^)���}�E���g���܂��B">nul

    mountvol %DRIVE_LETER% %MOUNT_POINT%
    set /a RC=%ERRORLEVEL%

    exit /b

:UNMOUNT 
    echo ^(%DRIVE_LETER%^)����O���f�B�X�N^(%MOUNT_POINT%^)���A���}�E���g���܂��B
    %EVE_INF8% "^(%DRIVE_LETER%^)����O���f�B�X�N^(%MOUNT_POINT%^)���A���}�E���g���܂��B">nul

    mountvol %DRIVE_LETER% /P
    set /a RC=%ERRORLEVEL%

    exit /b

:END
    if %RC% GTR 0 (
        echo %MYNAME%���ُ�I�����܂����B
        %EVE_ERR8% "%MYNAME%���ُ�I�����܂����B">nul
    ) else (
        echo %MYNAME%������I�����܂����B
        %EVE_INF8% "%MYNAME%������I�����܂����B">nul
    )

exit /b %RC%