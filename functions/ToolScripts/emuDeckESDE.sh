#!/bin/bash
#variables
ESDE_toolName="EmulationStation-DE"
ESDE_downloadedToolName="EmulationStation-DE-x64_SteamDeck.AppImage"
ESDE_toolType="AppImage"
ESDE_toolLocation="$HOME/Applications"
ESDE_toolPath="${ESDE_toolLocation}/EmulationStation-DE.AppImage"
ESDE_releaseURL="https://gitlab.com/es-de/emulationstation-de/-/package_files/76389058/download" #default URl in case of issues parsing json
ESDE_releaseMD5="b749b927d61317fde0250af9492a4b9f" #default hash
ESDE_prereleaseURL=""
ESDE_prereleaseMD5=""
ESDE_releaseJSON="https://gitlab.com/es-de/emulationstation-de/-/raw/master/latest_release.json"
ESDE_addSteamInputFile="$EMUDECKGIT/configs/steam-input/emulationstation-de_controller_config.vdf"
steam_input_templateFolder="$HOME/.steam/steam/controller_base/templates/"
es_systemsFile="$HOME/.emulationstation/custom_systems/es_systems.xml"
es_rulesFile="$HOME/.emulationstation/custom_systems/es_find_rules.xml"
es_settingsFile="$HOME/.emulationstation/es_settings.xml"


ESDE_SetAppImageURLS() {
    local json="$(curl -s $ESDE_releaseJSON)"
    ESDE_releaseURL=$(echo "$json" | jq -r '.stable.packages[] | select(.name == "LinuxSteamDeckAppImage") | .url')
	ESDE_releaseMD5=$(echo "$json" | jq -r '.stable.packages[] | select(.name == "LinuxSteamDeckAppImage") | .md5')
	ESDE_prereleaseURL=$(echo "$json" | jq -r '.prerelease.packages[] | select(.name == "LinuxSteamDeckAppImage") | .url')
	ESDE_prereleaseMD5=$(echo "$json" | jq -r '.prerelease.packages[] | select(.name == "LinuxSteamDeckAppImage") | .md5')
}

#cleanupOlderThings
ESDE_cleanup(){
	echo "NYI"
}

ESDE_migration(){

	if [ -f "${toolsPath}/$ESDE_downloadedToolName" ] && [ ! -L "${toolsPath}/$ESDE_downloadedToolName" ]; then
		mv "${toolsPath}/$ESDE_downloadedToolName" "$ESDE_toolPath"
		sed -i "s|$ESDE_downloadedToolName|$ESDE_toolName|g" "$ESDE_toolLocation/launchers/esde/emulationstationde.sh"
		echo "$ESDE_toolName successfully migrated and linked."
	fi

	if [ -f "${toolsPath}/$ESDE_toolName.AppImage" ] && [ ! -L "${toolsPath}/$ESDE_toolName.AppImage" ]; then

		mv "${toolsPath}/$ESDE_toolName.AppImage" "$ESDE_toolPath"
		ln -s  "$ESDE_toolPath" "${toolsPath}/$ESDE_toolName.AppImage"
		echo "$ESDE_toolName successfully migrated and linked."
	fi

}

ESDE_createDesktopShortcut(){

	mkdir -p "$toolsPath/launchers/esde"
	cp "$EMUDECKGIT/tools/launchers/esde/emulationstationde.sh" "$toolsPath/launchers/esde/emulationstationde.sh"
	rm -rf $HOME/.local/share/applications/$ESDE_toolName.desktop
	createDesktopShortcut   "$HOME/.local/share/applications/$ESDE_toolName.desktop" \
	"$ESDE_toolName AppImage" \
	"${toolsPath}/launchers/esde/emulationstationde.sh" \
	"false"
}

ESDE_uninstall(){
  rm -rf "${toolsPath}/$ESDE_toolName.AppImage"
  rm -rf "${toolsPath}/$ESDE_downloadedToolName"
  rm -rf "$ESDE_toolPath"
  rm -rf $HOME/.local/share/applications/$ESDE_toolName.desktop
}

#Install
ESDE_install(){
	setMSG "Installing $ESDE_toolName"

	# Move ES-DE to ~/Applications folder
	ESDE_migration
	
	ESDE_SetAppImageURLS
	local showProgress="$1"
	echo $ESDE_releaseURL
	if [[ $ESDE_releaseURL = "https://gitlab.com/es-de/emulationstation-de/-/package_files/"* ]]; then
		if safeDownload "$ESDE_toolName" "$ESDE_releaseURL" "$ESDE_toolPath" "$showProgress"; then
			chmod +x "$ESDE_toolPath"
			ESDE_createDesktopShortcut
		else
			return 1
		fi
	else 
		setMSG "$ESDE_toolName not found"
		return 1
	fi
}

