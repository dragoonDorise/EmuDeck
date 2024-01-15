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
	echo "<table>"
		echo "<tr>"
	#Check installation
	if [ ! -f "$cloud_sync_bin" ]; then
  		echo "<td>Executable Status: <strong class='alert--danger'>Failure, please reinstall</strong></td>"
  		exit
	else
		echo "<td>Executable Status: <strong class='alert--success'>Success</strong></td>"
	fi
	echo "</tr><tr>"
	if [ ! -f "$cloud_sync_config" ]; then
  		echo "<td>Config file Status: <strong class='alert--danger'>Failure, please reinstall</strong></td>"
  		exit
	else
		echo "<td>Config file Status: <strong class='alert--success'>Success</strong></td>"
	fi
	echo "</tr><tr>"
	if [ $cloud_sync_provider = '' ]; then
  		echo "<td>Provider Status: <strong class='alert--danger'>Failure, please reinstall</strong></td>"
  		exit
	else
		echo "<td>Provider Status: <strong class='alert--success'>Success</strong></td>"
	fi
	echo "</tr>"
	#Test emulators
	miArray=("Cemu" "citra" "dolphin" "duckstation" "MAME" "melonds" "mgba" "pcsx2" "ppsspp" "primehack" "retroarch" "rpcs3" "scummvm" "Vita3K" "yuzu" "ryujinx" )

#	echo -e "<span class=\"yellow\">Testing uploading</span>"
	for elemento in "${miArray[@]}"; do
#		echo -ne "Testing $elemento upload..."
		echo "<tr>"
		if cloud_sync_upload_test $elemento;then
			echo "<td>$elemento upload Status: <strong class='alert--success'>Success</strong></td>"
		elif [ $? = 2 ]; then
			echo "<td>Warning: $elemento, save folder not found"
		else
			echo "<td>$elemento upload Status: <strong class='alert--danger'>Failure</strong></td>"
			echo "</tr>"
			exit
		fi
		echo "</tr>"
	done

#	echo -e "<span class=\"yellow\">Testing downloading</span>"
	for elemento in "${miArray[@]}"; do
		echo "<tr>"
		if cloud_sync_dowload_test $elemento;then
			echo "<td>$elemento download Status: <strong class='alert--success'>Success</strong></td>"
		elif [ $? = 2 ]; then
			echo "<td>Warning: $elemento, save folder not found"
		else
			echo "<td>$elemento download Status: <strong class='alert--danger'>Failure</strong></td>"
			echo "</tr>"
			exit
		fi
		echo "</tr>"
	done
	echo "</table>"
	echo "true"
}