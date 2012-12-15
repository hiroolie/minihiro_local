@echo off

cd /d E:\Deployment\wwwroot\homeroot

echo ^<?xml version="1.0" encoding="Shift_JIS" ?^> > getlogs_DEVICE.xml
echo ^<?xml version="1.0" encoding="Shift_JIS" ?^> > getlogs_DEAD.xml
echo ^<?xml version="1.0" encoding="Shift_JIS" ?^> > getlogs_EVENT.xml

echo ^<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"^> >getconfig_AL.html
echo ^<html^> >>getconfig_AL.html
echo   ^<head^> >>getconfig_AL.html
echo     ^<meta http-equiv="Content-Type" content="text/html; charset=SHIFT_JIS"^> >>getconfig_AL.html
echo     ^<title^>DeviceLog^</title^> >>getconfig_AL.html
echo     ^<link rel="stylesheet" type="text/css" href="style.css"^> >>getconfig_AL.html
echo   ^</head^> >>getconfig_AL.html
echo   ^<body^> >>getconfig_AL.html
echo     ^<div class="container"^> >>getconfig_AL.html
echo       ^<div id="page-container"^> >>getconfig_AL.html
echo         ^<div class="content"^> >>getconfig_AL.html
echo           ^<pre class="brush: bash; gutter: true; first-line: 1"^> >>getconfig_AL.html

arcconf getconfig 1 AL   >> getconfig_AL.html

echo             ^</div^> >> getconfig_AL.html
echo          ^</div^> >> getconfig_AL.html
echo       ^</div^> >> getconfig_AL.html
echo    ^</body^> >> getconfig_AL.html
echo ^</html^> >> getconfig_AL.html


arcconf getlogs 1 DEVICE | findstr "<" >> getlogs_DEVICE.xml
arcconf getlogs 1 DEAD   | findstr "<" >> getlogs_DEAD.xml
arcconf getlogs 1 EVENT  | findstr "<" >> getlogs_EVENT.xml

D:\ProgramFilesD\SaxonHE9.4N\bin\Transform.exe -s:getEVENT.xml -xsl:getEVENT_style.xsl -o:getEVENT.html
D:\ProgramFilesD\SaxonHE9.4N\bin\Transform.exe -s:getDEVICE.xml -xsl:getDEVICE_style.xsl -o:getDEVICE.html
D:\ProgramFilesD\SaxonHE9.4N\bin\Transform.exe -s:getDEAD.xml -xsl:getDEAD_style.xsl -o:getDEAD.html

