#!/bin/bash
installEmuBI(){
    local name="$1"
    local url="$2"
    local altName="$3"
    local format="$4"
    local showProgress="$5"
    local lastVerFile="$6"
    local latestVer="$7"

    if [[ "$altName" == "" ]]; then
        altName="$name"
    fi
    echo "$name"
    echo "$url"
    echo "$altName"
    echo "$format"
    echo "$showProgress"
    echo "$lastVerFile"
    echo "$latestVer"

    #rm -f "$HOME/Applications/$altName.$format" # mv below will overwrite...
    mkdir -p "$HOME/Applications"

    #curl -L "$url" -o "$HOME/Applications/$altName.$format.temp" && mv "$HOME/Applications/$altName.$format.temp" "$HOME/Applications/$altName.$format"
    if safeDownload "$name" "$url" "$HOME/Applications/$altName.$format" "$showProgress"; then
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

        createDesktopShortcut   "$HOME/.local/share/applications/$altName.desktop" \
                                "$altName Binary" \
                                "${toolsPath}/launchers/$launcherFileName" \
                                "false"
    done
}