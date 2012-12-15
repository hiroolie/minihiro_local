@echo off

set FILE=test.conf

setlocal enabledelayedexpansion

set RESULT=

rem remで始まる行をコメント行として読み飛ばして変数RESULTに格納
for /f "usebackq tokens=*" %%i in (`findstr /v "^rem" %FILE%`) do (
	set RESULT=!RESULT!^

	%%i
)

for /f "tokens=1-3" %%a in ("!RESULT!") do (
	
	if "%%a" equ "-" (
		set OPTION=
	) else (
		set OPTION=-o %%a
	)
	set NFSDIR=%%b
	set MOUNT_POINT=%%c
	
	@echo mount !OPTION! !NFSDIR! !MOUNT_POINT!

)

endlocal