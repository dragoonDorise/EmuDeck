#!/bin/bash
installCHD(){		
	mkdir -p  "$toolsPath"chdconv/
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/tools/chdconv/ "$toolsPath"chdconv/ 
	
	rm -rf ~/Desktop/EmuDeckCHD.desktop 2>/dev/null
	echo "#!/usr/bin/env xdg-open
	[Desktop Entry]
	Name=EmuDeck CHD Script
	Exec=bash "$toolsPath"chdconv/chddeck.sh
	Icon=steamdeck-gaming-return
	Terminal=true
	Type=Application
	StartupNotify=false" > ~/Desktop/EmuDeckCHD.desktop
	chmod +x ~/Desktop/EmuDeckCHD.desktop	
	chmod +x "$toolsPath"chdconv/chddeck.sh
	chmod +x "$toolsPath"chdconv/chdman5
	#update the paths in the script
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" "$toolsPath"chdconv/chddeck.sh
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools/|${toolsPath}|g" "$toolsPath"chdconv/chddeck.sh	
}