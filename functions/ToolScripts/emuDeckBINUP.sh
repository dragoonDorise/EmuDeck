#!/bin/bash

BINUP_toolName="EmuDeck AppImage Updater"
BINUP_toolType="script"
BINUP_toolPath="${toolsPath}/binupdate/binupdate.sh"
BINUP_Shortcutlocation="$HOME/Desktop/EmuDeckBinUpdate.desktop"



BINUP_install(){

	rsync -avhp --mkpath "$EMUDECKGIT/tools/binupdate" "$toolsPath/"

	chmod +x "$BINUP_toolPath"
	#update the paths in the script
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|g" "$BINUP_toolPath"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "$BINUP_toolPath"

	#createDesktopShortcut "$BINUP_Shortcutlocation" "$BINUP_toolName" "bash $BINUP_toolPath"  "True"
}
