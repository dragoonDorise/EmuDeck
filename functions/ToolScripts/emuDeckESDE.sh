#!/bin/bash
#variables
ESDE_toolName="EmulationStation-DE"
ESDE_toolType="AppImage"
ESDE_toolPath="${toolsPath}/EmulationStation-DE-x64_SteamDeck.AppImage"
ESDE_releaseURL="https://gitlab.com/es-de/emulationstation-de/-/raw/master/es-app/assets/latest_steam_deck_appimage.txt"

es_systemsFile="$HOME/.emulationstation/custom_systems/es_systems.xml"
es_settingsFile="$HOME/.emulationstation/es_settings.xml"

#cleanupOlderThings
ESDE_cleanup(){
	echo "NYI"
}

#Install
ESDE_install(){
	setMSG "Installing $ESDE_toolName"		

    curl $ESDE_releaseURL --output "$toolsPath/latesturl.txt"
    latestURL=$(grep "https://gitlab" "$toolsPath/latesturl.txt")

    curl "$latestURL" --output "$ESDE_toolPath"
    rm "$toolsPath/latesturl.txt"
    chmod +x "$ESDE_toolPath"
	
}

#ApplyInitialSettings
ESDE_init(){

	setMSG "Setting up $ESDE_toolName"	

	mkdir -p "$HOME/.emulationstation/custom_systems/"

	rsync -avhp --mkpath "$EMUDECKGIT/configs/emulationstation/es_settings.xml" "$(dirname "$es_settingsFile")" --backup --suffix=.bak
	rsync -avhp --mkpath "$EMUDECKGIT/configs/emulationstation/custom_systems/es_systems.xml" "$(dirname "$es_systemsFile")" --backup --suffix=.bak

    ESDE_addCustomSystems
    ESDE_setEmulationFolder
    ESDE_setDefaultEmulators
    ESDE_applyTheme "$esdeTheme"
    ESDE_migrateDownloadedMedia
    ESDE_finalize
}



ESDE_update(){


	setMSG "Setting up $ESDE_toolName"	

	mkdir -p "$HOME/.emulationstation/custom_systems/"

	#update es_settings.xml
	rsync -avhp --mkpath "$EMUDECKGIT/configs/emulationstation/es_settings.xml" "$(dirname "$es_settingsFile")" --ignore-existing
	rsync -avhp --mkpath "$EMUDECKGIT/configs/emulationstation/custom_systems/es_systems.xml" "$(dirname "$es_systemsFile")" --ignore-existing

    ESDE_addCustomSystems
	ESDE_setEmulationFolder
    ESDE_setDefaultEmulators
    ESDE_applyTheme "$esdeTheme"
    ESDE_migrateDownloadedMedia
    ESDE_finalize
}

ESDE_addCustomSystems(){


	#insert cemu custom system if it doesn't exist, but the file does
	if [[ $(grep -rnw "$es_systemsFile" -e 'Cemu (Proton)') == "" ]]; then
		xmlstarlet ed --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'wiiu' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Nintendo Wii U' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/wiiu/roms' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.rpx .RPX .wud .WUD .wux .WUX .elf .ELF .iso .ISO .wad .WAD .wua .WUA' \
		--subnode '$newSystem' --type elem --name 'command' -v "/usr/bin/bash ${toolsPath}/launchers/cemu.sh -f -g z:%ROM%" \
		--insert '$newSystem/command' --type attr --name 'label' --value "Cemu (Proton)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'wiiu' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'wiiu' \
		"$es_systemsFile"
	fi
	#Custom Systems config end


}

#update
ESDE_applyTheme(){
    defaultTheme="EPICNOIR"
    local theme=$1
    if [[ "${theme}" == "" ]]; then
        echo "ESDE: applyTheme parameter not set."
        theme="$defaultTheme"
    fi
    echo "ESDE: applyTheme $theme"
    mkdir -p "$HOME/.emulationstation/themes/"
	git clone https://github.com/dragoonDorise/es-theme-epicnoir.git "$HOME/.emulationstation/themes/es-epicnoir" >> /dev/null
	cd "$HOME/.emulationstation/themes/es-epicnoir" && git reset --hard HEAD && git clean -f -d && git pull
	echo -e "OK!"
	
	if [[ "$theme" == *"EPICNOIR"* ]]; then
		changeLine '<string name="ThemeSet"' '<string name="ThemeSet" value="es-epicnoir" />' "$es_settingsFile" 
	fi
	if [[ "$theme" == *"MODERN-DE"* ]]; then
        changeLine '<string name="ThemeSet"' '<string name="ThemeSet" value="modern-DE" />' "$es_settingsFile" 
	fi
	if [[ "$theme" == *"RBSIMPLE-DE"* ]]; then
        changeLine '<string name="ThemeSet"' '<string name="ThemeSet" value="rbsimple-DE" />' "$es_settingsFile" 
	fi
}

