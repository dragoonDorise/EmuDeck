#!/bin/bash

function Android_Azahar_install(){
	setMSG "Installing Azahar"
	temp_url="$(getLatestReleaseURLGH "azahar-emu/azahar" ".apk")"
	temp_emu="azahar"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function Android_Azahar_init(){
	setMSG "Setting up Azahar"
	rsync -ra "$emudeckBackend/android/configs/azahar-emu/" "$Android_temp_internal/azahar-emu/"
}

function Android_Azahar_setup(){
	adb shell pm grant io.github.lime3ds.android android.permission.WRITE_EXTERNAL_STORAGE
	adb shell am start -n io.github.lime3ds.android/.ui.MainActivity
	sleep 1
	adb shell am force-stop  io.github.lime3ds.android
}

function Android_Azahar_IsInstalled(){
	package=" io.github.lime3ds.android"
	Android_ADB_appInstalled $package
}
