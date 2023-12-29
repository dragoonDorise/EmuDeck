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

	##Generate rom folders
	setMSG "Creating roms folder in $romsPath"
	##remove old readme.txt
	find "$romsPath" -name readme.txt -type f -delete -maxdepth 2

	sleep 3
	rsync -r --ignore-existing "$EMUDECKGIT/roms/" "$romsPath"
	#End repeated code
}