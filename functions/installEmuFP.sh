#!/bin/bash
installEmuFP(){		
	
	local name="$1"
	local ID="$2"
	
	setMSG "Installing $name"
	
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo --user
	flatpak install flathub "$ID" -y --user
	flatpak override "$ID" --filesystem=host --user
	flatpak override "$ID" --share=network --user
	#remove old system flatpak after we detect user flatpak is installed
	if [ "$(flatpak --columns=app list --user | grep "$ID")" == "$ID" ]; then
		flatpak uninstall "$ID" --system -y
	fi
 	
	shName=$(echo "$name" | awk '{print tolower($0)}')
	
   	find "${toolsPath}/launchers/" -maxdepth 1 -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | while read -r f; do echo "deleting old: $f"; rm -f "$f"; done;
    find "${EMUDECKGIT}/tools/launchers/" -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | while read -r l; do echo "deploying new: $l"; chmod +x "$l"; cp -v "$l" "${toolsPath}/launchers/"; done;

}
