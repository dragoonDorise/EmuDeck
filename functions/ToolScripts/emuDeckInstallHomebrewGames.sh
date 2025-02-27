#!/bin/bash

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