#ApplyInitialSettings
ESDE_init(){
	setMSG "Setting up $ESDE_toolName"

	mkdir -p "$HOME/.emulationstation/custom_systems/"

	rsync -avhp --mkpath "$EMUDECKGIT/configs/emulationstation/es_settings.xml" "$(dirname "$es_settingsFile")" --backup --suffix=.bak
	rsync -avhp --mkpath "$EMUDECKGIT/configs/emulationstation/custom_systems/es_systems.xml" "$(dirname "$es_systemsFile")" --backup --suffix=.bak

	cp -r "$EMUDECKGIT/tools/launchers/esde/." "$toolsPath/launchers/esde/" && chmod +x "$toolsPath/launchers/esde/emulationstationde.sh"

	ESDE_addCustomSystems
	ESDE_setEmulationFolder
	ESDE_setDefaultEmulators
	ESDE_applyTheme  "$esdeThemeUrl" "$esdeThemeName"
	ESDE_migrateDownloadedMedia
	#ESDE_addSteamInputProfile
	ESDE_symlinkGamelists
	ESDE_migrateEpicNoir
	ESDE_migration

	if [ "$system" == "chimeraos" ] || [ "$system" == "ChimeraOS" ]; then
			ESDE_chimeraOS
		fi
}

ESDE_chimeraOS(){
	if [ ! -f "$es_rulesFile" ]; then
		rsync -avhp --mkpath "$EMUDECKGIT/chimeraOS/configs/emulationstation/custom_systems/es_find_rules.xml" "$(dirname "$es_rulesFile")" --backup --suffix=.bak
	else
		xmlstarlet ed -d '//entry[contains(., "~/Applications/RetroArch-Linux*.AppImage") or contains(., "~/.local/share/applications/RetroArch-Linux*.AppImage") or contains(., "~/.local/bin/RetroArch-Linux*.AppImage") or contains(., "~/bin/RetroArch-Linux*.AppImage")]' $es_rulesFile > rules_temp.xml && mv rules_temp.xml $es_rulesFile
	fi
}

ESDE_resetConfig(){
	ESDE_init &>/dev/null && echo "true" || echo "false"
}

# ESDE20_init(){
# 	ESDE_init
# }

ESDE_update(){
	setMSG "Setting up $ESDE_toolName"

	mkdir -p "$HOME/.emulationstation/custom_systems/"

	#update es_settings.xml
	rsync -avhp --mkpath "$EMUDECKGIT/configs/emulationstation/es_settings.xml" "$(dirname "$es_settingsFile")" --ignore-existing
	rsync -avhp --mkpath "$EMUDECKGIT/configs/emulationstation/custom_systems/es_systems.xml" "$(dirname "$es_systemsFile")" --ignore-existing

	ESDE_addCustomSystems
	ESDE_setEmulationFolder
	ESDE_setDefaultEmulators
	ESDE_applyTheme "$esdeThemeUrl" "$esdeThemeName"
	ESDE_migrateDownloadedMedia
	#ESDE_addSteamInputProfile
	ESDE_symlinkGamelists
	ESDE_migration
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
		--subnode '$newSystem' --type elem --name 'commandP' -v "/bin/bash ${toolsPath}/launchers/cemu.sh -f -g z:%ROM%" \
		--insert '$newSystem/commandP' --type attr --name 'label' --value "Cemu (Native)" \
		--subnode '$newSystem' --type elem --name 'commandN' -v "/bin/bash ${toolsPath}/launchers/cemu.sh -w -f -g %ROM%" \
		--insert '$newSystem/commandN' --type attr --name 'label' --value "Cemu (Proton)" \
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
	local themeUrl=$1
	local themeName=$2

	echo "ESDE: applyTheme $themeName"
	mkdir -p "$HOME/.emulationstation/themes/"
	if [ -d "$HOME/.emulationstation/themes/$themeName" ]; then
		cd "$HOME/.emulationstation/themes/$themeName" && git pull
	else
		git clone $themeUrl "$HOME/.emulationstation/themes/"
	fi

	updateOrAppendConfigLine "$es_settingsFile" "<string name=\"ThemeSet\"" "<string name=\"ThemeSet\" value=\"\""
	updateOrAppendConfigLine "$es_settingsFile" "<string name=\"Theme\"" "<string name=\"Theme\" value=\"\""

	sed -i "s/<string name=\"ThemeSet\" value=\"[^\"]*\"/<string name=\"ThemeSet\" value=\"$themeName\"\/>/" "$es_settingsFile"
	sed -i "s/<string name=\"Theme\" value=\"[^\"]*\"/<string name=\"Theme\" value=\"$themeName\"\/>/" "$es_settingsFile"
}

