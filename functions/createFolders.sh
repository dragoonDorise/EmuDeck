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
	mkdir -p "$biosPath"/Mupen64plus/cache
	mkdir -p "$emulationPath"/hdpacks
	
	
	unlink "$emulationPath"/hdpacks/Mesen 2>/dev/null #refresh link if moved
	ln -s "$biosPath"/HdPacks/ "$emulationPath"/hdpacks/Mesen
	echo "Put your Mesen HD Packs here. Remember to put the pack inside a folder here with the exact name of the rom" > "$emulationPath"/hdpacks/Mesen/readme.txt
	
	unlink "$emulationPath"/hdpacks/Mupen64plus_next 2>/dev/null #refresh link if moved
	ln -s "$biosPath"/Mupen64plus/cache/ "$emulationPath"/hdpacks/Mupen64plus_next
	echo "Put your Nintendo64 HD Packs here in HTS format. You can download them from https://emulationking.com/nintendo64/" > "$emulationPath"/hdpacks/Mupen64plus_next/readme.txt
	
	##Generate rom folders
	setMSG "Creating roms folder in $romsPath"
	##remove old readme.txt
	find "$romsPath" -name readme.txt -type f -delete -maxdepth 2
	
	sleep 3
	rsync -r --ignore-existing "$EMUDECKGIT/roms/" "$romsPath" 
	#End repeated code	
}