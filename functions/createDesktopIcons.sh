#!/bin/bash
createDesktopIcons(){
	local sandbox=""
	local desktop=$(xdg-user-dir DESKTOP)
	if command -v apt-get >/dev/null; then
		sandbox=" --no-sandbox"
	fi

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
	createDesktopShortcut "$desktop/EmuDeck.desktop" \
	"EmuDeck" \
	"$HOME/Applications/EmuDeck.AppImage$sandbox" \
	"false"
	 #App list
	 #desktop-file-install --dir --delete-original "$HOME/Desktop/EmuDeck.desktop"
	 createDesktopShortcut "$HOME/.local/share/applications/EmuDeck.desktop" \
	 "EmuDeck" \
	 "$HOME/Applications/EmuDeck.AppImage$sandbox" \
	 "false"

}
