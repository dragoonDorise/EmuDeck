#!/bin/bash
configEmuFP(){		
	
	name=$1
	ID=$2
	overwrite=$3
	
	if [[ ! $overwrite == 'true' ]]; then
        overwrite="--ignore-existing"
    else
        overwrite="--backup --suffix=.bak"
    fi	
	setMSG "Updating $name Config using $overwrite"	
	
	rsync -avhp --mkpath "$HOME/dragoonDoriseTools/EmuDeck/configs/${ID}" "$HOME/.var/app/" $overwrite
	

}