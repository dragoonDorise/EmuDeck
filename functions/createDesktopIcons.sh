#!/bin/bash
createDesktopIcons(){		
	
	#We delete the old icons
	rm -rf ~/Desktop/EmuDeckUninstall.desktop 2>/dev/null	
	rm -rf ~/Desktop/EmuDeckCHD.desktop 2>/dev/null
	rm -rf ~/Desktop/EmuDeck.desktop 2>/dev/null
	rm -rf ~/Desktop/EmuDeckSD.desktop 2>/dev/null
	rm -rf ~/Desktop/EmuDeckBinUpdate 2>/dev/null
	rm -rf ~/Desktop/EmuDeckApp.desktop 2>/dev/null
	rm -rf ~/Desktop/EmuDeckAppImage.desktop 2>/dev/null

	#New EmuDeck icon, same place so people won't get confused
	 echo "#!/usr/bin/env xdg-open
	 [Desktop Entry]
	 Name=EmuDeck
	 Exec=$HOME/Applications/EmuDeck.AppImage
	 Icon=steamdeck-gaming-return
	 Terminal=false
	 Type=Application
	 StartupNotify=false" > ~/Desktop/EmuDeck.desktop
	 chmod +x ~/Desktop/EmuDeck.desktop
	 
	 echo "#!/usr/bin/env xdg-open
	  [Desktop Entry]
	  Name=EmuDeck
	  Exec=$HOME/Applications/EmuDeck.AppImage
	  Icon=steamdeck-gaming-return
	  Terminal=false
	  Type=Application
	  Categories=Game
	  StartupNotify=false" > $HOME/.local/share/applications/EmuDeck.desktop
	  chmod +x $HOME/.local/share/applications/EmuDeck.desktop	
	
}
