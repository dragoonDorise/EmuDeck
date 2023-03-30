#!/bin/bash
#variables
ESDE_toolName="EmulationStation-DE"
ESDE_toolType="AppImage"
ESDE_toolPath="${toolsPath}/EmulationStation-DE-x64_SteamDeck.AppImage"
ESDE_releaseURL="https://gitlab.com/es-de/emulationstation-de/-/raw/master/es-app/assets/latest_steam_deck_appimage.txt"
ESDE_prereleaseURL="https://gitlab.com/es-de/emulationstation-de/-/raw/master/es-app/assets/latest_steam_deck_prerelease_appimage.txt"

es_systemsFile="$HOME/.emulationstation/custom_systems/es_systems.xml"
es_settingsFile="$HOME/.emulationstation/es_settings.xml"

#cleanupOlderThings
ESDE_cleanup(){
	echo "NYI"
}

#Install
ESDE_install(){
	setMSG "Installing $ESDE_toolName"

	local showProgress="$1"

	curl $ESDE_releaseURL --output "$toolsPath/latesturl.txt"
	local latestURL=$(grep "https://gitlab.com/es-de/emulationstation-de/-/package_files/" "$toolsPath/latesturl.txt")

	if [[ $latestURL = "https://gitlab.com/es-de/emulationstation-de/-/package_files/"* ]]; then
		echo "downloading $latestURL"
		#curl "$latestURL" --output "$ESDE_toolPath"
		if safeDownload "$ESDE_toolName" "$latestURL" "$ESDE_toolPath" "$showProgress"; then
			rm "$toolsPath/latesturl.txt"
			chmod +x "$ESDE_toolPath"
		else
			return 1
		fi
	else
		setMSG "$ESDE_toolName not found"
		return 1
	fi	
}

ESDE20_install(){
	setMSG "Installing $ESDE_toolName PreRelease"

	local showProgress="$1"

	curl $ESDE_prereleaseURL --output "$toolsPath/latesturl.txt"
	local latestURL=$(grep "https://gitlab.com/es-de/emulationstation-de/-/package_files/" "$toolsPath/latesturl.txt")

	if [[ $latestURL = "https://gitlab.com/es-de/emulationstation-de/-/package_files/"* ]]; then
		echo "downloading $latestURL"
		#curl "$latestURL" --output "$ESDE_toolPath"
		if safeDownload "$ESDE_toolName PreRelease" "$latestURL" "$ESDE_toolPath" "$showProgress"; then
			rm "$toolsPath/latesturl.txt"
			chmod +x "$ESDE_toolPath"
		else
			return 1
		fi
	else
		setMSG "$ESDE_toolName PreRelease not found, installing stable"
		if ESDE_install; then
			:
		else
			return 1
		fi
	fi
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
	ESDE_addSteamInputProfile
	ESDE_symlinkGamelists
	ESDE_finalize
	ESDE_migrateEpicNoir
}


ESDE_resetConfig(){
	ESDE_init &>/dev/null && echo "true" || echo "false"
}

ESDE20_init(){
	ESDE_init
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
	ESDE_addSteamInputProfile
	ESDE_symlinkGamelists
	ESDE_finalize
}

