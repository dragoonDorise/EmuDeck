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
  		echo "Error: No executable found. Please reinstall"
  		exit
	elif [ ! -f "$cloud_sync_config" ]; then
  		echo "Error: No config file found. Please reinstall"
  		exit
	elif [ $cloud_sync_provider = '' ]; then
  		echo "Error: No provider found. Please reinstall"
  		exit
	fi

	#Test emulators
	miArray=("Cemu" "citra" "dolphin" "duckstation" "MAME" "melonds" "mgba" "pcsx2" "ppsspp" "primehack" "retroarch" "rpcs3" "scummvm" "Vita3K" "yuzu" "ryujinx" )

#	echo -e "<span class=\"yellow\">Testing uploading</span>"
	for elemento in "${miArray[@]}"; do
#		echo -ne "Testing $elemento upload..."
		if cloud_sync_upload_test $elemento;then
			echo ""
		elif [ $? = 2 ]; then
			echo ""
			#echo "Error: Testing $elemento upload, save folder not found"
		else
			echo "Error: Testing $elemento upload"
			exit
		fi
	done

#	echo -e "<span class=\"yellow\">Testing downloading</span>"
	for elemento in "${miArray[@]}"; do
#		echo -ne "Testing $elemento download..."
		if cloud_sync_dowload_test $elemento;then
			echo ""
		elif [ $? = 2 ]; then
			echo ""
			#echo "Error: Testing $elemento download, save folder not found"
		else
			echo "Error: Testing $elemento download"
			exit
		fi
	done

	echo "true"
}