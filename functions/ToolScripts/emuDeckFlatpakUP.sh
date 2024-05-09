#!/bin/bash

FlatpakUP_toolName="EmuDeck Flatpak Updater"
FlatpakUP_toolType="script"
FlatpakUP_toolPath="${toolsPath}/flatpakupdate/flatpakupdate.sh"



FlatpakUp_install(){

	rsync -avhp --mkpath "$EMUDECKGIT/tools/flatpakupdate" "$toolsPath/"

	chmod +x "$FlatpakUP_toolPath"
	#update the paths in the script
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|g" "$FlatpakUP_toolPath"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "$FlatpakUP_toolPath"

	#createDesktopShortcut "$FlatpakUP_Shortcutlocation" "$FlatpakUP_toolName" "bash $FlatpakUP_toolPath"  "True"
}
