#!/bin/bash
SAVESYNC_toolName="EmuDeck SaveSync"
SAVESYNC_toolType="AppImage"
SAVESYNC_toolPath="$HOME/Applications/EmuDeck_SaveSync.AppImage"
SAVESYNC_systemd_path="$HOME/.config/systemd/user"

source "$HOME/.config/EmuDeck/backend/functions/all.sh"

SAVESYNC_install(){	
	
	text="`printf " <b>Have your login details ready!</b>\n\nA new browser windows will open for your cloud provider.\nMake sure you have your cretendials ready because you only have <b>20 seconds to enter them</b>. \n\n you can always reconfigure SaveSync in the future )"`"
	 zenity --info \
			 --title="EmuDeck" \
			 --width="450" \
			 --text="${text}" 2>/dev/null	
	
	
	rm "$SAVESYNC_toolPath"
	curl -L "$(getReleaseURLGH "EmuDeck/savesync" "AppImage")" --output "$SAVESYNC_toolPath"
	chmod +x "$SAVESYNC_toolPath"

}

#$1 = gdrive,dropbox,onedrive,box,nextcloud
SAVESYNC_setup(){
	local cloudProvider=$1
	if [[ -z "$cloudProvider" ]]; then
		echo "no cloud provider selected"
	else
		echo "cloud provider: $cloudProvider"
		systemctl --user stop emudeck_savesync.service

		mv "${toolsPath}/savesync/config.yml" "${toolsPath}/savesync/config.yml.bak"
		mv "$HOME/.config/rclone/rclone.conf"  "$HOME/.config/rclone/rclone.conf.bak"

		"$SAVESYNC_toolPath" "$emulationPath" --setup "$cloudProvider"
		echo "Creating service, please wait"
		sleep 20
		SAVESYNC_createService
	fi
}

SAVESYNC_createService(){
	echo "Creating SaveSync service"
	systemctl --user stop emudeck_savesync.service

	mkdir -p "$SAVESYNC_systemd_path"
	echo \
	"[Unit]
	Description=Emudeck SaveSync service

	[Service]
	Type=simple
	Restart=always
	RestartSec=1
	ExecStart=$SAVESYNC_toolPath --sync $emulationPath

	[Install]
	WantedBy=default.target" > "$SAVESYNC_systemd_path/emudeck_savesync.service"
	chmod +x "$SAVESYNC_systemd_path/emudeck_savesync.service"

	echo "Setting SaveSync service to start on boot"
	systemctl --user enable emudeck_savesync.service

	echo "Starting SaveSync Service. First run may take a while."
	systemctl --user start emudeck_savesync.service
	rm -rf $HOME/Desktop/EmuDeckSaveSync.desktop &>> /dev/null	
	zenity --info --width=400 --title="EmuDeck" --text="SaveSync configured!"
}

syncProvider=$(cat "$HOME/.config/EmuDeck/.cloudprovider")
		
if [[ -n "$syncProvider" ]]; then
	SAVESYNC_install
	SAVESYNC_setup "$syncProvider"
fi

