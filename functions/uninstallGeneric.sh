#!/bin/bash

uninstallGeneric() {
    name=$1
    executablepath=$2
    desktopname=$3
    type=$4

    if [[ -z "$desktopname" ]]; then
        desktopname="$name"
    fi

	if [[ "$type" == "emulator" ]]; then
		launcherPath="${toolsPath}/launchers"
	elif [[ "$type" == "remoteplay" ]]; then
		launcherPath="${romsPath}/remoteplay"
	elif [[ "$type" == "genericapplication" ]]; then
		launcherPath="${romsPath}/generic-applications"
	fi

    echo "1, Application Name: $name"
    echo "2, Application Executable Path: $executablepath"
    echo "3, Desktop File Name: $desktopname"
    echo "3, Application Type: $type"

    rm -rf "$HOME/.local/share/applications/$desktopname.desktop"
    rm -rf $executablepath

    shName=$(echo "$name" | awk '{print tolower($0)}')
    find "${launcherPath}/" "${romsPath}/emulators" -maxdepth 1 -type f \( -iname "$shName.sh" -o -iname "$shName-emu.sh" \) | \
    while read -r f
    do
        echo "deleting $f"
        rm -f "$f"
    done
}
