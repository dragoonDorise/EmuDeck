#!/bin/bash

uninstallEmuAI() {
    name=$1
    filename=$2
    format=$3
    type=$4

    if [[ -z "$filename" ]]; then
        filename="$name"
    fi

    if [[ -z "$format" ]]; then
        format="AppImage"
    fi

	if [[ "$type" == "emulator" ]]; then
		launcherPath="${toolsPath}/launchers"
	elif [[ "$type" == "remoteplay" ]]; then
		launcherPath="${romsPath}/remoteplay"
	elif [[ "$type" == "genericapplication" ]]; then
		launcherPath="${romsPath}/generic-applications"
	fi

    echo "1, Application Name: $name"
    echo "2, Application Filename: $filename"
    echo "3, Application File Format: $format"
    echo "4, Application Type: $type"

    echo "Uninstalling $name. Deleting "$HOME/Applications/$filename.$format". Deleting "$HOME/.local/share/applications/$name.desktop"" 

    rm -rf "$HOME/Applications/$filename.$format"
    rm -rf "$HOME/.local/share/applications/$name.desktop"

    shName=$(echo "$name" | awk '{print tolower($0)}')
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
