#!/bin/bash
installESDE(){		
	
	setMSG "${installString} EmulationStation Desktop Edition"
	curl https://gitlab.com/leonstyhre/emulationstation-de/-/raw/master/es-app/assets/latest_steam_deck_appimage.txt --output "$toolsPath"/latesturl.txt 
	latestURL=$(grep "https://gitlab" "$toolsPath"/latesturl.txt)
	
	#New repo if the other fails
	if [ -z $latestURL ]; then
		curl https://gitlab.com/es-de/emulationstation-de/-/raw/master/es-app/assets/latest_steam_deck_appimage.txt --output "$toolsPath"/latesturl.txt 
		latestURL=$(grep "https://gitlab" "$toolsPath"/latesturl.txt)
	fi
		curl $latestURL --output "$toolsPath"/EmulationStation-DE-x64_SteamDeck.AppImage 
		rm "$toolsPath"/latesturl.txt
		chmod +x "$toolsPath"/EmulationStation-DE-x64_SteamDeck.AppImage	
	if [[ $doESDEThemePicker == true ]]; then
		if [[ $expert == true ]]; then	
			text="Which theme do you want to set as default on EmulationStation DE?"
			esdeTheme=$(zenity --list \
			--title="EmuDeck" \
			--height=250 \
			--width=250 \
			--ok-label="OK" \
			--cancel-label="Exit" \
			--text="${text}" \
			--radiolist \
			--column="" \
			--column="Theme" \
			1 "EPICNOIR" \
			2 "MODERN-DE" \
			3 "RBSIMPLE-DE" 2>/dev/null)
			clear
			ans=$?	
			if [ $ans -eq 0 ]; then
				echo "Theme selected" 
			fi
		fi
	fi
	
	#We check if we have scrapped data on ESDE so we can move it to the SD card
	#We do this wether the user wants to install ESDE or not to account for old users that might have ESDE already installed and won't update
	#Leon requested we use his config instead of symlink
	
	originalESMediaFolder="$HOME/.emulationstation/downloaded_media"
	echo "processing $originalESMediaFolder"
	if [ -L ${originalESMediaFolder} ] ; then
		echo "link found"
		unlink ${originalESMediaFolder} && echo "unlinked"
	elif [ -e ${originalESMediaFolder} ] ; then
		if [ -d "$HOME/.emulationstation/downloaded_media" ]; then		
			echo -e ""
			echo -e "Moving EmulationStation-DE downloaded_media to $toolsPath"			
			echo -e ""
			rsync -a $originalESMediaFolder $toolsPath  && rm -rf $originalESMediaFolder		#move it, merging files if in both locations
		fi
	else
		echo "downloaded_media not found on original location"
	fi
	
	
	
	#Configure Downloaded_media folder
	esDE_MediaDir="<string name=\"MediaDirectory\" value=\""${ESDEscrapData}"\" />"
	#search for media dir in xml, if not found, change to ours.
	mediaDirFound=$(grep -rnw $HOME/.emulationstation/es_settings.xml -e 'MediaDirectory')
	if [[ $mediaDirFound == '' ]]; then
		sed -i -e '$a'"${esDE_MediaDir}"  ~/.emulationstation/es_settings.xml # use config file instead of link
	fi	
	
	
}