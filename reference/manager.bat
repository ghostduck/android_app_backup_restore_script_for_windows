@echo off
adb start-server
cls
:start
@echo ********************************************
@echo *                                          *
@echo *           adb備份與還原工具程序          *
@echo *                                          *
@echo ********************************************
@echo.
FOR /F "tokens=1" %%i IN ('adb shell getprop ro.product.manufacturer') DO (
@echo 手機廠商: %%i
)
FOR /F "delims=/" %%a IN ('adb shell getprop ro.product.model') DO (
@echo 手機型號: %%a
)
FOR /F "tokens=1" %%x IN ('adb shell getprop ro.build.version.release') DO (
@echo 版本: %%x
)
FOR /F "tokens=1 delims=." %%k IN ('adb shell getprop ro.build.version.release') DO (
if %%k LSS 4 (
@echo 抱歉，您的裝置版本並不支援adb備份
@echo.
pause
exit
))
@echo.
set /p chk="以上資訊是否顯示正確? (y/n)"
if /i %chk% ==y (
cls
goto main
)
if /i %chk% ==n (
@echo.
@echo adb找不到裝置 請檢查是否連接 確認驅動是否正確安裝 並察看USB除錯是否開啟
@echo.
pause
exit
) else (
@echo 請輸入正確的文字
@echo.
pause
cls
goto start
)
:main
@echo ********************************************
@echo *                                          *
@echo *           adb備份與還原工具程序          *
@echo *                                          *
@echo ********************************************
@echo.
@echo.
@echo 1. 備份手機程式及資料(不含系統)
@echo 2. 備份整支手機 (包含系統APK 請謹慎使用！)
@echo 3. 備份單個APP
@echo 4. 還原資料
@echo 5. 連線測試
@echo 6. 離開
@echo.
@echo.                                          
set /p first="請輸入代號(1~6) "
if %first% ==1 goto op1
if %first% ==2 goto op2
if %first% ==3 goto op3
if %first% ==4 goto op4
if %first% ==5 goto op5
if %first% ==6 goto op6
if %first% GTR 6 (
@echo 代號不正確 請重新輸入
pause
cls
goto main
)
if %first% LSS 1 (
@echo 代號不正確 請重新輸入
pause
cls
goto main
)

:op1
@echo.
@echo 請指定存檔路徑與檔名
set /p input="若在同目錄，只需輸入檔名(不需輸入.ab) "
@echo.
set /p apk="是否要備份APK? (y/n) "
set /p stor="是否要連同記憶卡(儲存空間)資料一起備份? (y/n) "
if /i %apk% ==y (
 if /i %stor%==y (
adb backup -apk -shared -nosystem -all -f "%input%.ab"
  ) else (
adb backup -apk -noshared -nosystem -all -f "%input%.ab"
)
) else (
 if /i %stor%==y (
adb backup -shared -nosystem -all -f "%input%.ab"
) else (
adb backup -noshared -nosystem -all -f "%input%.ab"
)
) 
@echo.
adb kill-server
pause
exit

:op2
@echo.
@echo.
@echo 警告！！！
@echo 備份含有系統軟體的檔案 雖然會一併備份部分系統設定和聯絡人等資訊
@echo 但在還原時有一定的風險 該備份檔不得使用在不同軟體版本 更不得使用在不同手機上
@echo 否則可能會發生系統軟體無法執行或是手機變磚的狀況
@echo.
@echo 另外 亦不保證使用在相同軟體版本且相同的手機上就不會出問題
@echo.
set /p confirm="您確定要繼續執行嗎? (y/n) "
if /i %confirm% ==y (
goto op21
) else (
cls
goto main
)

:op21
@echo.
@echo 請指定存檔路徑與檔名
set /p input="若在同目錄，只需輸入檔名(不需輸入.ab) "
@echo.
set /p apk="是否要備份APK? (y/n) "
set /p stor="是否要連同記憶卡(儲存空間)資料一起備份? (y/n) "
if /i %apk% ==y (
 if /i %stor%==y (
adb backup -apk -shared -system -all -f "%input%.ab"
  ) else (
adb backup -apk -noshared -system -all -f "%input%.ab"
)
) else (
 if /i %stor%==y (
adb backup -shared -system -all -f "%input%.ab"
) else (
adb backup -noshared -system -all -f "%input%.ab"
)
) 
@echo.
adb kill-server
pause
exit

:op3
@echo 請輸入你想要備份的APP類別名稱
set /p name="注意！並非APP的直接名稱！ "
@echo.
@echo 請輸入備份檔存放路徑與檔名
set /p save="若在同目錄，只需輸入檔名(不需輸入.ab) "
@echo.
set /p apk="是否要備份APK? (y/n) "
if /i %apk% ==y (
adb backup -apk %name% -f "%save%.ab"
) else (
adb backup %name% -f "%save%.ab"
) 
@echo.
pause
cls
goto main

:op4
@echo 請輸入備份檔存放路徑與檔名
set /p input="若在同目錄，只需輸入檔名(不需輸入.ab) "
adb restore "%input%.ab"
@echo.
adb kill-server
pause
exit

:op5
@echo list of devices attached底下有出現手機序號就表示有抓到
@echo.
adb devices
@echo.
pause
cls
goto main

:op6
adb kill-server
exit
