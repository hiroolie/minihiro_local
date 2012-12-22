@echo off

set MYNAME=%0
set CONF_FILE=%MYNAME:.cmd=.env%

set EVE_INF8=EVENTCREATE /T INFORMATION /ID 778 /L APPLICATION /D
set EVE_ERR8=EVENTCREATE /T ERROR /ID 778 /L APPLICATION /D
set RC=0

setlocal enabledelayedexpansion

rem 処理開始メッセージ
echo %MYNAME%を開始します。
%EVE_INF8% "%MYNAME%を開始します。">nul

rem 設定ファイルが読めなかったら即異常終了。
IF NOT EXIST %CONF_FILE% (
    set RC=8
    echo 設定ファイル^( %CONF_FILE% ^)が読み込めません。
    %EVE_ERR% "設定ファイル^( %CONF_FILE% ^)が読み込めません。">nul
    goto :END
)

rem 設定ファイルからremで始まる行をコメント行として読み飛ばして変数RESULTに格納
set RESULT=
for /f "usebackq tokens=*" %%i in (`findstr /v "^rem" %CONF_FILE%`) do (
    set RESULT=!RESULT!^

    %%i
)

rem 数RESULTから1カラム目をドライブレターに、2カラム目をマウントポイントに設定
for /f "tokens=1,2" %%a in ("!RESULT!") do (

    set DRIVE_LETER=%%a
    set MOUNT_POINT=%%b

    rem 引数によって処理を分岐
        if "%1" == "mount" (
        set PROCESS=アンマウント
        call :MOUNT
    ) else if "%1" == "unmount" (
        set PROCESS=アンマウント
        call :UNMOUNT
    ) else (
        set RC=4
        echo 引数の指定が間違っています。(%MYNAME% [mount^|unmount])
        %EVE_ERR8% "引数の指定が間違っています。(%MYNAME% [mount^|unmount])">nul
        goto :END
    )
    rem 処理結果表示
    if %RC% neq 0 (
        echo 外部ディスク^(%MOUNT_POINT%^)の%PROCESS%中にエラーが発生しました。
        %EVE_ERR8% "外部ディスク^(%MOUNT_POINT%^)の%PROCESS%中にエラーが発生しました。">nul
        set /a RC=8
    )

)
rem 終了処理へ。
goto :END

:MOUNT 
    echo ^(%DRIVE_LETER%^)に外部ディスク^(%MOUNT_POINT%^)をマウントします。
    %EVE_INF8% "^(%DRIVE_LETER%^)に外部ディスク^(%MOUNT_POINT%^)をマウントします。">nul

    mountvol %DRIVE_LETER% %MOUNT_POINT%
    set /a RC=%ERRORLEVEL%

    exit /b

:UNMOUNT 
    echo ^(%DRIVE_LETER%^)から外部ディスク^(%MOUNT_POINT%^)をアンマウントします。
    %EVE_INF8% "^(%DRIVE_LETER%^)から外部ディスク^(%MOUNT_POINT%^)をアンマウントします。">nul

    mountvol %DRIVE_LETER% /P
    set /a RC=%ERRORLEVEL%

    exit /b

:END
    if %RC% GTR 0 (
        echo %MYNAME%が異常終了しました。
        %EVE_ERR8% "%MYNAME%が異常終了しました。">nul
    ) else (
        echo %MYNAME%が正常終了しました。
        %EVE_INF8% "%MYNAME%が正常終了しました。">nul
    )

exit /b %RC%