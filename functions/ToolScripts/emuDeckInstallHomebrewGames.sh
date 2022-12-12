#!/bin/bash
emuDeckInstallHomebrewGames(){
	setMSG "Installing HomeBrew Games"		
	mkdir -p "$toolsPath/homebrew/roms/"
	git clone https://github.com/EmuDeck/emudeck-homebrew.git "$toolsPath/homebrew/roms/" --depth=1
	cd "$toolsPath/homebrew/roms/" && git reset --hard HEAD && git clean -f -d && git pull && echo  "Homebrew Games up to date!" || echo "problem pulling Homebrew Games"
	
	#Symlinks
	
	ln -sn "$toolsPath/homebrew/roms/gamegear"  ${romsPath}/gamegear/homebrew/
	ln -sn "$toolsPath/homebrew/roms/gb"  ${romsPath}/gb/homebrew/
	ln -sn "$toolsPath/homebrew/roms/gba"  ${romsPath}/gba/homebrew/
	ln -sn "$toolsPath/homebrew/roms/gbc"  ${romsPath}/gbc/homebrew/
	ln -sn "$toolsPath/homebrew/roms/genesis"  ${romsPath}/genesis/homebrew/
	ln -sn "$toolsPath/homebrew/roms/mastersystem"  ${romsPath}/mastersystem/homebrew/
	ln -sn "$toolsPath/homebrew/roms/nes"  ${romsPath}/nes/homebrew/
	ln -sn "$toolsPath/homebrew/roms/snes"  ${romsPath}/snes/homebrew/
}