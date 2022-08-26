#!/bin/bash
#while this is in testing, i'm copying in the functions. once we leave the original repo in place and don't delete it, i'd like to use the functions we already made.

source "$HOME/emudeck/backend/functions/all.sh"
if [ "$?" == "1" ]; then
    echo "functions could not be loaded."
    zenity --error \
    --text="EmuDeck Functions could not be loaded. Please re-run Emudeck install."
    exit
fi

updateCemu(){
     releasesStr=$(curl -sL https://cemu.info | awk 'BEGIN{
            RS="</a>"
            IGNORECASE=1
            }
            {
            for(o=1;o<=NF;o++){
                if ( $o ~ /href/){
                gsub(/.*href=\042/,"",$o)
                gsub(/\042.*/,"",$o)
                print $(o)
                }
            }
            }' | grep releases)

            mapfile -t releases <<< "$releasesStr"

            releaseTable=()
            for release in "${releases[@]}"; do
                releaseTable+=(false "$release")
                echo "release: $release"
            done

            releaseChoice=$(zenity --list \
            --title="EmuDeck" \
            --height=500 \
            --width=500 \
            --ok-label="OK" \
            --cancel-label="Exit" \
            --text="Choose your Cemu version." \
            --radiolist \
            --column="Select" \
            --column="Release" \
            "${releaseTable[@]}" 2>/dev/null)

            curl "$releaseChoice" --output "$romsPath/wiiu/cemu.zip"


            mkdir -p "$romsPath/wiiu/tmp"
            unzip -o "$romsPath/wiiu/cemu.zip" -d "$romsPath/wiiu/tmp"
            mv "$romsPath"/wiiu/tmp/*/ "$romsPath/wiiu/tmp/cemu/" #don't quote the *
            rsync -avzh "$romsPath/wiiu/tmp/cemu/" "$romsPath/wiiu/"
            rm -rf "$romsPath/wiiu/tmp" 
            rm -f "$romsPath/wiiu/cemu.zip"	
}


    #begin script
	#paths update via sed in main script
    #source the all.sh, these should be pulled correctly!
	scriptPath="${toolsPath}/binupdate"
	
	#initialize log
	TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
	LOGFILE="${scriptPath}/binupdate-$TIMESTAMP.log"
	exec > >(tee "${LOGFILE}") 2>&1
	
    binTable=()
    binTable+=(TRUE "EmulationStation-DE" "esde")
    binTable+=(TRUE "Steam Rom Manager" "srm")
    binTable+=(TRUE "Nintendo Switch Emu" "yuzu")
    binTable+=(TRUE "Nintendo Switch Emu" "ryujinx")
    binTable+=(TRUE "Sony PlayStation 2 Emu" "pcsx2-qt")
    binTable+=(TRUE "Nintendo WiiU Emu" "cemu")
    binTable+=(FALSE "Xbox 360 Emu - TESTING ONLY" "xenia")

#Binary selector
    text="$(printf "What tools do you want to get the latest version of?\n This tool will simply overwrite what you have with the newest available.")"
    binsToDL=$(zenity --list \
            --title="EmuDeck" \
            --height=500 \
            --width=250 \
            --ok-label="OK" \
            --cancel-label="Exit" \
            --text="${text}" \
            --checklist \
            --column="Select" \
            --column="System" \
            --column="Name" \
            --print-column=3 \
            "${binTable[@]}" 2>/dev/null)
    ans=$?
    messages=()
    if [ $ans -eq 0 ]; then
        echo "User selected: $binsToDL"
        if [[ "$binsToDL" == *"esde"* ]]; then
            ESDE_install
            if [ "$?" == "0" ]; then
                messages+=("EmulationStation-DE Updated Successfully")
            else
                messages+=("There was a problem updating EmulationStation-DE")
            fi
        fi
        if [[ "$binsToDL" == *"srm"* ]]; then
            SRM_install
            if [ "$?" == "0" ]; then
                messages+=("SteamRomManager Updated Successfully")
            else
                messages+=("There was a problem updating SteamRomManager")
            fi
        fi
        if [[ "$binsToDL" == *"yuzu"* ]]; then
            Yuzu_install
            if [ "$?" == "0" ]; then
                messages+=("Yuzu Updated Successfully")
            else
                messages+=("There was a problem updating Yuzu")
            fi
        fi
        if [[ "$binsToDL" == *"pcsx2-qt"* ]]; then
            PCSX2QT_install
            if [ "$?" == "0" ]; then
                messages+=("PCSX2-QT Updated Successfully")
            else
                messages+=("There was a problem updating PCSX2-QT")
            fi
        fi
        if [[ "$binsToDL" == *"ryujinx"* ]]; then
            Ryujinx_install
            if [ "$?" == "0" ]; then
                messages+=("Ryujinx Updated Successfully")
            else
                messages+=("There was a problem updating Ryujinx")
            fi
        fi
        if [[ "$binsToDL" == *"cemu"* ]]; then
            updateCemu
            if [ "$?" == "0" ]; then
                messages+=("Cemu Updated Successfully")
            else
                messages+=("There was a problem updating Cemu")
            fi
        fi
        if [[ "$binsToDL" == *"xenia"* ]]; then
            Xenia_install
            if [ "$?" == "0" ]; then
                messages+=("Xenia Updated Successfully")
            else
                messages+=("There was a problem updating Xenia")
            fi
        fi
        if [[ ${#messages[@]} -gt 0 ]]; then
            zenity  --list \
                    --title="Update Status" \
                    --text="" \
                    --column="Messages"  \
                        "${messages[@]}"
        fi
    fi