#ConfigurePaths
ESDE_setEmulationFolder(){

    #update cemu custom system launcher to correct path by just replacing the line, if it exists.
	echo "updating $es_systemsFile"
	commandString="/usr/bin/bash ${toolsPath}/launchers/cemu.sh -f -g z:%ROM%"
	xmlstarlet ed -L -u '/systemList/system/command[@label="Cemu (Proton)"]' -v "$commandString" "$es_systemsFile"




	echo "updating $es_settingsFile"
	#configure roms Directory
	esDE_romDir="<string name=\"ROMDirectory\" value=\""${romsPath}"\" />" #roms
	
	changeLine '<string name="ROMDirectory"' "${esDE_romDir}" "$es_settingsFile"

	
	#Configure Downloaded_media folder
	esDE_MediaDir="<string name=\"MediaDirectory\" value=\""${ESDEscrapData}"\" />"
	#search for media dir in xml, if not found, change to ours. If it's blank, also change to ours.
	mediaDirFound=$(grep -rnw  "$es_settingsFile" -e 'MediaDirectory')
	mediaDirEmpty=$(grep -rnw  "$es_settingsFile" -e '<string name="MediaDirectory" value="" />')
	if [[ $mediaDirFound == '' ]]; then
		echo "adding ES-DE ${esDE_MediaDir}"
		sed -i -e '$a'"${esDE_MediaDir}"  "$es_settingsFile" # use config file instead of link
	elif [[ ! $mediaDirEmpty == '' ]]; then
		echo "setting ES-DE MediaDirectory to ${esDE_MediaDir}"
		changeLine '<string name="MediaDirectory"' "${esDE_MediaDir}" "$es_settingsFile"
	fi
}

ESDE_setDefaultEmulators(){
	#ESDE default emulators
	mkdir -p  "$HOME/.emulationstation/gamelists/"
	ESDE_setEmu 'Dolphin (Standalone)' gc
	ESDE_setEmu 'PPSSPP (Standalone)' psp
	ESDE_setEmu 'Dolphin (Standalone)' wii
	ESDE_setEmu 'PCSX2 (Standalone)' ps2
	ESDE_setEmu 'melonDS' nds
	ESDE_setEmu 'Citra (Standalone)' n3ds
}


ESDE_migrateDownloadedMedia(){

    echo "ESDE: Migrate Downloaded Media."

    originalESMediaFolder="$HOME/.emulationstation/downloaded_media"
    echo "processing $originalESMediaFolder"
    if [ -L "${originalESMediaFolder}" ] ; then
        echo "link found"
        unlink "${originalESMediaFolder}" && echo "unlinked"
    elif [ -e "${originalESMediaFolder}" ] ; then
        if [ -d "${originalESMediaFolder}" ]; then		
            echo -e ""
            echo -e "Moving EmulationStation-DE downloaded_media to $toolsPath"			
            echo -e ""
            rsync -a "$originalESMediaFolder" "$toolsPath/"  && rm -rf "$originalESMediaFolder"		#move it, merging files if in both locations
        fi
    else
        echo "downloaded_media not found on original location"
    fi
}

#finalExec - Extra stuff
ESDE_finalize(){
   	#Symlinks for ESDE compatibility
	cd $(echo $romsPath | tr -d '\r') 
	ln -sn gamecube gc 
	ln -sn 3ds n3ds 
	ln -sn arcade mamecurrent 
	ln -sn mame mame2003 
	ln -sn lynx atarilynx 
}



ESDE_setEmu(){		
	local emu=$1
	local system=$2
	local gamelistFile="$HOME/.emulationstation/gamelists/$system/gamelist.xml"
	if [ ! -f "$gamelistFile" ]; then
		mkdir -p "$HOME/.emulationstation/gamelists/$system" && cp "$EMUDECKGIT/configs/emulationstation/gamelists/$system/gamelist.xml" "$gamelistFile"
	else
		gamelistFound=$(grep -rnw $gamelistFile -e 'gameList')
		if [[ $gamelistFound == '' ]]; then
			sed -i -e '$a\<gameList />' $gamelistFile
		fi
		alternativeEmu=$(grep -rnw $gamelistFile -e 'alternativeEmulator')
		if [[ $alternativeEmu == '' ]]; then
			echo "<alternativeEmulator><label>$emu</label></alternativeEmulator>" >> $gamelistFile
		fi
		sed -i "s|<?xml version=\"1.0\">|<?xml version=\"1.0\"?>|g" $gamelistFile
	fi
}