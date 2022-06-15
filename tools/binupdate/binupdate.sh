#!/bin/bash
#while this is in testing, i'm copying in the functions. once we leave the original repo in place and don't delete it, i'd like to use the functions we already made.
installESDE(){		


    #New repo

    curl https://gitlab.com/es-de/emulationstation-de/-/raw/master/es-app/assets/latest_steam_deck_appimage.txt --output "$toolsPath"/latesturl.txt 
    latestURL=$(grep "https://gitlab" "$toolsPath"/latesturl.txt)

    curl $latestURL --output "$toolsPath"/EmulationStation-DE-x64_SteamDeck.AppImage 
    rm "$toolsPath"/latesturl.txt
    chmod +x "$toolsPath"/EmulationStation-DE-x64_SteamDeck.AppImage	

}

installSRM(){		
	#setMSG "${installString} Steam Rom Manager"
	rm -f ~/Desktop/Steam-ROM-Manager-2.3.29.AppImage
	rm -f ~/Desktop/Steam-ROM-Manager.AppImage
	mkdir -p "${toolsPath}"srm
	curl -L "$(curl -s https://api.github.com/repos/SteamGridDB/steam-rom-manager/releases/latest | grep -E 'browser_download_url.*AppImage' | grep -ve 'i386' | cut -d '"' -f 4)" > "${toolsPath}"srm/Steam-ROM-Manager.AppImage
	chmod +x "${toolsPath}"srm/Steam-ROM-Manager.AppImage	
}
	#paths update via sed in main script
	romsPath="/run/media/mmcblk0p1/Emulation/roms/"
	toolsPath="/run/media/mmcblk0p1/Emulation/tools/"
	scriptPath="${toolsPath}binupdate/"
	
	#initialize log
	TIMESTAMP=`date "+%Y%m%d_%H%M%S"`
	LOGFILE="${scriptPath}binupdate-$TIMESTAMP.log"
	exec > >(tee ${LOGFILE}) 2>&1
	
    binTable=()
    binTable+=(TRUE "EmulationStation-DE" "esde")
    binTable+=(TRUE "Steam Rom Manager" "srm")
    binTable+=(TRUE "Nintendo Switch Emu" "yuzu")
    binTable+=(TRUE "Nintendo WiiU Emu" "cemu")
    binTable+=(FALSE "Xbox 360 Emu - TESTING ONLY" "xenia")

#Binary selector
    text="`printf "What tools do you want to get the latest version of?\n This tool will simply overwrite what you have with the newest available."`"
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

    if [ $ans -eq 0 ]; then
        echo "User selected: $binsToDL"
        if [[ "$binsToDL" == *"esde"* ]]; then
            installESDE
        fi
        if [[ "$binsToDL" == *"srm"* ]]; then
            installSRM
        fi
        if [[ "$binsToDL" == *"yuzu"* ]]; then
            mkdir -p $HOME/Applications
            cd $HOME/Applications
            url="$(curl -sL https://api.github.com/repos/yuzu-emu/yuzu-mainline/releases/latest | jq -r ".assets[].browser_download_url" | grep .AppImage\$)"
            wget -c "$url" -O "yuzu.AppImage" 
        fi
        if [[ "$binsToDL" == *"cemu"* ]]; then

            releasesStr=$(wget -O - https://cemu.info | awk 'BEGIN{
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

            releases=($releasesStr)

            releaseTable=()
            for release in ${releases[@]}; do
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

            curl $releaseChoice --output "$romsPath"wiiu/cemu.zip 


            mkdir -p "$romsPath"wiiu/tmp
            unzip -o "$romsPath"wiiu/cemu.zip -d "$romsPath"wiiu/tmp
            mv "$romsPath"wiiu/tmp/cemu_*/ "$romsPath"wiiu/tmp/cemu/
            rsync -avzh "$romsPath"wiiu/tmp/cemu/ "$romsPath"wiiu/
            rm -rf "$romsPath"wiiu/tmp 
            rm -f "$romsPath"wiiu/cemu.zip 	
        fi
        if [[ "$binsToDL" == *"xenia"* ]]; then
            curl -L https://github.com/xenia-project/release-builds-windows/releases/latest/download/xenia_master.zip --output "$romsPath"xbox360/xenia_master.zip 
            mkdir -p "$romsPath"xbox360/tmp
            unzip -o "$romsPath"xbox360/xenia_master.zip -d "$romsPath"xbox360/tmp 
            mv "$romsPath"xbox360/tmp/* "$romsPath"xbox360 
            rm -rf "$romsPath"xbox360/tmp 
            rm -f "$romsPath"xbox360/xenia_master.zip 	
        fi
    fi

