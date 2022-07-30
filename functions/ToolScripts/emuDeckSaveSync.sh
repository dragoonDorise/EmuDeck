#!/bin/bash

SAVESYNC_toolName="EmuDeck SaveSync"
SAVESYNC_toolType="AppImage"
SAVESYNC_toolPath="${toolsPath}/savesync/EmuDeck_SaveSync.AppImage"
SAVESYNC_url="https://nightly.link/withertech/savesync/actions/runs/2517254418/EmuDeck-SaveSync-AppImage.zip"
SAVESYNC_systemd_path="$HOME/.config/systemd/user"
#SAVESYNC_Shortcutlocation="$HOME/Desktop/EmuDeckBinUpdate.desktop"



SAVESYNC_install(){		
	rm "${toolsPath}/savesync/EmuDeck_SaveSync-0.0.1-x86_64.AppImage"
    curl -L "$SAVESYNC_url" --output "${toolsPath}/savesync/savesync.zip"
    unzip -j "${toolsPath}/savesync/savesync.zip" && rm "${toolsPath}/savesync/savesync.zip"
    mv "${toolsPath}/savesync/EmuDeck_SaveSync-0.0.1-x86_64.AppImage" "$SAVESYNC_toolPath"
	chmod +x "$SAVESYNC_toolPath"

}

SAVESYNC_setup(){
    systemctl --user stop emudeck_savesync.service
    mv "${toolsPath}/savesync/config.yml" "${toolsPath}/savesync/config.yml.bak"
    mv "$HOME/.config/rclone/rclone.conf"  "$HOME/.config/rclone/rclone.conf.bak"

    "$SAVESYNC_toolPath" "$emulationPath" --setup $cloudProvider

    mkdir -p "$SAVESYNC_systemd_path"
    echo \
    "[Unit]
    Description=Emudeck SaveSync service

    [Service]
    Type=simple
    Restart=always
    RestartSec=1
    ExecStart=$SAVESYNC_toolPath --sync

    [Install]
    WantedBy=default.target" > "$SAVESYNC_systemd_path/emudeck_savesync.service"
    chmod +x "$SAVESYNC_systemd_path/emudeck_savesync.service"

    echo "Setting SaveSync service to start on boot"
    systemctl --user enable emudeck_savesync.service

    echo "Starting SaveSync Service. First run may take a while."
    systemctl --user start emudeck_savesync.service
}

