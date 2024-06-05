#!/bin/bash

function Android_Citra_install(){
	temp_url="$(getLatestReleaseURLGH "weihuoya/citra" ".apk")"
	temp_emu="citra"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function Android_Citra_init(){
	setMSG "Setting up Citra"
	rsync -r "$HOME/.config/EmuDeck/backend/android/configs/citra-emu/" "$Android_temp_internal/citra-emu/"
}

function Android_Citra_setup(){
	adb shell pm grant org.citra.emu android.permission.WRITE_EXTERNAL_STORAGE
	adb shell am start -n org.citra.emu/.ui.MainActivity
	sleep 1
	adb shell am force-stop org.citra.emu
}

function Android_Citra_IsInstalled(){
	package="org.citra.emu"
	Android_ADB_appInstalled $package
}