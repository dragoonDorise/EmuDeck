#!/bin/bash
createDesktopIcons(){		
	
	#We delete the old icons
	rm -rf ~/Desktop/EmuDeckUninstall.desktop 2>/dev/null	
	rm -rf ~/Desktop/EmuDeckCHD.desktop 2>/dev/null
	rm -rf ~/Desktop/EmuDeck.desktop 2>/dev/null
	rm -rf ~/Desktop/EmuDeckSD.desktop 2>/dev/null
	rm -rf ~/Desktop/EmuDeckBinUpdate 2>/dev/null

	#Legacy Icon, just in case
	echo "#!/usr/bin/env xdg-open
	[Desktop Entry]
	Name=EmuDeck (Legacy)
	Exec=curl https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh | bash -s #-- SD
	Icon=steamdeck-gaming-return
	Terminal=true
	Type=Application
	StartupNotify=false" > ~/Desktop/EmuDeck.desktop
	chmod +x ~/Desktop/EmuDeck.desktop
	
	#New EmuDeck icon, same place so people won't get confused
	 echo "#!/usr/bin/env xdg-open
	 [Desktop Entry]
	 Name=EmuDeck
	 Exec=$HOME/Applications/EmuDeck.AppImage
	 Icon=steamdeck-gaming-return
	 Terminal=false
	 Type=Application
	 StartupNotify=false" > ~/Desktop/EmuDeckAppImage.desktop
	 chmod +x ~/Desktop/EmuDeckAppImage.desktop
	
}
