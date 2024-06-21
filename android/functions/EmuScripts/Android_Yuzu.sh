#!/bin/bash

function Android_Yuzu_install(){
	setMSG "Installing Yuzu"
	temp_url="$(getLatestReleaseURLGH "yuzu-emu/yuzu-android" ".apk")"
	temp_emu="yuzu"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function Android_Yuzu_init(){
	setMSG "Setting up Yuzu"

	rsync -ra "$HOME/.config/EmuDeck/backend/android/configs/Android/data/org.yuzu.yuzu_emu/" "$Android_temp_android_data/org.yuzu.yuzu_emu/"

	originFile="$Android_temp_android_data/org.yuzu.yuzu_emu/files/config/config.ini"
	origin="XXXX"
	#SD or internal?
	#SD or internal?
	if [[ "$androidStoragePath" == *-* ]]; then
		target="${androidStoragePath//\/storage\//}"
	else
		target="primary"
	fi

	sed -E -i "s|$origin|$target|g" "$originFile"

}

function Android_Yuzu_setup(){
	setMSG "YUZU"
	adb shell pm grant org.yuzu.yuzu_emu android.permission.WRITE_EXTERNAL_STORAGE
	adb shell am start -n org.yuzu.yuzu_emu/.ui.main.MainActivity
	zenity --info --width=400 --text="Waiting for user action..."
	adb shell am force-stop org.yuzu.yuzu_emu

}

function Android_Yuzu_IsInstalled(){
	package="org.yuzu.yuzu_emu"
	Android_ADB_appInstalled $package
}