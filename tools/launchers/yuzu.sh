#!/bin/bash
emuName="yuzu" #parameterize me
useEAifFound="true" # set to false to simply use the newest file found
emufolder="$HOME/Applications" # has to be applications for ES-DE to find it
emuDontUpdate="$HOME/emudeck/${emuName}.noupdate"
Yuzu_emuPath="$HOME/Applications/yuzu.AppImage"
YuzuEA_emuPath="$HOME/Applications/yuzu-ea.AppImage"
YuzuEA_tokenFile="$HOME/emudeck/yuzu-ea-token.txt"
YuzuEA_lastVerFile="$HOME/emudeck/yuzu-ea.ver"
Yuzu_lastVerFile="$HOME/emudeck/yuzu.ver"
showProgress="true"

#source the helpers for safeDownload
. "$HOME/.config/EmuDeck/backend/functions/helperFunctions.sh"

#force ea if available
if [ "$useEAifFound" = "true" ]; then
    emuExeFile=$(find "$emufolder" -iname "${emuName}-ea*.AppImage" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)
fi
if [[ ! $emuExeFile =~ "AppImage" ]]; then
    #find the most recent yuzu*.AppImage by creation date
    emuExeFile=$(find "$emufolder" -iname "${emuName}*.AppImage" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)
fi
if [[ ! $emuExeFile =~ "AppImage" ]]; then
     zenity --info --title="Yuzu AppImage not found!" --width 200 --text "Please check that you have the appimage in ~/Applications or \nrerun Emudeck and ensure it is installed." 2>/dev/null
fi
isMainline=true
if [ ! "$emuExeFile" = "$emufolder/$emuName.AppImage" ]; then
    isMainline=false
fi

echo "Detected exe: $emuExeFile"

#if launched without parameters we can check for updates.
if [ -z "$1" ];then
    #check for noupdate flag
    if [ ! -e "${emuDontUpdate}" ]; then
        #check for network
        if : >/dev/tcp/8.8.8.8/53; then
            echo 'Internet available. Check for Update'
            #check if we are running mainline so we can offer to update
            if [ "$isMainline" = true ]; then
                echo "Yuzu mainline detected, checking connectivity"



                yuzuHost="https://api.github.com/repos/yuzu-emu/yuzu-mainline/releases/latest"
                metaData=$(curl -fSs ${yuzuHost})
                fileToDownload=$(echo ${metaData} | jq -r '.assets[] | select(.name|test(".*.AppImage$")).browser_download_url')
                currentVer=$(echo ${metaData} | jq -r '.tag_name')


                if [ "$currentVer" = "$(cat ${Yuzu_lastVerFile})" ] ;then
                    echo "no need to update."
                elif [ -z "$currentVer" ] ;then
                    echo "couldn't get metadata."
                else
                    zenity --question --title="Yuzu update available!" --width 200 --text "Yuzu ${currentVer} available. Would you like to update?" --ok-label="Yes" --cancel-label="No" 2>/dev/null
                    if [ $? = 0 ]; then
                        echo "download ${currentVer} appimage: ${fileToDownload}"

                        if safeDownload "$emuName" "${fileToDownload}" "$Yuzu_emuPath" "$showProgress"; then
                            chmod +x "$emufolder/$emuName.AppImage"
                            echo "latest version $currentVer > $Yuzu_lastVerFile"
                            echo "${currentVer}" > "${Yuzu_lastVerFile}"
                        else
                            zenity --error --text "Error updating yuzu!" --width=250 2>/dev/null
                        fi
                    fi
                fi
            else
                #if not running mainline check if we are running yuzu-ea and have a token file in place
                if [ "$emuExeFile" = "$YuzuEA_emuPath" ] && [ -e "$YuzuEA_tokenFile" ]; then
                    jwtHost="https://api.yuzu-emu.org/jwt/installer/"
                    yuzuEaHost="https://api.yuzu-emu.org/downloads/earlyaccess/"
                    yuzuEaMetadata=$(curl -fSs ${yuzuEaHost})
                    fileToDownload=$(echo "$yuzuEaMetadata" | jq -r '.files[] | select(.name|test(".*.AppImage")).url')
                    currentVer=$(echo "$yuzuEaMetadata" | jq -r '.files[] | select(.name|test(".*.AppImage")).name')

                    if [ -e "$YuzuEA_tokenFile" ]; then

                        if [ "$currentVer" = "$(cat "${YuzuEA_lastVerFile}")" ]; then

                            echo "no need to update."

                        elif [ -z  "$currentVer" ]; then

                            echo "couldn't get metadata."

                        else
                            zenity --question --title="Yuzu EA update available!" --width 200 --text "Yuzu-EA ${currentVer} available. Would you like to update?" --ok-label="Yes" --cancel-label="No" 2>/dev/null
                            if [ $? = 0 ]; then
                                echo "updating"
                                read -r user auth <<< "$( base64 -d -i "${YuzuEA_tokenFile}" | awk -F":" '{print $1" "$2}' )"

                                if [ -n "$user" ] && [ -n "$auth" ]; then

                                    echo "get bearer token"
                                    BEARERTOKEN=$(curl -X POST ${jwtHost} -H "X-Username: ${user}" -H "X-Token: ${auth}" -H "User-Agent: EmuDeck")

                                    echo "download ea appimage"
                                    if safeDownload "yuzu-ea" "$fileToDownload" "${YuzuEA_emuPath}" "$showProgress" "Authorization: Bearer ${BEARERTOKEN}"; then
                                        chmod +x "$YuzuEA_emuPath"
                                        echo "latest version $currentVer > $YuzuEA_lastVerFile"
                                        echo "${currentVer}" > "${YuzuEA_lastVerFile}"
                                    else
                                        zenity --error --text "Error updating yuzu!" --width=250 2>/dev/null
                                    fi

                                else
                                    echo "Token malformed"
                                fi

                            fi
                        fi
                    else
                        echo "Token Not Found"
                    fi
                fi
            fi
        else
            echo 'Offline'
        fi
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