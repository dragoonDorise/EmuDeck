#!/bin/bash

SAVESYNC_toolName="EmuDeck SaveSync"
SAVESYNC_toolType="AppImage"
SAVESYNC_toolPath="${toolsPath}/savesync/EmuDeck_SaveSync.AppImage"
SAVESYNC_url="https://nightly.link/withertech/savesync/actions/runs/2517254418/EmuDeck-SaveSync-AppImage.zip"
#SAVESYNC_Shortcutlocation="$HOME/Desktop/EmuDeckBinUpdate.desktop"



SAVESYNC_install(){		
	

    curl -L "$SAVESYNC_url" --output "${toolsPath}/savesync/savesync.zip"

    unzip -j "${toolsPath}/savesync/savesync.zip" && rm "${toolsPath}/savesync/savesync.zip"

	chmod +x "$SAVESYNC_toolPath"

}

SAVESYNC_setup(){
    "$SAVESYNC_toolPath" "$emulationPath" --setup gdrive
}

