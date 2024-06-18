#!/bin/bash
updateEmuFP(){		
	
	name=$1
	ID=$2	
	type="$3"

	if [[ "$type" == "emulator" ]]; then
		gitPath="${EMUDECKGIT}/tools/launchers/"
		launcherPath="${toolsPath}/launchers"
	elif [[ "$type" == "remoteplay" ]]; then
		gitPath="${EMUDECKGIT}/tools/remoteplayclients/"
		launcherPath="${romsPath}/remoteplay"
	elif [[ "$type" == "genericapplication" ]]; then
		gitPath="${EMUDECKGIT}/tools/generic-applications/"
		launcherPath="${romsPath}/generic-applications"
	fi	

	setMSG "Updating $name"
	
	flatpak update $ID -y
	flatpak override $ID --filesystem=host --user
	flatpak override $ID --share=network --user	
	
  	if [[ "$type" == "emulator" ]]; then
        shName=$(echo "$name" | awk '{print tolower($0)}')-emu
    else
        shName=$(echo "$name" | awk '{print tolower($0)}')
    fi 
	
	find "$launcherPath" -maxdepth 1 -type f \( -iname "${shName}.sh" -o -iname "${shName}.sh" \) | while read -r f; do
		echo "deleting old: $f"
		rm -f "$f"
	done

	find "$gitPath" -type f \( -iname "${shName}.sh" -o -iname "${shName}.sh" \) | while read -r l; do
		echo "deploying new: $l"
		chmod +x "$l"
		cp -v "$l" "${launcherPath}"
	done
	
}
