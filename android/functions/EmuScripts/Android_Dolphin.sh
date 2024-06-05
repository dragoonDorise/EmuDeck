#!/bin/bash

function Android_Dolphin_install(){
	setMSG "Installing Dolphin"
	temp_url="$(getLatestReleaseURLGH "Medard22/Dolphin-MMJR2-VBI" ".apk")"
	temp_emu="dolphinmmjr2"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function Android_Dolphin_init(){
	setMSG "Setting up Dolphin"

	rsync -ra "$HOME/.config/EmuDeck/backend/android/configs/mmjr2-vbi/" "$Android_temp_internal/mmjr2-vbi/"
	originFile="$Android_temp_internal/mmjr2-vbi/Config/Dolphin.ini"
	origin="XXXX"

	#SD or internal?
	if [[ "$androidStoragePath" == *-* ]]; then
		target="${androidStoragePath//\/storage\//}"
	else
		target="primary"
	fi

	sed -E -i "s|$origin|$target|g" "$originFile"

}

function Android_Dolphin_setup(){
	adb shell pm grant org.dolphinemu.mmjr android.permission.WRITE_EXTERNAL_STORAGE
	adb shell am start -n org.dolphinemu.mmjr/org.dolphinemu.dolphinemu.ui.main.MainActivity
	sleep 1
	adb shell am force-stop org.dolphinemu.mmjr

}

function Android_Dolphin_IsInstalled(){
	package="org.dolphinemu.mmjr"
	Android_ADB_appInstalled $package
}