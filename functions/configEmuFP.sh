#!/bin/bash
configEmuFP(){		
	
	name=$1
	ID=$2	
	
	FOLDER=~/.var/app/"${ID}"/config_bak
	if [ ! -d "$FOLDER" ]; then
		setMSG "Backing up ${name} Config..."
		cp -r ~/.var/app/"${ID}"/config ~/.var/app/"${ID}"/config_bak		
	fi
	
	FOLDER=~/.var/app/"${ID}"/data_bak
	if [ ! -d "$FOLDER" ]; then
		setMSG "Backing up ${name} Data..."
		cp -r ~/.var/app/"${ID}"/data ~/.var/app/"${ID}"/data_bak		
	fi
	
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/"${ID}"/ ~/.var/app/"${ID}"/ 	
	
}