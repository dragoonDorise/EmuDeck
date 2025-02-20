#!/bin/bash
installEmuFP(){		
	
	local name="$1"
	local ID="$2"
	local type="$3"
	local scriptname="$4"

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

	setMSG "Installing $name"
	
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo --user
	flatpak install flathub "$ID" -y --user
	flatpak override "$ID" --filesystem=host --user
	flatpak override "$ID" --share=network --user
	#remove old system flatpak after we detect user flatpak is installed
	if [ "$(flatpak --columns=app list --user | grep "$ID")" == "$ID" ]; then
		flatpak uninstall "$ID" --system -y
	fi
 	
	shName=$(echo "$scriptname" | awk '{print tolower($0)}')
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
