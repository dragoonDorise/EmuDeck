#!/bin/bash
installEmuAI(){
    local name="$1"
    local url="$2"
    local fileName="$3"
    local format="$4"
    local type="$5"
    local showProgress="$6"
    local lastVerFile="$7"
    local latestVer="$8"

    if [[ -z "$fileName" ]]; then
        fileName="$name"
    fi

    if [[ -z "$format" ]]; then
        format="AppImage"
    fi

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

    echo "1, Application Name: $name"
    echo "2, Application URL: $url"
    echo "3, Application Filename: $fileName"
    echo "4, Application File Format: $format"
    echo "5, Application Type: $type"
    echo "6, Progress: $showProgress"
    echo "7, Last Version File: $lastVerFile"
    echo "8, Last Version: $latestVer"


    #rm -f "$HOME/Applications/$fileName.$format" # mv in safeDownload will overwrite...
    mkdir -p "$HOME/Applications"

    #curl -L "$url" -o "$HOME/Applications/$fileName.AppImage.temp" && mv "$HOME/Applications/$fileName.AppImage.temp" "$HOME/Applications/$fileName.AppImage"
    if safeDownload "$name" "$url" "$HOME/Applications/${fileName}.${format}" "$showProgress"; then
        chmod +x "$HOME/Applications/$fileName.AppImage"
        if [[ -n $lastVerFile ]] && [[ -n $latestVer ]]; then
            echo "latest version $latestVer > $lastVerFile"
            echo "$latestVer" > "$lastVerFile"
        fi
    else
        return 1
    fi

    shName=$(echo "$name" | awk '{print tolower($0)}')  
    mkdir -p "${romsPath}/emulators"
    mkdir -p "$launcherPath"
    find "${launcherPath}/" "${romsPath}/emulators" -maxdepth 1 -type f \( -iname "$shName.sh" -o -iname "$shName-emu.sh" \) | \
    while read -r f
    do
        echo "deleting $f"
        rm -f "$f"
    done

    find "${gitPath}" -type f \( -iname "${shName}.sh" -o -iname "$shName-emu.sh" \) | \
    while read -r l; do
        echo "deploying $l"
        launcherFileName=$(basename "$l")
        chmod +x "$l"
        cp -v "$l" "$launcherPath"
        chmod +x "${launcherPath}"/*

        if [[ "$type" == "emulator" ]]; then
            cp -v "$l" "${romsPath}/emulators"
            chmod +x "${romsPath}/emulators/"*
        fi 

        createDesktopShortcut   "$HOME/.local/share/applications/${name}.desktop" \
                                "${name} AppImage" \
                                "${launcherPath}/${launcherFileName}" \
                                "false"
    done

}
