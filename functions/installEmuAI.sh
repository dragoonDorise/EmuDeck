#!/bin/bash
installEmuAI(){
    local name="$1"
    local url="$2"
    local fileName="$3"
    local showProgress="$4"
    local lastVerFile="$5"
    local latestVer="$6"

    if [[ "$fileName" == "" ]]; then
        fileName="$name"
    fi
    echo "$name"
    echo "$url"
    echo "$fileName"
    echo "$showProgress"
    echo "$lastVerFile"
    echo "$latestVer"

    #rm -f "$HOME/Applications/$fileName.AppImage" # mv in safeDownload will overwrite...
    mkdir -p "$HOME/Applications"

    #curl -L "$url" -o "$HOME/Applications/$fileName.AppImage.temp" && mv "$HOME/Applications/$fileName.AppImage.temp" "$HOME/Applications/$fileName.AppImage"
    if safeDownload "$name" "$url" "$HOME/Applications/$fileName.AppImage" "$showProgress"; then
        chmod +x "$HOME/Applications/$fileName.AppImage"
        if [[ -n $lastVerFile ]] && [[ -n $latestVer ]]; then
            echo "latest version $latestVer > $lastVerFile"
            echo "$latestVer" > "$lastVerFile"
        fi
    else
        return 1
    fi

    shName=$(echo "$name" | awk '{print tolower($0)}')
    find "${toolsPath}/launchers/" -maxdepth 1 -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | \
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

        createDesktopShortcut   "$HOME/.local/share/applications/$name.desktop" \
                                "$name AppImage" \
                                "${toolsPath}/launchers/$launcherFileName" \
                                "false"
    done
}
