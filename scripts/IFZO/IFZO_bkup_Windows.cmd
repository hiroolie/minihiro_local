@echo on
::Demo-Backup.bat
::demonstration script using WBADMIN.EXE on a Windows Server 2008 R2 Server

set MYNAME=%0
set CONF_FILE=%MYNAME:.cmd=.env%

set EVE_INF8=EVENTCREATE /T INFORMATION /ID 778 /L APPLICATION /D
set EVE_ERR8=EVENTCREATE /T ERROR /ID 778 /L APPLICATION /D
set RC=0

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

rem 設定ファイルからremで始まる行をコメント行として読み飛ばして変数を設定
set RESULT=
for /f "usebackq tokens=*" %%i in (`findstr /v "^rem" %CONF_FILE%`) do (
    set %%i
)

rem バックアップサーバーに接続できなかったらエラー8
echo Connecting backup server
net use %SHARE_DIR% %AUTH_PASS% /user:%AUTH_USER%

set RC=%ERRORLEVEL%
if %RC% neq 0 (
    echo バックアップサーバーに接続できませんでした。
    %EVE_ERR8% "バックアップサーバーに接続できませんでした。">nul
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
    echo バックアップ先ディレクトリは既に存在します。
    %EVE_ERR8% "バックアップ先ディレクトリは既に存在します。">nul
    set /a RC=4
    goto :END
)

mkdir %newfolder%

set RC=%ERRORLEVEL%
if %RC% neq 1 (
    echo バックアップ先ディレクトリを作成できませんでした。
    %EVE_ERR8% "バックアップ先ディレクトリを作成できませんでした。">nul
    set /a RC=8
    goto :END
)

rem run the backup
echo Backing up %INCLUDE% to %newfolder%
wbadmin start backup -backuptarget:%newfolder% -INCLUDE:%INCLUDE% -allCritical -systemState -vssFull -quiet

set RC=%ERRORLEVEL%
if %RC% neq 0 (
    echo バックアップを作成できませんでした。
    %EVE_ERR8% "バックアップを作成できませんでした。">nul
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
        echo %MYNAME%が異常終了しました。
        %EVE_ERR8% "%MYNAME%が異常終了しました。">nul
    ) else (
        echo %MYNAME%が正常終了しました。
        %EVE_INF8% "%MYNAME%が正常終了しました。">nul
    )

exit /b %RC%