#ConfigurePaths
ESDE_setEmulationFolder(){
	#update cemu custom system launcher to correct path by just replacing the line, if it exists.
	echo "updating $es_systemsFile"

	#insert new commands
	if [[ ! $(grep -rnw "$es_systemsFile" -e 'wiiu') == "" ]]; then
		if [[ $(grep -rnw "$es_systemsFile" -e 'Cemu (Proton)') == "" ]]; then
			#insert
			xmlstarlet ed -S --inplace --subnode 'systemList/system[name="wiiu"]' --type elem --name 'commandP' -v "/bin/bash ${toolsPath}/launchers/cemu.sh -w -f -g z:%ROM%" \
			--insert 'systemList/system/commandP' --type attr --name 'label' --value "Cemu (Proton)" \
			-r 'systemList/system/commandP' -v 'command' \
			"$es_systemsFile"

			#format doc to make it look nice
			xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
		else
			#update
			cemuProtonCommandString="/bin/bash ${toolsPath}/launchers/cemu.sh -w -f -g z:%ROM%"
			xmlstarlet ed -L -u '/systemList/system/command[@label="Cemu (Proton)"]' -v "$cemuProtonCommandString" "$es_systemsFile"
		fi
		if [[ $(grep -rnw "$es_systemsFile" -e 'Cemu (Native)') == "" ]]; then
			#insert
			xmlstarlet ed -S --inplace --subnode 'systemList/system[name="wiiu"]' --type elem --name 'commandN' -v "/bin/bash ${toolsPath}/launchers/cemu.sh -f -g %ROM%" \
			--insert 'systemList/system/commandN' --type attr --name 'label' --value "Cemu (Native)" \
			-r 'systemList/system/commandN' -v 'command' \
			"$es_systemsFile"

			#format doc to make it look nice
			xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
		else
			#update
			cemuNativeCommandString="/bin/bash ${toolsPath}/launchers/cemu.sh -f -g %ROM%"
			xmlstarlet ed -L -u '/systemList/system/command[@label="Cemu (Native)"]' -v "$cemuNativeCommandString" "$es_systemsFile"
		fi
	fi
	if [[ ! $(grep -rnw "$es_systemsFile" -e 'xbox360') == "" ]]; then
		if [[ $(grep -rnw "$es_systemsFile" -e 'Xenia (Proton)') == "" ]]; then
			#insert
			xmlstarlet ed -S --inplace --subnode 'systemList/system[name="xbox360"]' --type elem --name 'commandP' -v "/bin/bash ${toolsPath}/launchers/xenia.sh %ROM%" \
			--insert 'systemList/system/commandP' --type attr --name 'label' --value "Xenia (Proton)" \
			-r 'systemList/system/commandP' -v 'command' \
			"$es_systemsFile"

			#format doc to make it look nice
			xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
		else
			#update
			xeniaProtonCommandString="/bin/bash ${toolsPath}/launchers/xenia.sh %ROM%"
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
	ESDE_setEmu 'Dolphin (Standalone)' gamecube
	ESDE_setEmu 'PPSSPP (Standalone)' psp
	ESDE_setEmu 'Dolphin (Standalone)' wii
	ESDE_setEmu 'PCSX2 (Standalone)' ps2
	ESDE_setEmu 'melonDS' nds
	ESDE_setEmu 'Citra (Standalone)' /3ds
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
			echo -e "Moving $ESDE_toolName downloaded_media to $toolsPath"
			echo -e ""
			rsync -a "$originalESMediaFolder" "$toolsPath/"  && rm -rf "$originalESMediaFolder"		#move it, merging files if in both locations
		fi
	else
		echo "downloaded_media not found on original location"
	fi
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
	#setMSG "Adding $ESDE_toolName Steam Input Profile."
		#rsync -r "$ESDE_addSteamInputFile" "$steam_input_templateFolder"
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