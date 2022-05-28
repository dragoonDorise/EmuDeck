#!/bin/bash
installEmuFP(){		
	
	name=$1
	ID=$2	
	
	setMSG "# Installing $name"
	
	flatpak install flathub $ID -y --system	
	flatpak override $ID --filesystem=host --user
	flatpak override $ID --share=network --user	
	
	shName=$($name | awk '{print tolower($0)}')
	
	cp "${EMUDECKGIT}"/configs/$ID "${toolsPath}"launchers/"${shName}".sh	
	
}