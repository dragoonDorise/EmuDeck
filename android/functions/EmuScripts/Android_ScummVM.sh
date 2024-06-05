#!/bin/bash

function Android_ScummVM_install(){
	setMSG "Installing ScummVM"
	temp_url="https://downloads.scummvm.org/frs/scummvm/2.8.0/scummvm-2.8.0-android-arm64-v8a.apk"
	temp_emu="scummvm"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function Android_ScummVM_init(){
	echo "NYI"
}

function Android_ScummVM_setup(){
	adb shell pm grant org.scummvm.scummvm android.permission.WRITE_EXTERNAL_STORAGE
	adb shell am start -n org.scummvm.scummvm/.ui.main.MainActivity
	sleep 1
	adb shell am force-stop org.scummvm.scummvm

}

function Android_ScummVM_IsInstalled(){
	package="org.scummvm.scummvm"
	Android_ADB_appInstalled $package
}