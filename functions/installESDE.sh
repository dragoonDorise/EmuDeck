#!/bin/bash
installESDE(){		
	
	setMSG "${installString} EmulationStation Desktop Edition"
	curl https://gitlab.com/leonstyhre/emulationstation-de/-/raw/master/es-app/assets/latest_steam_deck_appimage.txt --output "$toolsPath"/latesturl.txt 
	latestURL=$(grep "https://gitlab" "$toolsPath"/latesturl.txt)
	
	#New repo if the other fails
	if [ -z $latestURL ]; then
		curl https://gitlab.com/es-de/emulationstation-de/-/raw/master/es-app/assets/latest_steam_deck_appimage.txt --output "$toolsPath"/latesturl.txt 
		latestURL=$(grep "https://gitlab" "$toolsPath"/latesturl.txt)
	fi
		curl $latestURL --output "$toolsPath"/EmulationStation-DE-x64_SteamDeck.AppImage 
		rm "$toolsPath"/latesturl.txt
		chmod +x "$toolsPath"/EmulationStation-DE-x64_SteamDeck.AppImage	
	
}