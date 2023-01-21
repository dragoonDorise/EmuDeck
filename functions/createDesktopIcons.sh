#!/bin/bash
createDesktopIcons(){		
	
	#We delete the old icons
	rm -rf ~/Desktop/EmuDeckUninstall.desktop 2>/dev/null	
	rm -rf ~/Desktop/EmuDeckCHD.desktop 2>/dev/null
	rm -rf ~/Desktop/EmuDeck.desktop 2>/dev/null
	rm -rf ~/Desktop/EmuDeckSD.desktop 2>/dev/null
	rm -rf ~/Desktop/EmuDeckBinUpdate.desktop 2>/dev/null
	rm -rf ~/Desktop/EmuDeckApp.desktop 2>/dev/null
	rm -rf ~/Desktop/EmuDeckAppImage.desktop 2>/dev/null
	rm -rf ~/Desktop/EmuDeckAppImage.desktop 2>/dev/null

	#New EmuDeck icon, same place so people won't get confused
	createDesktopShortcut "$HOME/Desktop/EmuDeck.desktop" \
	"EmuDeck" \
	"$HOME/Applications/EmuDeck.AppImage" \
	"false"
	 #App list	 
	 #desktop-file-install --dir --delete-original "$HOME/Desktop/EmuDeck.desktop"	  
	 createDesktopShortcut "$HOME/.local/share/applications/EmuDeck.desktop" \
	 "EmuDeck" \
	 "$HOME/Applications/EmuDeck.AppImage" \
	 "false"
	 
}
