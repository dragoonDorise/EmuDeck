#!/bin/bash
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
CYAN='\033[01;36m'
cloud_sync_upload_test(){
	local emuName=$1

	if [ ! -d $savesPath/$emuName ];then
		return 2
	fi

	echo "test" > "$savesPath/$emuName/.temp"
	filePath="$savesPath/$emuName/.temp"
	"$cloud_sync_bin"  -q  copyto --fast-list --checkers=50 --transfers=50 --low-level-retries 1 --retries 1 "$filePath" "$cloud_sync_provider":Emudeck/saves/$emuName/.temp  && rm -rf "$savesPath/$emuName/.temp" && return 0 || return 1
}

cloud_sync_dowload_test(){
	local emuName=$1

	if [ ! -d $savesPath/$emuName ];then
		return 2
	fi

	echo "test" > "$savesPath/$emuName/.temp"
	filePath="$savesPath/$emuName/.temp"
	"$cloud_sync_bin"  -q  copyto --fast-list --checkers=50 --transfers=50 --low-level-retries 1 --retries 1 "$cloud_sync_provider":Emudeck/saves/$emuName/.temp "$filePath" && rm -rf "$savesPath/$emuName/.temp" && return 0 || return 1

}

cloudSyncHealth(){

	echo -e "<span class=\"cyan\">CloudSync Status Report</span>"
	echo ""

	miArray=("Cemu" "citra" "dolphin" "duckstation" "MAME" "melonds" "mgba" "pcsx2" "ppsspp" "primehack" "retroarch" "rpcs3" "scummvm" "Vita3K" "yuzu" "ryujinx" )

	upload="true"
	download="true"
	launchers="true"
	echo -e "<span class=\"yellow\">Checking launchers</span>"
	for entry in "$toolsPath/launchers/"*.sh
	do
		if [ -f "$entry" ]; then
			if grep -q "cloud_sync_startService" $entry; then
				echo -e "$entry: <span class=\"green\">Success</span>"
			else
				echo -e "$entry: <span class=\"red\">Failure</span>"
				launchers="false"
			fi
		fi
	done

	if grep -q "cloud_sync_startService" "$toolsPath/launchers/esde/emulationstationde.sh"; then
		echo -e "$toolsPath/launchers/esde/emulationstationde.sh: <span class=\"green\">Success</span>"
	else
		echo -e "$toolsPath/launchers/esde/emulationstationde.sh: <span class=\"red\">Failure</span>"
	fi

	found_files="false"
	echo -e "<span class=\"yellow\">Checking for Windows old .lnk files</span>"
	find "$savesPath" -type f -name "*.lnk" | while read -r entry
	do
		rm -rf $entry
		echo "found and deleted: $entry"
		found_files="true"
	done

	if [ "$found_files" = "false" ]; then
		echo "No files with the '.lnk' extension found."
	fi

	echo -e ""
	echo -e "<span class=\"yellow\">Testing uploading</span>"
	# Recorrer el array y ejecutar la función cloud_sync_upload_test para cada elemento
	for elemento in "${miArray[@]}"; do
		echo -ne "Testing $elemento upload..."
		if cloud_sync_upload_test $elemento;then
			echo -e "<span class=\"green\">Success</span>"
		elif [ $? = 2 ]; then
			echo -e "<span class=\"yellow\">Save folder not found</span>"
		else
			echo -e "<span class=\"red\">Failure</span>"
			upload="false"
		fi
	done
	echo ""
	echo -e "<span class=\"yellow\">Testing downloading</span>"
	# Recorrer el array y ejecutar la función cloud_sync_upload_test para cada elemento
	for elemento in "${miArray[@]}"; do
		echo -ne "Testing $elemento download..."
		if cloud_sync_dowload_test $elemento;then
			echo -e "<span class=\"green\">Success</span>"
		elif [ $? = 2 ]; then
			echo -e "<span class=\"yellow\">Save folder not found</span>"
		else
			echo -e "<span class=\"red\">Failure</span>"
			download="false"
		fi
	done
	echo -e ""
	echo -e "<span class=\"cyan\">Recommendations</span>"



	if [ $download = "true" ] && [ $upload = "true" ] && [ $launchers = "true" ]; then
		echo -e "<span class=\"yellow\">Everything seems to be in proper order, at least on Linux</span>"
	else
		echo -e "<span class=\"yellow\">Open EmuDeck, go to Manage Emulators and reset SteamRomManager Configuration. Then test some games and if it keeps failing open Steam Rom Manager and parse all your games again to get the proper launchers</span>"
	fi
}