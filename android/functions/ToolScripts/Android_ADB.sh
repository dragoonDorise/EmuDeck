#!/bin/bash
#https://dl.google.com/android/repository/platform-tools-latest-linux.zip
#https://dl.google.com/android/repository/platform-tools-latest-darwin.zip
#https://dl.google.com/android/repository/platform-tools-latest-windows.zip


function Android_ADB_isInstalled(){
	if [ -e "$Android_ADB_path" ]; then
		echo "true"
		return 0
	else
		echo "false"
		return 1
	fi
}

function Android_ADB_install(){
	local outFile="adb.zip"
	local outDir="$HOME/emudeck/android"

	Android_download "$outFile" "$Android_ADB_url" && unzip -o "$outDir/$outFile" -d $outDir && rm -rf "$outDir/$outFile" && echo "true" && return 0

}

function Android_download(){
	local outDir="$HOME/emudeck/android/"
	local outFile="$HOME/emudeck/android/$1"
	local url=$2
	mkdir -p $outDir

	request=$(curl -w $'\1'"%{response_code}" --fail -L "$url" -o "${outFile}.temp" 2>&1 && echo $'\2'0 || echo $'\2'$?)

	returnCodes="${request#*$'\1'}"
	httpCode="${returnCodes%$'\2'*}"
	exitCode="${returnCodes#*$'\2'}"

	if [ "$httpCode" = "200" ]; then
		mv -v "$outFile.temp" "$outFile"
		return 0
	else
		echo "false"
		return 1
	fi

}

function Android_ADB_connected(){
	export PATH=$PATH:$Android_ADB_path
	local output=$(adb devices)
	local device_count=$(echo "$output" | grep -E "device\b" | wc -l)

	if [ "$device_count" -gt 0 ]; then
		echo "true"
		return 0
	else
		echo "false"
		return 1
	fi
}

function Android_ADB_push(){
	local origin=$1
	local destination=$2
	export PATH=$PATH:$Android_ADB_path
	adb push $origin $destination
}

Android_ADB_installAPK(){
	local apk=$1
	export PATH=$PATH:$Android_ADB_path
	adb install $apk && rm -rf $apk
}

Android_ADB_dl_installAPK(){
	local temp_emu=$1
	local temp_url=$2
	Android_download "$temp_emu.apk" $temp_url
	Android_ADB_installAPK "$HOME/emudeck/android/$temp_emu.apk"
}

function Android_ADB_getSDCard(){
	export PATH=$PATH:$Android_ADB_path
	adb shell sm list-volumes public | perl -lane 'print $F[-1]'
}
function Android_ADB_setPath(){
	export PATH=$PATH:$Android_ADB_path
}
function Android_ADB_init(){

	if [ $(Android_ADB_isInstalled) == "false" ]; then
		$(Android_ADB_install)
	fi


	local isConnected=$(Android_ADB_connected)
	local SDCardName=$(Android_ADB_getSDCard)
	local json='{
		"isConnected": "'"$isConnected"'",
		"SDCardName": "'"$SDCardName"'"
	}'

	echo $json;

}


function Android_ADB_appInstalled(){
	test=$(adb shell pm list packages $1)
	if [[ $test != "" ]]; then
		echo "true"
	else
		echo "false"
	fi
}
