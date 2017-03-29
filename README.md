# Android App Backup Script For Windows
Simple Python script to generate batch file for Windows to backup Android apps

Original idea from https://www.mobile01.com/topicdetail.php?f=566&t=3019116

## Usage: 
**Just update the params in main(), then run *create_script.py* to generate a batch file to backup/restore your Android apps.**

Please note that the save APK option may not work for some apps :(

## Batch file usage:
After the first check, you will see the menu with items.

* Backup [app name]: Save backup file in /backup in file name of yyyymmdd_packagename.ab

* Restore [app name]: Try to restore your Android data by reading packagename.ab in current directory.

**You probably NEED to COPY the backup file from /backup then RENAME it (by removing *'yyyymmdd_'*).**

## File structure:
- /reference - has the original batch file (manager.bat) and a generated batch file as example
- /backup - batch file will save backup files (yyyymmdd_packagename.ab) here [package name is refer to app id in script]
- create_script.py - the python script to generate batch file
- batch_template.txt - template file for script
- AdbWinUsbApi.dll, AdbWinApi.dll, adb.exe - required, I just copy them