ESDE_addCustomSystems(){
	#insert cemu custom system if it doesn't exist, but the file does
	if [[ $(grep -rnw "$es_systemsFile" -e 'wiiu') == "" ]]; then
		xmlstarlet ed -S --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'wiiu' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Nintendo Wii U' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/wiiu/roms' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.rpx .RPX .wud .WUD .wux .WUX .elf .ELF .iso .ISO .wad .WAD .wua .WUA' \
		--subnode '$newSystem' --type elem --name 'commandP' -v "/usr/bin/bash ${toolsPath}/launchers/cemu.sh -w -f -g z:%ROM%" \
		--insert '$newSystem/commandP' --type attr --name 'label' --value "Cemu (Proton)" \
		--subnode '$newSystem' --type elem --name 'commandN' -v "/usr/bin/bash ${toolsPath}/launchers/cemu.sh -f -g %ROM%" \
		--insert '$newSystem/commandN' --type attr --name 'label' --value "Cemu (Native)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'wiiu' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'wiiu' \
		-r 'systemList/system/commandP' -v 'command' \
		-r 'systemList/system/commandN' -v 'command' \
		"$es_systemsFile"

		#format doc to make it look nice
		xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
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
	git clone https://github.com/anthonycaccese/epic-noir-revisited-es-de "$HOME/.emulationstation/themes/epic-noir-revisited" --depth=1
	cd "$HOME/.emulationstation/themes/epic-noir-revisited" && git reset --hard HEAD && git clean -f -d && git pull && echo  "epicnoir up to date!" || echo "problem pulling epicnoir theme"
	
	if [[ "$theme" == *"EPICNOIR"* ]]; then
		changeLine '<string name="ThemeSet"' '<string name="ThemeSet" value="es-epicnoir" />' "$es_settingsFile"
	fi
	if [[ "$theme" == *"MODERN-DE"* ]]; then
		changeLine '<string name="ThemeSet"' '<string name="ThemeSet" value="modern-es-de" />' "$es_settingsFile"
	fi
	if [[ "$theme" == *"RBSIMPLE-DE"* ]]; then
		changeLine '<string name="ThemeSet"' '<string name="ThemeSet" value="slate-es-de" />' "$es_settingsFile"
	fi
}

