#!/bin/bash
createDesktopIcons(){		
	
	#We create new icons
	rm -rf ~/Desktop/EmuDeckUninstall.desktop 2>/dev/null
	echo '#!/usr/bin/env xdg-open
	[Desktop Entry]
	Name=Uninstall EmuDeck
	Exec=curl https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/uninstall.sh | bash -s -- SD
	Icon=delete
	Terminal=true
	Type=Application
	StartupNotify=false' > ~/Desktop/EmuDeckUninstall.desktop
	chmod +x ~/Desktop/EmuDeckUninstall.desktop
	
	rm -rf ~/Desktop/EmuDeck.desktop 2>/dev/null
	rm -rf ~/Desktop/EmuDeckSD.desktop 2>/dev/null
	echo "#!/usr/bin/env xdg-open
	[Desktop Entry]
	Name=EmuDeck (${version})
	Exec=curl https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh | bash -s -- SD
	Icon=steamdeck-gaming-return
	Terminal=true
	Type=Application
	StartupNotify=false" > ~/Desktop/EmuDeck.desktop
	chmod +x ~/Desktop/EmuDeck.desktop
}