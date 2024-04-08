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
	echo "<table class='table'>"
		echo "<tr>"
	#Check installation
	if [ ! -f "$cloud_sync_bin" ]; then
  		echo "<td>Executable Status: </td><td class='alert--danger'><strong>Failure, please reinstall</strong></td></tr></table>"
  		exit
	else
		echo "<td>Executable Status: </td><td class='alert--success'><strong>Success</strong></td>"
	fi
	echo "</tr><tr>"
	if [ ! -f "$cloud_sync_config" ]; then
  		echo "<td>Config file Status: </td><td class='alert--danger'><strong>Failure, please reinstall</strong></td></tr></table>"
  		exit
	else
		echo "<td>Config file Status: </td><td class='alert--success'><strong>Success</strong></td>"
	fi
	echo "</tr><tr>"
	if [ $cloud_sync_provider = '' ]; then
  		echo "<td>Provider Status: </td><td class='alert--danger'><strong>Failure, please reinstall</strong></td></tr></tr></table>"
  		exit
	else
		echo "<td>Provider Status: </td><td class='alert--success'><strong>Success</strong></td>"
	fi
	echo "</tr><tr>"
	if [ ! -d "$HOME/homebrew/plugins/EmuDecky" ]; then
		  echo "<td>EmuDecky Status: </td><td class='alert--danger'><strong>Failure, please install EmuDecky</strong></td></tr></tr></table>" >&2
		  return 1
	else
		echo "<td>EmuDecky Status: </td><td class='alert--success'><strong>Success</strong></td>"
	fi
	echo "</tr><tr>"
	if [ ! -f "$HOME/.config/systemd/user/EmuDeckCloudSync.service" ]; then
		  echo "<td>Watcher Status: </td><td class='alert--danger'><strong>Failure, please reinstall</strong></td></tr></table>"
		  exit
	else
		echo "<td>Watcher Status: </td><td class='alert--success'><strong>Success</strong></td>"
	fi
	echo "</tr>"


	$(systemctl --user status "EmuDeckCloudSync.service")
	echo "</tr>"



	#Test emulators
	miArray=("Cemu" "citra" "dolphin" "duckstation" "MAME" "melonds" "mgba" "pcsx2" "ppsspp" "primehack" "retroarch" "rpcs3" "scummvm" "Vita3K" "yuzu" "Ryujinx" "BigPEmu" )

#	echo -e "<span class=\"yellow\">Testing uploading</span>"
	for elemento in "${miArray[@]}"; do
#		echo -ne "Testing $elemento upload..."
		echo "<tr>"
		if cloud_sync_upload_test $elemento;then
			echo "<td>$elemento upload Status: </td><td class='alert--success'><strong>Success</strong></td>"
		elif [ $? = 2 ]; then
			echo "<td>$elemento, save folder </td><td class='alert--warning'>not found</td>"
		else
			echo "<td>$elemento upload Status: </td><td class='alert--danger'><strong>Failure</strong></td>"
			echo "</tr></tr></table>"
			exit
		fi
		echo "</tr>"
	done

#	echo -e "<span class=\"yellow\">Testing downloading</span>"
	for elemento in "${miArray[@]}"; do
		echo "<tr>"
		if cloud_sync_dowload_test $elemento;then
			echo "<td>$elemento download Status: </td><td class='alert--success'><strong>Success</strong></td>"
		elif [ $? = 2 ]; then
			echo "<td>$elemento, save folder </td><td class='alert--warning'>not found</td>"
		else
			echo "<td>$elemento download Status: </td><td class='alert--danger'><strong>Failure</strong></td>"
			echo "</tr></tr></table>"
			exit
		fi
		echo "</tr>"
	done
	echo "</table>"
	echo "<span class='is-hidden'>true</span>"
}