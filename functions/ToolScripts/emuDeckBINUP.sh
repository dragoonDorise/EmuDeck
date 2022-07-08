#!/bin/bash

BINUP_toolName="EmuDeck Tool Updater"
BINUP_toolType="script"
BINUP_toolPath="${toolsPath}binupdate/binupdate.sh"



BINUP.install(){		
	
	rsync -avhp --mkpath "$EMUDECKGIT/tools/binupdate" "$toolsPath"

	chmod +x "$BINUP_toolPath"
	#update the paths in the script
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" "$BINUP_toolPath"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools/|${toolsPath}|g" "$BINUP_toolPath"	

	BINUP.createDesktopShortcut
}



BINUP.createDesktopShortcut(){

	BINUP_Shortcutlocation=$1

	if [[ "$BINUP_Shortcutlocation" == "" ]]; then

		BINUP_Shortcutlocation="$HOME/Desktop/SteamRomManager.desktop"
	

	fi

	echo "#!/usr/bin/env xdg-open
	[Desktop Entry]
	Name="$BINUP_toolName"
	Exec=bash "$BINUP_toolPath"
	Icon=steamdeck-gaming-return
	Terminal=true
	Type=Application
	StartupNotify=false" > $BINUP_Shortcutlocation
	chmod +x $BINUP_Shortcutlocation
}

