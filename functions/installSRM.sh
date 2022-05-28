#!/bin/bash
installSRM(){		
	setMSG "${installString} Steam Rom Manager"
	rm -f ~/Desktop/Steam-ROM-Manager-2.3.29.AppImage
	rm -f ~/Desktop/Steam-ROM-Manager.AppImage
	mkdir -p "${toolsPath}"/srm
	curl -L "$(curl -s https://api.github.com/repos/SteamGridDB/steam-rom-manager/releases/latest | grep -E 'browser_download_url.*AppImage' | grep -ve 'i386' | cut -d '"' -f 4)" > "${toolsPath}"srm/Steam-ROM-Manager.AppImage
	#Nova fix'
	echo "#!/usr/bin/env xdg-open
	[Desktop Entry]
	Name=Steam Rom Manager
	Exec=kill -9 `pidof steam` & ${toolsPath}srm/Steam-ROM-Manager.AppImage
	Icon=steamdeck-gaming-return
	Terminal=false
	Type=Application
	StartupNotify=false" > ~/Desktop/SteamRomManager.desktop
	chmod +x ~/Desktop/SteamRomManager.desktop
	chmod +x "${toolsPath}"/srm/Steam-ROM-Manager.AppImage	
}