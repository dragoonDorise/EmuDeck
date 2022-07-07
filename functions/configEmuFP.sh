#!/bin/bash
configEmuFP(){		
	
	name=$1
	ID=$2
	overwrite=$3
	
	if [[ $overwrite == 'true' ]]; then
		overwrite="--backup --suffix=.bak"
    else
        overwrite="--ignore-existing"
    fi	
	setMSG "Updating $name Config using $overwrite"	
	
	rsync -avhp --mkpath "$EMUDECKGIT/configs/${ID}" "$HOME/.var/app/" $overwrite
	

}