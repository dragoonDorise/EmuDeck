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
	echo "testing upload" > "$savesPath/retroarch/test_emudeck.txt"
	local watcherStatus=1
	local upload=1
	local download=1

	touch "$HOME/emudeck/logs/cloudHealth.log"

{
	cloud_sync_stopService

	#We start the service and check if it works

	if [ $(check_internet_connection) == "true" ]; then

		#Change path to a new test place
		echo "internet ok"

	else
		text="$(printf "<b>CloudSync Error.</b>\nInternet connection not available.")"
		zenity --error \
		--title="EmuDeck" \
		--width=400 \
		--text="${text}" 2>/dev/null
		exit
	fi


	#Zenity asking SRM or ESDE
	#Opening RA/ESDE in background
	kill="ESDE"
	zenity --question --title "CloudSync Health" --text "Do you launch your games using EmulationStation?" --cancel-label "No" --ok-label "Yes"

	if [ $? = 0 ]; then
		notify-send "ESDE" --icon="$HOME/.local/share/icons/emudeck/EmuDeck.png" --app-name "EmuDeck CloudSync"
		touch "$savesPath/.gaming"
		touch "$savesPath/.watching"
		echo "all" > "$savesPath/.emuName"
		cloud_sync_startService

		systemctl --user is-active --quiet "EmuDeckCloudSync.service"
		status=$?

		if [ $status -eq 0 ]; then
			echo "CloudSync Service running"
			watcherStatus=0
		else
			text="$(printf "<b>CloudSync Error.</b>\nCloudSync service is not running. Please reinstall CloudSync and try again")"
			zenity --error \
			--title="EmuDeck" \
			--width=400 \
			--text="${text}" 2>/dev/null
		fi

		"$ESDE_toolPath" & xdotool search --sync --onlyvisible --name '^ES-DE$' windowminimize
	else
		kill="RETROARCH"
		notify-send "RETROARCH" --icon="$HOME/.local/share/icons/emudeck/EmuDeck.png" --app-name "EmuDeck CloudSync"
		touch "$savesPath/.gaming"
		touch "$savesPath/.watching"
		echo "retroarch" > "$savesPath/.emuName"
		cloud_sync_startService

		systemctl --user is-active --quiet "EmuDeckCloudSync.service"
		status=$?

		if [ $status -eq 0 ]; then
			echo "CloudSync Service running"
			watcherStatus=0
		else
			text="$(printf "<b>CloudSync Error.</b>\nCloudSync service is not running. Please reinstall CloudSync and try again")"
			zenity --error \
			--title="EmuDeck" \
			--width=400 \
			--text="${text}" 2>/dev/null
		fi

		/usr/bin/flatpak run org.libretro.RetroArch & xdotool search --sync --name '^RetroArch$' windowminimize
	fi


	#
	#Testing Upload
	#

	#Creating new file
	echo "Creating test file"
	sleep 2
	echo "testing upload" > "$savesPath/retroarch/test_emudeck.txt"


	#Upload should be happenning now in the background...

	while pgrep -x "rclone" > /dev/null; do
		echo "Waiting for cloudsync to finish..."
		sleep 5
	done


	#"$cloud_sync_bin"  --progress copyto -L --fast-list --checkers=50 --transfers=50 --low-level-retries 1 --retries 1 "$savesPath/test_emudeck.txt" "$cloud_sync_provider":Emudeck/saves/.test_emudeck.txt

	#Check if the file exists in the cloud
	"$cloud_sync_bin" lsf "$cloud_sync_provider":Emudeck/saves/retroarch/ | grep test_emudeck.txt
	status=$?

	# Evaluar el código de salida
	if [ $status -eq 0 ]; then
		echo "file exists in the cloud. SUCCESS"
		upload=0
	else
		echo "file does not exist in the cloud. FAIL"
	fi
	#Delete local test file
	rm -rf "$savesPath/retroarch/test_emudeck.txt"


	#
	##Testing Dowmload
	#

	#Downloading
	"$cloud_sync_bin"  --progress copyto -L --fast-list --checkers=50 --transfers=50 --low-level-retries 1 --retries 1 "$cloud_sync_provider":Emudeck/saves/retroarch/test_emudeck.txt "$savesPath/retroarch/test_emudeck.txt"

	#Check if the file exists.

	if [ -f "$savesPath/retroarch/test_emudeck.txt" ]; then
		echo "file exists in local. SUCCESS"
		download=0
	else
		echo "file does not exist in local. FAIL"
	fi

	#Ending, closing loose ends
	rm -rf "$savesPath/.gaming"
	rm -rf "$savesPath/.watching"
	rm -rf "$savesPath/.emuName"
	rm -rf "$savesPath/retroarch/test_emudeck.txt"
	#Delete remote test file
	"$cloud_sync_bin" delete "$cloud_sync_provider":Emudeck/saves/retroarch/test_emudeck.txt

	if [ $kill == "RETROARCH" ];then
		killall retroarch
	else
		xdotool search --sync --name '^ES-DE$' windowquit
	fi


} > "$HOME/emudeck/logs/cloudHealth.log"

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
		echo "<td>Watcher Status: </td><td class='alert--success'><strong>Installed</strong></td>"
	fi
	echo "</tr><tr>"

	if [ $watcherStatus -eq 0 ]; then
		echo "<td>CloudSync Service: </td><td class='alert--success'><strong>Running</strong></td>"
	else
		echo "<td>CloudSync Service: </td><td class='alert--success'><strong>Not running</strong></td>"
		text="$(printf "<b>CloudSync Service.</b>\n CloudSync service was not detected. Please contact us on Patreon")"
		zenity --error \
		--title="EmuDeck" \
		--width=400 \
		--text="${text}" 2>/dev/null
	fi
	echo "</tr>"

	# Tests upload
	echo "<tr>"
	if [ $upload -eq 0 ]; then
		echo "<td>Upload Status: </td><td class='alert--success'><strong>Success</strong></td>"
	elif [ $? = 2 ]; then
		echo "<td>Save folder </td><td class='alert--warning'>not found</td>"
	else
		echo "<td>Upload Status: </td><td class='alert--danger'><strong>Failure</strong></td>"
		echo "</tr></tr></table>"
	fi
	echo "</tr>"

	# Tests download
	echo "<tr>"
	if [ $download -eq 0 ]; then
		echo "<td>Download Status: </td><td class='alert--success'><strong>Success</strong></td>"
	elif [ $? = 2 ]; then
		echo "<td>Save folder </td><td class='alert--warning'>not found</td>"
	else
		echo "<td>Download Status: </td><td class='alert--danger'><strong>Failure</strong></td>"
		echo "</tr></tr></table>"
	fi
	echo "</tr>"

	echo "</table>"
	echo "<span class='is-hidden'>true</span>"
	cloud_sync_stopService
}