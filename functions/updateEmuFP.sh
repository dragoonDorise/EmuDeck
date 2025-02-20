#!/bin/bash
updateEmuFP(){		
	
	name=$1
	ID=$2	
	type="$3"
	scriptname="$4"

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

    if [[ -z "$scriptname" ]]; then
        scriptname="$name"
    fi

    echo "1, Flatpak Name: $name"
    echo "2, Flatpak ID: $ID"
    echo "3, Flatpak Type: $type"
	echo "4, Flatpak Script Name: $scriptname"

	setMSG "Updating $name"
	
	flatpak update $ID -y
	flatpak override $ID --filesystem=host --user
	flatpak override $ID --share=network --user	
	
	shName=$(echo "$name" | awk '{print tolower($0)}')
	mkdir -p "${romsPath}/emulators"
	mkdir -p "$launcherPath"
    find "${launcherPath}/" "${romsPath}/emulators" -maxdepth 1 -type f \( -iname "$shName.sh" -o -iname "$shName-emu.sh" \) | \
    while read -r f
    do
        echo "deleting $f"
        rm -f "$f"
    done

	find "$gitPath" -type f \( -iname "${shName}.sh" -o -iname "$shName-emu.sh" \) | while read -r l; do
		echo "deploying new: $l"
		chmod +x "$l"
		cp -v "$l" "${launcherPath}"
        if [[ "$type" == "emulator" ]]; then
            cp -v "$l" "${romsPath}/emulators"
            chmod +x "${romsPath}/emulators/"*
        fi 
	done
	
}
