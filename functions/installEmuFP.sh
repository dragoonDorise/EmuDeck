#!/bin/bash
installEmuFP(){		
	
	name=$1
	ID=$2	
	
	setMSG "Installing $name"
	
	flatpak install flathub $ID -y --system	
	flatpak override $ID --filesystem=host --user
	flatpak override $ID --share=network --user	
	
	shName=$(echo "$name" | awk '{print tolower($0)}')
	
   	find "${toolsPath}/launchers/" -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | while read -r f; do echo "deleting $f"; rm -f "$f"; done;
    find "${EMUDECKGIT}/tools/launchers/" -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | while read -r l; do echo "deploying $l"; chmod +x "$l"; cp -v "$l" "${toolsPath}/launchers/"; done;

	
}
