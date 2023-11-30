#!/bin/bash
configEmuAI(){

	emu=$1
	folderName=$2
    folderPath=$3
    gitLocation=$4
    overwrite=$5

	if [[ $overwrite == 'true' ]]; then
		overwrite="--backup --suffix=.bak"
    else
        overwrite="--ignore-existing"
    fi
    
	setMSG "Updating $emu $folderName using $overwrite"	

	rsync -avhp --mkpath $gitLocation/ $folderPath $overwrite


}