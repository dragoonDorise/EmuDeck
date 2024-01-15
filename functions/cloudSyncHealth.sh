#!/bin/bash
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

	#Check installation
	if [ ! -f "$cloud_sync_bin" ]; then
  		echo "<strong>Error: No executable found. Please reinstall</strong>"
  		exit
	else
		echo "Executable Status: <strong>Correct</strong>"
	fi

	if [ ! -f "$cloud_sync_config" ]; then
  		echo "<strong>Error: No config file found. Please reinstall</strong>"
  		exit
	else
		echo "Config file Status: <strong>Correct</strong>"
	if
	if [ $cloud_sync_provider = '' ]; then
  		echo "<strong>Error: No provider found. Please reinstall</strong>"
  		exit
	else
		echo "Provider set up: <strong>Correct</strong>"
	fi

	#Test emulators
	miArray=("Cemu" "citra" "dolphin" "duckstation" "MAME" "melonds" "mgba" "pcsx2" "ppsspp" "primehack" "retroarch" "rpcs3" "scummvm" "Vita3K" "yuzu" "ryujinx" )

#	echo -e "<span class=\"yellow\">Testing uploading</span>"
	for elemento in "${miArray[@]}"; do
#		echo -ne "Testing $elemento upload..."
		if cloud_sync_upload_test $elemento;then
			echo "$elemento upload Status: <strong>Success</strong>"
		elif [ $? = 2 ]; then
			echo "Warning: $elemento, save folder not found"
		else
			echo "<strong>Error: Testing $elemento upload</strong>"
			exit
		fi
	done

#	echo -e "<span class=\"yellow\">Testing downloading</span>"
	for elemento in "${miArray[@]}"; do
#		echo -ne "Testing $elemento download..."
		if cloud_sync_dowload_test $elemento;then
			echo "$elemento download Status: <strong>Success</strong>"
		elif [ $? = 2 ]; then
			echo "Warning: $elemento, save folder not found"
		else
			echo "<strong>Error: Testing $elemento download</strong>"
			exit
		fi
	done

	echo "true"
}