#!/bin/bash
configEmuAI(){		
	
	emu=$1
	folderName=$2
    folderPath=$3
    gitLocation=$4
    overwrite=$5

    if [[ ! $overwrite == 'true' ]]; then
        overwrite="--ignore-existing"
    else
        overwrite=""
    fi
    
	setMSG "Backing up ${emu} ${folderName}..."
	cp -r ${folderPath} ${folderPath}_bak		

	
	rsync -avhp $gitLocation $folderPath $overwrite	
	
}