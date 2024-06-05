#!/bin/bash

function Android_PPSSPP_install(){
	temp_url="https://www.ppsspp.org/files/1_16_6/ppsspp.apk"
	temp_emu="ppsspp"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function Android_PPSSPP_init(){
	echo "NYI"
}

function Android_PPSSPP_setup(){
	setMSG "PPSSPP"
	adb shell pm grant org.ppsspp.ppsspp android.permission.WRITE_EXTERNAL_STORAGE
	adb shell am start -n org.ppsspp.ppsspp/.PpssppActivity
	zenity --info --text="Waiting for user action..."
	adb shell am force-stop org.ppsspp.ppsspp
}

function Android_PPSSPP_IsInstalled(){
	package="org.ppsspp.ppsspp"
	test= adb shell pm list packages $package
	if [ $test == "true" ]; then
		echo "true"
	else
		echo "false"
	fi
}