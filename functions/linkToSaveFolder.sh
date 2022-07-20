#!/bin/bash
linkToSaveFolder(){	
    emu=$1
    folderName=$2
    path=$3

	if [ ! -d "$savesPath/$emu/$folderName" ]; then		
		mkdir -p $savesPath/$emu
		setMSG "Linking $emu $folderName to the Emulation/saves folder"			
		mkdir -p $path 
		ln -sn $path $savesPath/$emu/$folderName 
	fi

}