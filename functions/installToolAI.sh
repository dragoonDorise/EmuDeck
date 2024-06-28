#!/bin/bash
installToolAI(){
    local name="$1"
    local url="$2"
    local fileName="$3"
    local showProgress="$4"
    local lastVerFile="$5"
    local latestVer="$6"

    if [[ -z "$fileName" ]]; then
        fileName="$name"
    fi

    echo "1: $name"
    echo "2: $url"
    echo "3: $fileName"
    echo "4: $showProgress"
    echo "5: $lastVerFile"
    echo "6: $latestVer"

    echo "1, Application Name: $name"
    echo "2, Application URL: $url"
    echo "3, Application Filename: $fileName"
    echo "4, Progress: $showProgress"
    echo "5, Last Version File: $lastVerFile"
    echo "6, Last Version: $latestVer"


    #curl -L "$url" -o "$toolsPath/$fileName.AppImage.temp" && mv "$toolsPath/$fileName.AppImage.temp" "$toolsPath/$fileName.AppImage"
    if safeDownload "$name" "$url" "$toolsPath/$fileName.AppImage" "$showProgress"; then
        chmod +x "$toolsPath/$fileName.AppImage"
        if [[ -n $lastVerFile ]] && [[ -n $latestVer ]]; then
            echo "latest version $latestVer > $lastVerFile"
            echo "$latestVer" > "$lastVerFile"
        fi
    else
        return 1
    fi

#    shName=$(echo "$name" | awk '{print tolower($0)}')

# TODO: Restore this funcionality
#     find "${toolsPath}/launchers/" -maxdepth 2 -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | \
#     while read -r f
#     do
#         echo "deleting $f"
#         rm -f "$f"
#     done
#
#     find "${EMUDECKGIT}/tools/launchers/" -maxdepth 2 -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | \
#     while read -r l
#     do
#         echo "deploying $l"
#         launcherFileName=$(basename "$l")
#         folderName=$(dirname "$l" | sed 's!.*/!!')
#         if [ $folderName == "launchers" ]; then
#             folderName=""
#         fi
#         chmod +x "$l"
#         mkdir -p "${toolsPath}/launchers/$folderName"
#         cp -v -r "$l" "${toolsPath}/launchers/$folderName/$launcherFileName"
#         chmod +x "${toolsPath}/launchers/$folderName/$launcherFileName"
#         name=${name//-/}
#         name=${name// /}
#         createDesktopShortcut   "$HOME/.local/share/applications/$name.desktop" \
#                                 "$name" \
#                                 "${toolsPath}/launchers/$folderName/$launcherFileName" \
#                                 "false"
#     done
}
