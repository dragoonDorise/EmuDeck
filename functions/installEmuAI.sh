#!/bin/bash
installEmuAI(){
    local name="$1"
    local url="$2"
    local altName="$3"
    local showProgress="$4"
    local lastVerFile="$5"
    local latestVer="$6"

    if [[ "$altName" == "" ]]; then
        altName="$name"
    fi
    echo "$name"
    echo "$url"
    echo "$altName"
    echo "$showProgress"
    echo "$lastVerFile"
    echo "$latestVer"

    #rm -f "$HOME/Applications/$altName.AppImage" # mv in safeDownload will overwrite...
    mkdir -p "$HOME/Applications"

    #curl -L "$url" -o "$HOME/Applications/$altName.AppImage.temp" && mv "$HOME/Applications/$altName.AppImage.temp" "$HOME/Applications/$altName.AppImage"
    if safeDownload "$name" "$url" "$HOME/Applications/$altName.AppImage" "$showProgress"; then
        chmod +x "$HOME/Applications/$altName.AppImage"
        if [[ ! -z $lastVerFile ]] && [[ ! -z $latestVer ]]; then
            echo "latest version $latestVer > $lastVerFile"
            echo $latestVer > "$lastVerFile"
        fi
    else
        return 1
    fi

    shName=$(echo "$name" | awk '{print tolower($0)}')
    find "${toolsPath}/launchers/" -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | \
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

        createDesktopShortcut   "$HOME/.local/share/applications/$altName.desktop" \
                                "$altName AppImage" \
                                "${toolsPath}/launchers/$launcherFileName" \
                                "false"
    done
}
