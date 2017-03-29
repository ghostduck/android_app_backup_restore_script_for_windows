#!/usr/bin/python

#
# Original idea from https://www.mobile01.com/topicdetail.php?f=566&t=3019116
#
# This script creates the batch file to backup up your Android apps using Windows.
#
# You should enable USB debugging in your Android device, then run the generated
# script to backup your app.
#
# Usage for this script: Update the params in main() manually then run this script
# to generate your own batch file.
#
# Note: Look at the generated script to have a better grasp at this piece of code
#

from string import Template

# pickle and hash: Just for consistent file name on the output batch file
# http://stackoverflow.com/questions/5417949/computing-an-md5-hash-of-a-data-structure
import pickle 
import hashlib

def var_digest(i):
	data_pickle = pickle.dumps(i)
	# NOTE: I know MD5 is not secure, but good enough for same file name for same input
	data_md5 = hashlib.md5(data_pickle).hexdigest()
	return data_md5

def build_menu_flow(n):
	# n is len(p) 
	# we use n and 2n+1 to create this simple control part
	
	# control flow: make sure user only enters the correct number
	
	total = 2*n + 1
	t = '''set /p first="Enter(1-{n}) "'''.format(n=total) + "\n"
	
	# start from 1, end at total(include total)
	for k in range(total):
		t += "if %first% =={n} goto op{n}".format(n=k+1) + "\n"

	# beginning space cannot be removed easily so I have to do in this way...
	t += r'''
if %first% GTR {n} (
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
)'''.format(n=total)
		
	return t

def backup_option(n, app_id, app_name, backup_apk):
	with_apk_option = " -apk" if backup_apk else ""
	with_apk = " with APK" if backup_apk else ""
	
	d = dict(
		n = n,
		app_id = app_id,
		app_name = app_name,
		with_apk = with_apk,
		with_apk_option = with_apk_option		
	)
	
	opt = Template(r"""
:op${n}
@echo.
set /p chk="Really want to backup ${app_name}${with_apk}? Will save in a file under \backup\ with today's name (y/n)"
@echo.
if /i %chk% ==y (
adb backup ${app_id}${with_apk_option} -f "backup\%datestr%_${app_id}.ab"
)

@echo.
pause
cls
goto main
""")
	
	return opt.substitute(d)
	
def restore_option(n, app_id, app_name):
	d = dict(
		n = n,
		app_id = app_id,
		app_name = app_name		
	)
	
	opt = Template(r"""
:op${n}
@echo.
@echo Restore ${app_name} (Make sure ${app_id}.ab is available in local directory)
@echo.
set /p chk="Really want to restore ${app_name}? (y/n)"
if /i %chk% ==y (
adb restore "${app_id}.ab"
@echo.
adb kill-server
pause
exit
)

cls
goto main
""")
	
	return opt.substitute(d)
	
def build_menu(p):
	t = ""
	
	# menu has 2n + 1 items, n is the number of apps in p
	# We use the order of Backup app, then Restore app
	for idx, tup in enumerate(p, start=1):
		t += "@echo {n}. Backup {app_name}".format(n=idx*2 - 1, app_name=tup[1]) + "\n"
		t += "@echo {n}. Restore {app_name}".format(n=idx*2, app_name=tup[1]) + "\n"
		
	# the last one is the escape option
	t += "@echo {n}. End".format(n=len(p)*2+1)

	return t
	
def build_opts(p):
	t = ""
	
	# Options in between: Backup app, then restore app
	for idx, tup in enumerate(p, start=1):
		app_id, app_name, backup_apk = tup
		t += backup_option(idx*2 - 1, app_id, app_name, backup_apk)
		t += restore_option(idx*2, app_id, app_name)
	
	# Last option: exit
	t += r"""
:op{n}
adb kill-server
exit""".format(n=len(p)*2+1)
	
	return t

def generate_batch(p):
	# read file
	f = open("batch_template.txt", "r")
	
	# use params to write the script
	
	# the hash will be the new batch file name, same p should generate same batch file
	file_id = var_digest(p)

	d = dict(
		batch_menu = build_menu(p),
		batch_opts = build_opts(p),
		batch_control = build_menu_flow(len(p))
	)
	# the batch file content
	batch_content = Template(f.read()).substitute(d)
	
	# output file
	out = open("android_backup_restore_{n}.bat".format(n=file_id), "w")
	out.write(batch_content)
	
	# cleanup
	f.close()
	out.close()

	print("Batch file created")

def main():
	# Setup the parameters here
	params = (
		# Example using nekoatsume
		# (app id, display name in batch file, (optional)True if you want to backup both data and APK)
		# The script does not backup APK by default, only data.
		#
		# WARNING: You CAN shoot your feet with this script with strange strings as input.
		# I don't care for security this time since you are expected to run the generated batch file YOURSELF.
		# You have been WARNED if you don't use this script carefully.
		#
		# Finally, I don't recommend having more than 5 items here.
		# That would be too long in DOS windows. I recommend building separate scripts instead.
		#
		("jp.co.hit_point.nekoatsume", "Nekoatsume", False),
		#("more apps", "here if you want", False),
	)
	generate_batch(params)

if __name__ == "__main__":
	main()
	print("END of program")
    

