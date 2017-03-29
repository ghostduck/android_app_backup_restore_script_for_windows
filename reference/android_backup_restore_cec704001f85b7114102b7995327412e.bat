@echo off

REM Copy and edited from https://www.mobile01.com/topicdetail.php?f=566&t=3019116

SETLOCAL

REM This date will be used as file name during backup. Format is yyyymmdd_(app id).ab
for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (
     set dow=%%i
     set month=%%j
     set day=%%k
     set year=%%l
)
SET datestr=%dow%%month%%day%

adb start-server
cls
:start
@echo ********************************************
@echo *                                          *
@echo *           adb backup and restore         *
@echo *                                          *
@echo ********************************************
@echo.
FOR /F "tokens=1" %%i IN ('adb shell getprop ro.product.manufacturer') DO (
@echo Manufacturer: %%i
)
FOR /F "delims=/" %%a IN ('adb shell getprop ro.product.model') DO (
@echo Model: %%a
)
FOR /F "tokens=1" %%x IN ('adb shell getprop ro.build.version.release') DO (
@echo Version: %%x
)
FOR /F "tokens=1 delims=." %%k IN ('adb shell getprop ro.build.version.release') DO (
if %%k LSS 4 (
@echo Sorry, your device cannot use ADB backup
@echo.
pause
exit
))
@echo.
set /p chk="Everything correct? (y/n)"
if /i %chk% ==y (
cls
goto main
)
if /i %chk% ==n (
@echo.
@echo adb can't find device, please check your connection, driver, and make sure USB debugging is open in your Android device
@echo.
pause
exit
) else (
@echo Please enter correct letter
@echo.
pause
cls
goto start
)
:main
@echo ********************************************
@echo *                                          *
@echo *    Android app Backup and restore        *
@echo *                                          *
@echo ********************************************
@echo.
@echo.
@echo 1. Backup Nekoatsume
@echo 2. Restore Nekoatsume
@echo 3. End
@echo.
@echo.
set /p first="Enter(1-3) "
if %first% ==1 goto op1
if %first% ==2 goto op2
if %first% ==3 goto op3

if %first% GTR 3 (
@echo Wrong number try again
pause
cls
goto main
)
if %first% LSS 1 (
@echo Wrong number try again
pause
cls
goto main
)

REM INTENDED to use different file name for restoration - Just prevent you from save/loading the wrong file

:op1
@echo.
set /p chk="Really want to backup Nekoatsume with APK? Will save in a file under \backup\ with today's name (y/n)"
@echo.
if /i %chk% ==y (
adb backup jp.co.hit_point.nekoatsume -apk -f "backup\%datestr%_jp.co.hit_point.nekoatsume.ab"
)

@echo.
pause
cls
goto main

:op2
@echo.
@echo Restore Nekoatsume (Make sure jp.co.hit_point.nekoatsume.ab is available in local directory)
@echo.
set /p chk="Really want to restore Nekoatsume? (y/n)"
if /i %chk% ==y (
adb restore "jp.co.hit_point.nekoatsume.ab"
@echo.
adb kill-server
pause
exit
)

cls
goto main

:op3
adb kill-server
exit
