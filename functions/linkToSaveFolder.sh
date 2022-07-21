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

moveSaveFolder(){	
    emu=$1
    folderName=$2
    path=$3

	linkedTarget=$(readlink -f "$savesPath/$emu/$folderName")

	unlink "$savesPath/$emu/$folderName"

	if [[ ! -e "$savesPath/$emu/$folderName" ]]; then
		mkdir -p "$savesPath/$emu/$folderName"
		if [[ "$linkedTarget" == "$path" ]]; then		
			setMSG "Moving $emu $folderName to the Emulation/saves/$emu/$folderName folder"	
			rsync -avh "$path/" "$savesPath/$emu/$folderName" && rm -rf "${path:?}"
			ln -sn  "$savesPath/$emu/$folderName" "$path"
		fi
	fi
	
}