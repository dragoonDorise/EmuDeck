#!/bin/bash
createDesktopIcons(){
	local sandbox=""
	local envPrefix=""
	local desktop=$(xdg-user-dir DESKTOP)
	if command -v apt-get >/dev/null; then
		sandbox=" --no-sandbox"
	fi

	# Armada / ARM fix
	if [ ! -e /usr/lib64/libz.so ] && [ -e "$HOME/.local/lib/libz.so" ]; then
		envPrefix="env LD_LIBRARY_PATH=$HOME/.local/lib:\$LD_LIBRARY_PATH "
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
	"${envPrefix}$emusFolder/EmuDeck.AppImage$sandbox" \
	"false"
	 #App list
	 createDesktopShortcut "$HOME/.local/share/applications/EmuDeck.desktop" \
	 "EmuDeck" \
	 "${envPrefix}$emusFolder/EmuDeck.AppImage$sandbox" \
	 "false"
}
