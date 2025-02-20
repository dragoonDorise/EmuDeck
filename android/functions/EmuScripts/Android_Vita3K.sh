#!/bin/bash

function Android_Vita3K_install(){
	setMSG "Installing Vita3K"
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
	Android_ADB_appInstalled $package
}