#ConfigurePaths
ESDE_setEmulationFolder(){
	#update cemu custom system launcher to correct path by just replacing the line, if it exists.
	echo "updating $es_systemsFile"

	#insert new commands
	if [[ ! $(grep -rnw "$es_systemsFile" -e 'wiiu') == "" ]]; then
		if [[ $(grep -rnw "$es_systemsFile" -e 'Cemu (Proton)') == "" ]]; then
			#insert
			xmlstarlet ed -S --inplace --subnode 'systemList/system[name="wiiu"]' --type elem --name 'commandP' -v "/usr/bin/bash ${toolsPath}/launchers/cemu.sh -w -f -g z:%ROM%" \
			--insert 'systemList/system/commandP' --type attr --name 'label' --value "Cemu (Proton)" \
			-r 'systemList/system/commandP' -v 'command' \
			"$es_systemsFile"

			#format doc to make it look nice
			xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
		else
			#update
			cemuProtonCommandString="/usr/bin/bash ${toolsPath}/launchers/cemu.sh -w -f -g z:%ROM%"
			xmlstarlet ed -L -u '/systemList/system/command[@label="Cemu (Proton)"]' -v "$cemuProtonCommandString" "$es_systemsFile"
		fi
		if [[ $(grep -rnw "$es_systemsFile" -e 'Cemu (Native)') == "" ]]; then
			#insert
			xmlstarlet ed -S --inplace --subnode 'systemList/system[name="wiiu"]' --type elem --name 'commandN' -v "/usr/bin/bash ${toolsPath}/launchers/cemu.sh -f -g %ROM%" \
			--insert 'systemList/system/commandN' --type attr --name 'label' --value "Cemu (Native)" \
			-r 'systemList/system/commandN' -v 'command' \
			"$es_systemsFile"

			#format doc to make it look nice
			xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
		else
			#update
			cemuNativeCommandString="/usr/bin/bash ${toolsPath}/launchers/cemu.sh -f -g %ROM%"
			xmlstarlet ed -L -u '/systemList/system/command[@label="Cemu (Native)"]' -v "$cemuNativeCommandString" "$es_systemsFile"
		fi
	fi
	if [[ ! $(grep -rnw "$es_systemsFile" -e 'xbox360') == "" ]]; then
		if [[ $(grep -rnw "$es_systemsFile" -e 'Xenia (Proton)') == "" ]]; then
			#insert
			xmlstarlet ed -S --inplace --subnode 'systemList/system[name="xbox360"]' --type elem --name 'commandP' -v "/usr/bin/bash ${toolsPath}/launchers/xenia.sh %ROM%" \
			--insert 'systemList/system/commandP' --type attr --name 'label' --value "Xenia (Proton)" \
			-r 'systemList/system/commandP' -v 'command' \
			"$es_systemsFile"

			#format doc to make it look nice
			xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
		else
			#update
			xeniaProtonCommandString="/usr/bin/bash ${toolsPath}/launchers/xenia.sh %ROM%"
			xmlstarlet ed -L -u '/systemList/system/command[@label="Xenia (Proton)"]' -v "$xeniaProtonCommandString" "$es_systemsFile"
		fi
	fi

	echo "updating $es_settingsFile"
	#configure roms Directory
	esDE_romDir="<string name=\"ROMDirectory\" value=\"${romsPath}\" />" #roms
	
	changeLine '<string name="ROMDirectory"' "${esDE_romDir}" "$es_settingsFile"
	
	#Configure Downloaded_media folder
	esDE_MediaDir="<string name=\"MediaDirectory\" value=\"${ESDEscrapData}\" />"
	#search for media dir in xml, if not found, change to ours. If it's blank, also change to ours.
	mediaDirFound=$(grep -rnw  "$es_settingsFile" -e 'MediaDirectory')
	mediaDirEmpty=$(grep -rnw  "$es_settingsFile" -e '<string name="MediaDirectory" value="" />')
	mediaDirEmulation=$(grep -rnw  "$es_settingsFile" -e 'Emulation/tools/downloaded_media')
	if [[ $mediaDirFound == '' ]]; then
		echo "adding ES-DE ${esDE_MediaDir}"
		sed -i -e '$a'"${esDE_MediaDir}"  "$es_settingsFile" # use config file instead of link
	elif [[ -z $mediaDirEmpty || -n $mediaDirEmulation ]]; then
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
	ESDE_setEmu 'Beetle Lynx' atarilynx
	ESDE_setEmu 'DuckStation (Standalone)' psx
	ESDE_setEmu 'Beetle Saturn' saturn
	ESDE_setEmu 'ScummVM (Standalone)' scummvm
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
		gamelistFound=$(grep -rnw "$gamelistFile" -e 'gameList')
		if [[ $gamelistFound == '' ]]; then
			sed -i -e '$a\<gameList />' "$gamelistFile"
		fi
		alternativeEmu=$(grep -rnw "$gamelistFile" -e 'alternativeEmulator')
		if [[ $alternativeEmu == '' ]]; then
			echo "<alternativeEmulator><label>$emu</label></alternativeEmulator>" >> "$gamelistFile"
		fi
		sed -i "s|<?xml version=\"1.0\">|<?xml version=\"1.0\"?>|g" "$gamelistFile"
	fi
}

ESDE_addSteamInputProfile(){
	addSteamInputCustomIcons
	setMSG "Adding $ESDE_toolName Steam Input Profile."
	rsync -r "$EMUDECKGIT/configs/steam-input/emulationstation-de_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

ESDE_IsInstalled(){
	if [ -e "$ESDE_toolPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

ESDE_symlinkGamelists(){
		linkToSaveFolder es-de gamelists "$HOME/.emulationstation/gamelists/"
}


ESDE_migrateEpicNoir(){
	FOLDER="$HOME/.emulationstation/themes/es-epicnoir"
	
	if [ -f "$FOLDER" ]; then
		rm -rf "$FOLDER"
		git clone https://github.com/anthonycaccese/epic-noir-revisited-es-de "$HOME/.emulationstation/themes/epic-noir-revisited" --depth=1
		changeLine '<string name="ThemeSet"' '<string name="ThemeSet" value="epic-noir-revisited-es-de" />' "$es_settingsFile"	
	fi
}