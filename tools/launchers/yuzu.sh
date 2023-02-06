#!/bin/sh
emuName="yuzu" #parameterize me
emufolder="$HOME/Applications" # has to be applications for ES-DE to find it


if [ -z "$1" ]; then
    echo $1
    if : >/dev/tcp/8.8.8.8/53; then

    echo 'Internet available. Check for Update'

    yuzuHost="https://api.github.com/repos/yuzu-emu/yuzu-mainline/releases/latest"
    metaData=$(curl ${yuzuHost})
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
                    response=$(curl -L -X GET ${fileToDownload} --write-out '%{http_code}' -H "Accept: application/json" -o "${HOME}/Applications/${emuName}.AppImage")

                    if [ "$response" = "200" ] ; then
                        echo "downloaded successfully"
                        echo ${currentVer} > ${lastDL}
                        chmod +x "${HOME}/Applications/${emuName}.AppImage"
                    elif [ "$response" = "401" ] ; then
                        echo "Not authorized."
                    else
                        echo "Download errored with code $response"
                    fi
                fi
        fi



    else
    echo 'Offline'

    fi
fi

#find full path to emu executable
exe="prlimit --nofile=8192 $(find $emufolder -iname "${emuName}*.AppImage" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)"

#run the executable with the params.
#Fix first '
param="${@}"
substituteWith='"'
param=${param/\'/"$substituteWith"}
#Fix last ' on command
param=$(echo "$param" | sed 's/.$/"/')
eval "${exe} ${param}"