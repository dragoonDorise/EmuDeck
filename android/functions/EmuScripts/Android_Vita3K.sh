#!/bin/bash

function Android_Vita3K_install(){
	temp_url="$(getLatestReleaseURLGH "Vita3K/Vita3K-Android" ".apk")"
	temp_emu="vita3k"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function Android_Vita3K_init(){
	echo "NYI"
}

function Android_Vita3K_setup(){
	echo "NYI"
}

function Android_Vita3K_IsInstalled(){
	package="com.retroarch.aarch64"
	test= adb shell pm list packages $package
	if [ $test == "true" ]; then
		echo "true"
	else
		echo "false"
	fi
}