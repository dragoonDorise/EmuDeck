#!/bin/bash
installEmuBI(){
    local name="$1"
    local url="$2"
    local fileName="$3"
    local format="$4"
    local showProgress="$5"
    local lastVerFile="$6"
    local latestVer="$7"

    if [[ -z "$fileName" ]]; then
        fileName="$name"
    fi

    echo "1, Application Name: $name"
    echo "2, Application URL: $url"
    echo "3, Application Filename: $fileName"
    echo "4, Application File Format: $format"
    echo "5, Progress: $showProgress"
    echo "6, Last Version File: $lastVerFile"
    echo "7, Last Version: $latestVer"

    #rm -f "$HOME/Applications/$fileName.$format" # mv below will overwrite...
    mkdir -p "$HOME/Applications"

    #curl -L "$url" -o "$HOME/Applications/$fileName.$format.temp" && mv "$HOME/Applications/$fileName.$format.temp" "$HOME/Applications/$fileName.$format"
    if safeDownload "$name" "$url" "$HOME/Applications/${fileName}.${format}" "$showProgress"; then
        if [[ -n $lastVerFile ]] && [[ -n $latestVer ]]; then
            echo "latest version $latestVer > $lastVerFile"
            echo "$latestVer" > "$lastVerFile"
        fi
    else
        return 1
    fi

    shName=$(echo "$name" | awk '{print tolower($0)}')
    mkdir -p "${romsPath}/emulators"
    find "${toolsPath}/launchers/" "${romsPath}/emulators" -maxdepth 1 -type f \( -iname "$shName.sh" -o -iname "$shName-emu.sh" \) | \
    while read -r f
    do
        echo "deleting $f"
        rm -f "$f"
    done

    find "${EMUDECKGIT}/tools/launchers/" -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | \
    while read -r l
    do
        echo "deploying $l"
        launcherFileName=$(basename "$l")
        chmod +x "$l"
        cp -v "$l" "${toolsPath}/launchers/"
        chmod +x "${toolsPath}/launchers/"*
        cp -v "$l" "${romsPath}/emulators"
		chmod +x "${romsPath}/emulators/"*

        createDesktopShortcut   "$HOME/.local/share/applications/$name.desktop" \
                                "$name Binary" \
                                "${toolsPath}/launchers/$launcherFileName" \
                                "false"
    done
}