#!/bin/bash

SAVESYNC_toolName="EmuDeck SaveSync"
SAVESYNC_toolType="AppImage"
SAVESYNC_toolPath="$HOME/Applications/EmuDeck_SaveSync.AppImage"
SAVESYNC_systemd_path="$HOME/.config/systemd/user"
#SAVESYNC_Shortcutlocation="$HOME/Desktop/EmuDeckBinUpdate.desktop"



SAVESYNC_install(){	

	rm "$SAVESYNC_toolPath"
    curl -L "$(getReleaseURLGH "withertech/savesync" "AppImage")" --output "$SAVESYNC_toolPath"
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
        echo "pausing before creating service"
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
}