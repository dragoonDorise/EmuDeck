#!/bin/bash
installEmuAI(){
    local name="$1"
    local scriptName="$2"
    local url="$3"
    local fileName="$4"
    local format="$5"
    local type="$6"
    local showProgress="$7"
    local lastVerFile="$8"
    local latestVer="$9"
    local downloadChecksumSha256="${10}"

    if [[ -z "$fileName" ]]; then
        fileName="$name"
    fi

    if [[ -z "$format" ]]; then
        format="AppImage"
    fi

    if [[ -z "$scriptName" ]]; then
        scriptName="$name"
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

    echo "01, Application Name: $name"
	echo "02, AppImage Script Name: $scriptName"
    echo "03, Application URL: $url"
    echo "04, Application Filename: $fileName"
    echo "05, Application File Format: $format"
    echo "06, Application Type: $type"
    echo "07, Progress: $showProgress"
    echo "08, Last Version File: $lastVerFile"
    echo "09, Last Version: $latestVer"
    echo "10, Download checksum (SHA256): $downloadChecksumSha256"

    #rm -f "$HOME/Applications/$fileName.$format" # mv in safeDownload will overwrite...
    mkdir -p "$HOME/Applications"

    if [[ -z "$url" ]]; then
        if [ -f "$HOME/Applications/${fileName}.${format}" ]; then
            echo "No download link provided but local file already exists. Will refresh links and launcher."
        else
            echo "No download link provided and no local file exists, exitting."
            return 1
        fi
    elif safeDownload "$name" "$url" "$HOME/Applications/${fileName}.${format}" "$showProgress" "" "$downloadChecksumSha256"; then
        echo "$name downloaded successfuly."
    else
        echo "Failed to download or verify $name."
        return 1
    fi

    chmod +x "$HOME/Applications/$fileName.AppImage"
    if [[ -n $lastVerFile ]] && [[ -n $latestVer ]]; then
        echo "latest version $latestVer > $lastVerFile"
        echo "$latestVer" > "$lastVerFile"
    fi

    shName=$(echo "$scriptName" | awk '{print tolower($0)}')  
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
