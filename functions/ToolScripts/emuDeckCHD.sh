#!/bin/bash

CHD_toolName="EmuDeck Compression Tool"
CHD_toolType="script"
CHD_toolPath="${toolsPath}/chdconv/chddeck.sh"

CHD_install(){		
	
	rsync -avhp --mkpath "$EMUDECKGIT/tools/chdconv" "$toolsPath"

	chmod +x "$CHD_toolPath"
	chmod +x "$toolsPath"chdconv/chdman5

	#update the paths in the script
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|g" "$CHD_toolPath"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools/|${toolsPath}|g" "$CHD_toolPath"	

	CHD_createDesktopShortcut
}



CHD_createDesktopShortcut(){

	CHD_Shortcutlocation=$1

	if [[ "$CHD_Shortcutlocation" == "" ]]; then

		CHD_Shortcutlocation="$HOME/Desktop/EmuDeckCHD_desktop"

	fi

	echo "#!/usr/bin/env xdg-open
	[Desktop Entry]
	Name="$CHD_toolName"
	Exec=bash "$CHD_toolPath"
	Icon=steamdeck-gaming-return
	Terminal=true
	Type=Application
	StartupNotify=false" > $CHD_Shortcutlocation
	chmod +x $CHD_Shortcutlocation
}