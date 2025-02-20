#!/bin/bash

uninstallEmuFP() {
    name=$1
    ID=$2
    type=$3
	scriptname="$4"

	if [[ "$type" == "emulator" ]]; then
		launcherPath="${toolsPath}/launchers"
	elif [[ "$type" == "remoteplay" ]]; then
		launcherPath="${romsPath}/remoteplay"
	elif [[ "$type" == "genericapplication" ]]; then
		launcherPath="${romsPath}/generic-applications"
	fi

    if [[ -z "$scriptname" ]]; then
        scriptname="$name"
    fi


    echo "1, Flatpak Name: $name"
    echo "2, Flatpak ID: $ID"
    echo "3, Flatpak Type: $type"
	echo "4, Flatpak Script Name: $scriptname"


    flatpak uninstall "$ID" -y --user
    flatpak uninstall "$ID" -y --system

    shName=$(echo "$scriptname" | awk '{print tolower($0)}')
    for romfolder in "${launcherPath}/" "${romsPath}/emulators" "${romsPath}/desktop/remoteplay" "${romsPath}/desktop/generic-applications"; do
        if [ -d "$romfolder" ]; then
            find "$romfolder" -maxdepth 1 -type f \( -iname "$shName.sh" -o -iname "$shName-emu.sh" \) | \
            while read -r f; do
                echo "deleting $f"
                rm -f "$f"
            done
        else
            echo "Skipping. $romfolder does not exist."
        fi
    done
}
