#!/bin/bash

createFolders(){ 
	#Folder creation... This code is repeated outside of this if for the yes zenity mode
	mkdir -p "$emulationPath"
	mkdir -p "$toolsPath"/launchers 
	mkdir -p "$savesPath"
	mkdir -p "$romsPath"
	mkdir -p "$storagePath"
	mkdir -p "$biosPath"/yuzu
	mkdir -p "$biosPath"/HdPacks
	mkdir -p "$emulationPath"/hdpacks
	
	unlink "$emulationPath"/hdpacks/Mesen 2>/dev/null #refresh link if moved
	ln -s "$biosPath"/HdPacks/ "$emulationPath"/hdpacks/Mesen
	echo "Put your Mesen HD Packs here. Remember to put the pack inside a folder here with the exact name of the rom" > "$biosPath"/HdPacks/readme.txt
	
	##Generate rom folders
	setMSG "Creating roms folder in $romsPath"
	
	sleep 3
	rsync -r --ignore-existing "$EMUDECKGIT/roms/" "$romsPath" 
	#End repeated code	
}