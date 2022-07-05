#!/bin/bash

installBinUp() {
	mkdir -p "${toolsPath}binupdate/"
	rsync -avhp "$HOME/dragoonDoriseTools/EmuDeck/tools/binupdate/" "${toolsPath}binupdate/"

	rm -rf "$HOME/Desktop/EmuDeckBinUpdate.desktop" 2>/dev/null
	echo "#!/usr/bin/env xdg-open
	[Desktop Entry]
	Name=EmuDeck Tool Updater
	Exec=bash ${toolsPath}binupdate/binupdate.sh
	Icon=steamdeck-gaming-return
	Terminal=true
	Type=Application
	StartupNotify=false" >"$HOME/Desktop/EmuDeckBinUpdate.desktop"
	chmod +x "$HOME/Desktop/EmuDeckBinUpdate.desktop"
	chmod +x "${toolsPath}binupdate/binupdate.sh"
	#update the paths in the script
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" "${toolsPath}binupdate/binupdate.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools/|${toolsPath}|g" "${toolsPath}binupdate/binupdate.sh"
}
