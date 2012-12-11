'指定はミリ秒で、1秒なら1000、5秒だと5000。
WScript.sleep(60000)

Set objShell = WScript.CreateObject("WScript.Shell")

objShell.Run """C:\Program Files (x86)\AppleWirelessKeyboardHelper\AppleWirelessKeyboardHelper.exe"""
