#!/bin/bash
configESDE(){
	reset=$1	

	if [[ $reset == 'reset' ]]; then
		setMSG "Resetting EmulationStation DE..."
	else
		setMSG "Configuring EmulationStation DE..."
	fi
	mkdir -p ~/.emulationstation/
	mkdir -p ~/.emulationstation/custom_systems/
	es_systemsFile="$HOME/.emulationstation/custom_systems/es_systems.xml"
	es_settingsFile="$HOME/.emulationstation/es_settings.xml"

	#Custom Systems config Begin
	if [[ ! -f "$es_systemsFile" || $reset == "true" ]];  then
		cp ~/dragoonDoriseTools/EmuDeck/configs/emulationstation/custom_systems/es_systems.xml $es_systemsFile
	fi

	#update cemu custom system launcher to correct path by just replacing the line, if it exists.
	commandString="/usr/bin/bash ${toolsPath}launchers/cemu.sh -f -g z:%ROM%"
	xmlstarlet ed -L -u '/systemList/system/command[@label="Cemu (Proton)"]' -v "$commandString" $es_systemsFile

	#insert cemu custom system if it doesn't exist, but the file does
	if [[ $(grep -rnw $es_systemsFile -e 'Cemu (Proton)') == "" ]]; then
		xmlstarlet ed --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'wiiu' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Nintendo Wii U' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/wiiu/roms' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.rpx .RPX .wud .WUD .wux .WUX .elf .ELF .iso .ISO .wad .WAD .wua .WUA' \
		--subnode '$newSystem' --type elem --name 'command' -v "/usr/bin/bash ${toolsPath}launchers/cemu.sh -f -g z:%ROM%" \
		--insert '$newSystem/command' --type attr --name 'label' --value "Cemu (Proton)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'wiiu' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'wiiu' \
		$es_systemsFile
	fi
	#Custom Systems config end

	#update es_settings.xml
	if [[ ! -f "$es_settingsFile" || $reset == 'reset' ]];  then
		cp ~/dragoonDoriseTools/EmuDeck/configs/emulationstation/es_settings.xml $es_settingsFile
	fi

	#configure roms Directory
	esDE_romDir="<string name=\"ROMDirectory\" value=\""${romsPath}"\" />"

	sed -i "/<string name=\"ROMDirectory\"/c\\${esDE_romDir}" $es_settingsFile
	
	
	#Configure Downloaded_media folder
	esDE_MediaDir="<string name=\"MediaDirectory\" value=\""${ESDEscrapData}"\" />"
	#search for media dir in xml, if not found, change to ours. If it's blank, also change to ours.
	mediaDirFound=$(grep -rnw  $es_settingsFile -e 'MediaDirectory')
	mediaDirEmpty=$(grep -rnw  $es_settingsFile -e '<string name="MediaDirectory" value="" />')
	if [[ $mediaDirFound == '' ]]; then
		sed -i -e '$a'"${esDE_MediaDir}"  $es_settingsFile # use config file instead of link
	elif [[ ! $mediaDirEmpty == '' ]]; then
		sed -i "/<string name=\"MediaDirectory\" value=\"\" \/>/c\\${esDE_MediaDir}" $es_settingsFile
	fi

	#We check if we have downloaded_media data on ESDE so we can move it to the SD card

	originalESMediaFolder="$HOME/.emulationstation/downloaded_media"
	echo "processing $originalESMediaFolder"
	if [ -L ${originalESMediaFolder} ] ; then
		echo "link found"
		unlink ${originalESMediaFolder} && echo "unlinked"
	elif [ -e ${originalESMediaFolder} ] ; then
		if [ -d "${originalESMediaFolder}" ]; then		
			echo -e ""
			echo -e "Moving EmulationStation-DE downloaded_media to $toolsPath"			
			echo -e ""
			rsync -a $originalESMediaFolder $toolsPath  && rm -rf $originalESMediaFolder		#move it, merging files if in both locations
		fi
	else
		echo "downloaded_media not found on original location"
	fi


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
			ans=$?	
			if [ $ans -eq 0 ]; then
				echo "Theme selected" 
			fi
		fi
	fi

	mkdir -p ~/.emulationstation/themes/
	git clone https://github.com/dragoonDorise/es-theme-epicnoir.git ~/.emulationstation/themes/es-epicnoir &>> /dev/null
	cd ~/.emulationstation/themes/es-epicnoir && git pull
	echo -e "OK!"
	
	#Do this properly with wildcards
	if [[ "$esdeTheme" == *"EPICNOIR"* ]]; then
		sed -i "s|rbsimple-DE|es-epicnoir|" $es_settingsFile 
		sed -i "s|modern-DE|es-epicnoir|" $es_settingsFile 
		sed -i "s|es-epicnoir|es-epicnoir|" $es_settingsFile 
	fi
	if [[ "$esdeTheme" == *"MODERN-DE"* ]]; then
		sed -i "s|rbsimple-DE|modern-DE|" $es_settingsFile 
		sed -i "s|modern-DE|modern-DE|" $es_settingsFile 
		sed -i "s|es-epicnoir|modern-DE|" $es_settingsFile 
	fi
	if [[ "$esdeTheme" == *"RBSIMPLE-DE"* ]]; then
		sed -i "s|rbsimple-DE|rbsimple-DE|" $es_settingsFile 
		sed -i "s|modern-DE|rbsimple-DE|" $es_settingsFile 
		sed -i "s|es-epicnoir|rbsimple-DE|" $es_settingsFile 
	fi
	
	
	#ESDE default emulators
	mkdir -p  ~/.emulationstation/gamelists/
	setESDEEmus 'Dolphin (Standalone)' gc
	setESDEEmus 'PPSSPP (Standalone)' psp
	setESDEEmus 'Dolphin (Standalone)' wii
	setESDEEmus 'PCSX2 (Standalone)' ps2
	setESDEEmus 'melonDS' nds
	setESDEEmus 'Citra (Standalone)' n3ds

	#Symlinks for ESDE compatibility
	cd $(echo $romsPath | tr -d '\r') 
	ln -sn gamecube gc 
	ln -sn 3ds n3ds 
	ln -sn arcade mamecurrent 
	ln -sn mame mame2003 
	ln -sn lynx atarilynx 

}