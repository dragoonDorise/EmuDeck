#!/bin/bash

Android_Pegasus_temp="$Android_temp_android_data/org.pegasus_frontend.android/files/pegasus-frontend"
mkdir -p $Android_Pegasus_temp/themes
function Android_Pegasus_install(){
	setMSG "Installing Pegasus"
	temp_url="$(getLatestReleaseURLGH "mmatyas/pegasus-frontend" "android64.apk")"
	temp_emu="pegasus"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}


function Android_Pegasus_dl_theme(){
	temp_emu=$1
	temp_url=$2
	Android_download "$temp_emu.zip" $temp_url
	unzip -o "$Android_folder/$temp_emu.zip" -d $Android_Pegasus_temp/themes/$temp_emu
	rm -rf "$Android_folder/$temp_emu.zip"
}

function Android_Pegasus_init(){
	setMSG "Setting up Pegasus"
	#Download theme
	temp_url="$(getLatestReleaseURLGH "dragoonDorise/retromega-next" ".zip")"
	temp_emu="retromega-next"
	Android_Pegasus_dl_theme $temp_emu $temp_url

	temp_url="$(getLatestReleaseURLGH "dragoonDorise/ES-Simple-Clean" ".zip")"
	temp_emu="simple-clean"
	Android_Pegasus_dl_theme $temp_emu $temp_url

	temp_url="$(getLatestReleaseURLGH "dragoonDorise/COLORFUL" ".zip")"
	temp_emu="colorful"
	Android_Pegasus_dl_theme $temp_emu $temp_url

	temp_url="$(getLatestReleaseURLGH "dragoonDorise/RP-epic-noir" ".zip")"
	temp_emu="epicnoir"
	Android_Pegasus_dl_theme $temp_emu $temp_url

	#Change paths
	rsync -ra "$HOME/.config/EmuDeck/backend/android/configs/Android/data/org.pegasus_frontend.android/files/pegasus-frontend/" "$Android_Pegasus_temp/"
	originFile="$Android_Pegasus_temp/game_dirs.txt"
	origin="XXXX"
	target="$androidStoragePath"
	sed -E -i "s|$origin|$target|g" "$originFile"

}

function Android_Pegasus_setup(){
	adb shell pm grant org.pegasus_frontend.android android.permission.WRITE_EXTERNAL_STORAGE
}

function Android_Pegasus_IsInstalled(){
	package="org.pegasus_frontend.android"
	Android_ADB_appInstalled $package
}

