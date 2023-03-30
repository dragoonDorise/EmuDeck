#!/bin/bash
emuDeckInstallHomebrewGames(){
	setMSG "Installing HomeBrew Games"		
	mkdir -p "$toolsPath/homebrew/roms/"
	mkdir -p "$toolsPath/downloaded_media/"
	git clone https://github.com/EmuDeck/emudeck-homebrew.git "$toolsPath/homebrew/roms/" --depth=1
	cd "$toolsPath/homebrew/roms/" && git reset --hard HEAD && git clean -f -d && git pull && echo  "Homebrew Games up to date!" || echo "problem pulling Homebrew Games"
	
	#Symlinks	
	ln -sn "$toolsPath/homebrew/roms/gamegear"  "${romsPath}/gamegear/homebrew"
	ln -sn "$toolsPath/homebrew/roms/gb"  "${romsPath}/gb/homebrew"
	ln -sn "$toolsPath/homebrew/roms/gba"  "${romsPath}/gba/homebrew"
	ln -sn "$toolsPath/homebrew/roms/gbc"  "${romsPath}/gbc/homebrew"
	ln -sn "$toolsPath/homebrew/roms/genesis"  "${romsPath}/genesis/homebrew"
	ln -sn "$toolsPath/homebrew/roms/mastersystem"  "${romsPath}/mastersystem/homebrew"
	ln -sn "$toolsPath/homebrew/roms/nes"  "${romsPath}/nes/homebrew"
	ln -sn "$toolsPath/homebrew/roms/snes" "${romsPath}/snes/homebrew"
	
	rsync -r --ignore-existing "${toolsPath}/homebrew/roms/downloaded_media/" "${toolsPath}/downloaded_media/" && rm -rf "${toolsPath}/homebrew/roms/downloaded_media/" && echo "true"
	
}

emuDeckUninstallHomebrewGames(){	
	#Symlinks	
	unlink "${romsPath}/gamegear/homebrew"
	unlink "${romsPath}/gb/homebrew"
	unlink "${romsPath}/gba/homebrew"
	unlink "${romsPath}/gbc/homebrew"
	unlink "${romsPath}/genesis/homebrew"
	unlink "${romsPath}/mastersystem/homebrew"
	unlink "${romsPath}/nes/homebrew"
	unlink "${romsPath}/snes/homebrew"

	rm -rf "$toolsPath/homebrew/roms/" && echo "true"
}

emuDeckInstallHomebrewGame(){
	system=$1
	gameName=$2
	game=$3
	
	
	gameNameUrl="${gameName//[ ]/%20}"  
	gameUrl="${game//[ ]/%20}"         

	mkdir -p ${romsPath}/${system}/homebrew/ && \
	mkdir -p ${toolsPath}/downloaded_media/${system}/screenshots/homebrew/ && \
	mkdir -p ${toolsPath}/downloaded_media/${system}/titlescreens/homebrew/ #&& \
	curl "${gameUrl}" -o "${romsPath}/${system}/homebrew/${gameName}.zip" && \
	curl "https://raw.githubusercontent.com/EmuDeck/emudeck-homebrew/main/downloaded_media/${system}/screenshots/homebrew/${gameNameUrl}.png" -o "${toolsPath}/downloaded_media/${system}/screenshots/homebrew/${gameName}.png" && \
	curl "https://raw.githubusercontent.com/EmuDeck/emudeck-homebrew/main/downloaded_media/${system}/titlescreens/homebrew/${gameNameUrl}.png" -o "${toolsPath}/downloaded_media/${system}/titlescreens/homebrew/${gameName}.png" && echo 'true'

}

emuDeckUnInstallHomebrewGame(){
	system=$1
	gameName=$2
	game=$3
	echo ${romsPath}/${system}/homebrew/${gameName}.zip;
	
	rm -rf "${romsPath}/${system}/homebrew/${gameName}.zip" && \
	rm -rf  "${toolsPath}/downloaded_media/${system}/screenshots/homebrew/${gameName}.png" && \
	rm -rf "${toolsPath}/downloaded_media/${system}/titlescreens/homebrew/${gameName}.png" && echo 'true'

}