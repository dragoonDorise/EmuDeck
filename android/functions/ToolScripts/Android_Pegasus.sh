#!/bin/bash

Android_Pegasus_temp="$Android_temp_android_data/org.pegasus_frontend.android/files/pegasus-frontend"

function Android_Pegasus_install(){
	setMSG "Installing Pegasus"
	temp_url="$(Android_getLatestReleaseURLGH "mmatyas/pegasus-frontend" "android64.apk")"
	temp_emu="pegasus"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function Android_Pegasus_init(){
	setMSG "Setting up Pegasus"
	#Download theme
	mkdir -p "$Android_Pegasus_temp/themes/"
	temp_url="$(Android_getLatestReleaseURLGH "dragoonDorise/retromega-next" ".zip")"
	temp_emu="retromega-next"
	Android_download "$temp_emu.zip" $temp_url
	unzip "$Android_Pegasus_temp/themes/$temp_emu" -aoa "$Android_folder\$temp_emu.zip"
	rm -rf "$Android_folder\$temp_emu.zip"

	temp_url="$(Android_getLatestReleaseURLGH "dragoonDorise/ES-Simple-Clean" ".zip")"
	temp_emu="simple-clean"
	Android_download "$temp_emu.zip" $temp_url
	unzip "$Android_Pegasus_temp/themes/$temp_emu" -aoa "$Android_folder\$temp_emu.zip"
	rm -rf "$Android_folder\$temp_emu.zip"

	temp_url="$(Android_getLatestReleaseURLGH "dragoonDorise/COLORFUL" ".zip")"
	temp_emu="colorful"
	Android_download "$temp_emu.zip" $temp_url
	unzip "$Android_Pegasus_temp/themes/$temp_emu" -aoa "$Android_folder\$temp_emu.zip"
	rm -rf "$Android_folder\$temp_emu.zip"

	temp_url="$(Android_getLatestReleaseURLGH "dragoonDorise/RP-epic-noir" ".zip")"
	temp_emu="epicnoir"
	Android_download "$temp_emu.zip" $temp_url
	unzip "$Android_Pegasus_temp/themes/$temp_emu" -aoa "$Android_folder\$temp_emu.zip"
	rm -rf "$Android_folder\$temp_emu.zip"

	#Change paths
	rsync "$GOME/.config/EmuDeck/backend/android/configs/Android/data/org.pegasus_frontend.android/files/pegasus-frontend" "$Android_Pegasus_temp/"
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
	test= adb shell pm list packages $package
	if [ $test == "true" ]; then
		echo "true"
	else
		echo "false"
	fi
}

