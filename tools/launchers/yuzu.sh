#!/bin/sh
emuName="yuzu" #parameterize me
emufolder="$HOME/Applications" # has to be applications for ES-DE to find it
emuExeFile=$(find $emufolder -iname "${emuName}*.AppImage" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)
emuDontUpdate="$HOME/emudeck/${emuName}.noupdate"
#source the helpers for safeDownload
. ~/.config/EmuDeck/backend/functions/helperFunctions.sh

# update check only if we're not launching yuzu-ea...
isMainline=true
if [ ! "$emuExeFile" == "$emufolder/$emuName.AppImage" ]; then
    isMainline=false
fi

if [ -z "$1" ] && [ "$isMainline" = true ] && [ ! -e "${emuDontUpdate}" ]; then
    echo "Yuzu mainline detected, checking connectivity"

    if : >/dev/tcp/8.8.8.8/53; then

    echo 'Internet available. Check for Update'

    yuzuHost="https://api.github.com/repos/yuzu-emu/yuzu-mainline/releases/latest"
    metaData=$(curl -fSs ${yuzuHost})
    fileToDownload=$(echo ${metaData} | jq -r '.assets[] | select(.name|test(".*.AppImage$")).browser_download_url')
    currentVer=$(echo ${metaData} | jq -r '.tag_name')
    lastDL="$HOME/emudeck/yuzu.ver"

    if [ "$currentVer" == "$(cat ${lastDL})" ] ;then
        echo "no need to update."
    elif [ -z $currentVer ] ;then
        echo "couldn't get metadata."
    else
        zenity --question --title="Yuzu update available!" --width 200 --text "Yuzu ${currentVer} available. Would you like to update?" --ok-label="Yes" --cancel-label="No" 2>/dev/null
        if [[ $? == 0 ]]; then
            echo "download ${currentVer} appimage: ${fileToDownload}"

            #response=$(curl -L -X GET ${fileToDownload} --write-out '%{http_code}' -H "Accept: application/json" -o "${HOME}/Applications/${emuName}.AppImage")
            if safeDownload "yuzu" "${fileToDownload}" "$emufolder/$emuName.AppImage" "true"; then
                chmod +x "$emufolder/$emuName.AppImage"
                echo "latest version $currentVer > $lastVerFile"
                echo ${currentVer} > ${lastDL}
            else
                zenity --error --text "Error updating yuzu!" --width=250 2>/dev/null
            fi
        fi
    fi
    else
        echo 'Offline'
    fi
fi

#find full path to emu executable
exe="prlimit --nofile=8192 ${emuExeFile}"

#run the executable with the params.
#Fix first '
param="${@}"
substituteWith='"'
param=${param/\'/"$substituteWith"}
#Fix last ' on command
param=$(echo "$param" | sed 's/.$/"/')
eval "${exe} ${param}"
