#!/usr/bin/env bash
#variables
ESDE_toolName="ES-DE"
ESDE_oldtoolName="EmulationStation-DE"
ESDE_downloadedToolName="EmulationStation-DE-x64_SteamDeck.AppImage"
ESDE_toolType="$emuDeckEmuTypeAppImage"
ESDE_oldConfigDirectory="$ESDE_newConfigDirectory"
ESDE_newConfigDirectory="$HOME/ES-DE"
ESDE_toolLocation="$esdeFolder"
ESDE_toolPath="${ESDE_toolLocation}/ES-DE.AppImage"
ESDE_releaseURL="https://gitlab.com/es-de/emulationstation-de/-/package_files/76389058/download" #default URl in case of issues parsing json
ESDE_releaseMD5="b749b927d61317fde0250af9492a4b9f" #default hash
ESDE_prereleaseURL=""
ESDE_prereleaseMD5=""
ESDE_releaseJSON="https://gitlab.com/es-de/emulationstation-de/-/raw/master/latest_release.json"
ESDE_addSteamInputFile="$emudeckBackend/configs/steam-input/emulationstation-de_controller_config.vdf"
steam_input_templateFolder="$HOME/.steam/steam/controller_base/templates/"
es_systemsFile="$ESDE_newConfigDirectory/custom_systems/es_systems.xml"
es_settingsFile="$ESDE_newConfigDirectory/settings/es_settings.xml"
es_rulesFile="$ESDE_newConfigDirectory/custom_systems/es_find_rules.xml"


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

	if [ -d "$ESDE_oldConfigDirectory" ] && [ ! -L "$ESDE_oldConfigDirectory" ] && [ ! -d "$ESDE_newConfigDirectory" ]; then
		mv "$ESDE_oldConfigDirectory" "$ESDE_newConfigDirectory"
		ln -s  "$ESDE_newConfigDirectory" "$ESDE_oldConfigDirectory"
		echo "EmulationStation-DE config directory successfully migrated and linked."
	fi

	if [ -f "${toolsPath}/$ESDE_downloadedToolName" ] && [ ! -L "${toolsPath}/$ESDE_downloadedToolName" ]; then
		mv "${toolsPath}/$ESDE_downloadedToolName" "$ESDE_toolPath"
		ln -s  "$ESDE_toolPath" "${toolsPath}/EmulationStation-DE-x64_SteamDeck.AppImage"
		echo "$ESDE_toolName successfully migrated and linked."
	fi

	if [ -f "${toolsPath}/$ESDE_oldtoolName.AppImage" ] && [ ! -L "${toolsPath}/$ESDE_oldtoolName.AppImage" ]; then

		mv "${toolsPath}/$ESDE_oldtoolName.AppImage" "$ESDE_toolPath"
		ln -s  "$ESDE_toolPath" "${toolsPath}/$ESDE_oldtoolName.AppImage"
		echo "$ESDE_toolName successfully migrated and linked."
	fi

}

ESDE_customDesktopShortcut(){

    mkdir -p "$toolsPath/launchers/es-de"
    mkdir -p "$toolsPath/launchers/esde"
    cp "$emudeckBackend/tools/launchers/es-de/es-de.sh" "$toolsPath/launchers/es-de/es-de.sh"
    rm -rf $HOME/.local/share/applications/$ESDE_oldtoolName.desktop
    createDesktopShortcut   "$HOME/.local/share/applications/$ESDE_toolName.desktop" \
        "$ESDE_toolName AppImage" \
        "${toolsPath}/launchers/es-de/es-de.sh" \
        "false"
    ln -s "${toolsPath}/launchers/es-de/es-de.sh" "$toolsPath/launchers/esde/emulationstationde.sh"
}

ESDE_uninstall(){
  rm -rf "${toolsPath}/$ESDE_oldtoolName.AppImage"
  rm -rf "${toolsPath}/$ESDE_downloadedToolName"
  rm -rf "$ESDE_toolPath"
  rm -rf $HOME/.local/share/applications/$ESDE_toolName.desktop
}

#Install
ESDE_install(){
	setMSG "Installing $ESDE_toolName"
	mkdir -p $ESDE_toolLocation

	# Move ES-DE to ~/Applications folder
	ESDE_migration

	ESDE_SetAppImageURLS
	ESDE_migration

	local showProgress="$1"
	local esdeReleaseData=$(curl -fsSL "$ESDE_releaseJSON")

	ESDE_releaseURL=$(echo "$esdeReleaseData" | jq -r '.stable.packages[] | select(.name == "LinuxSteamDeckAppImage") | .url')
	
	if [ $CPUarch == "arm" ]; then
		ESDE_releaseURL=$(echo "$esdeReleaseData" | jq -r '.stable.packages[] | select(.name == "LinuxAArch64AppImage") | .url')
	fi
	
	echo "$ESDE_releaseURL"
	if [[ -n "$ESDE_releaseURL" ]]; then
		if safeDownload "$ESDE_toolName" "$ESDE_releaseURL" "$ESDE_toolPath" "$showProgress"; then
			chmod +x "$ESDE_toolPath"
			ESDE_customDesktopShortcut
		else
			return 1
		fi
	else
		setMSG "$ESDE_toolName not found"
		return 1
	fi
}

ESDE_addToSteam(){
	setMSG "Adding $ESDE_toolName to Steam"
	add_to_steam "es-de" "EmulationStationDE" "$toolsPath/launchers/es-de/es-de.sh" "$HOME/Applications/" "$HOME/.config/EmuDeck/backend/icons/ico/EmulationStationDE.ico" "Emulation" "true"
}

#ApplyInitialSettings
ESDE_init(){
	setMSG "Setting up $ESDE_toolName"
	ESDE_addToSteam
	ESDE_migration
	ESDE_junksettingsFile
	ESDE_addCustomSystemsFile

	mkdir -p "$ESDE_newConfigDirectory/settings"
	mkdir -p "$ESDE_newConfigDirectory/custom_systems/"
	rsync -avhp --mkpath "$emudeckBackend/configs/emulationstation/es_settings.xml" "$(dirname "$es_settingsFile")" --backup --suffix=.bak
	rsync -avhp --mkpath "$emudeckBackend/configs/emulationstation/custom_systems/es_find_rules.xml" "$(dirname "$es_rulesFile")" --backup --suffix=.bak
	# This duplicates ESDE_addCustomSystemsFile but this line only applies only if you are resetting ES-DE and not the emulators themselves.
	rsync -avhp --mkpath "$emudeckBackend/configs/emulationstation/custom_systems/es_systems.xml" "$(dirname "$es_systemsFile")" --backup --suffix=.bak

	ESDE_createLauncher
	
	ESDE_setEmulationFolder
	ESDE_setDefaultSettings
	ESDE_setDefaultEmulators
	ESDE_applyTheme  "$esdeThemeUrl" "$esdeThemeName"
	ESDE_migrateDownloadedMedia
	#ESDE_addSteamInputProfile
	ESDE_symlinkGamelists
	ESDE_migrateEpicNoir
	SRM_createParsers
	addSteamInputCustomIcons
	ESDE_flushToolLauncher
	SRM_flushOldSymlinks
	
	#Symlinks for windows migration
	ln -sfn "$ESDEscrapData/" "$storagePath/downloaded_media"
	
	ESDE_addCustomSystems
	sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" "$es_rulesFile"
	sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" "$es_systemsFile"
}

ESDE_createLauncher(){
 cp -r "$emudeckBackend/tools/launchers/es-de/." "$toolsPath/launchers/es-de/" && chmod +x "$toolsPath/launchers/es-de/es-de.sh"
}

ESDE_resetConfig(){
	ESDE_init &>/dev/null && echo "true" || echo "false"
}

# ESDE20_init(){
# 	ESDE_init
# }

ESDE_update(){
	setMSG "Setting up $ESDE_toolName"

	ESDE_migration
	ESDE_junksettingsFile

	if [ "$system" != "darwin" ]; then
		ESDE_addCustomSystemsFile

		mkdir -p "$ESDE_newConfigDirectory/custom_systems/"
		mkdir -p "$ESDE_newConfigDirectory/settings"

		#update es_settings.xml
		rsync -avhp --mkpath "$emudeckBackend/configs/emulationstation/es_settings.xml" "$(dirname "$es_settingsFile")" --ignore-existing
		rsync -avhp --mkpath "$emudeckBackend/configs/emulationstation/custom_systems/es_find_rules.xml" "$(dirname "$es_rulesFile")" --ignore-existing
		rsync -avhp --mkpath "$emudeckBackend/configs/emulationstation/custom_systems/es_systems.xml" "$(dirname "$es_systemsFile")" --ignore-existing

		ESDE_addCustomSystems
	fi
	ESDE_setEmulationFolder
	ESDE_setDefaultSettings
	ESDE_setDefaultEmulators
	ESDE_applyTheme "$esdeThemeUrl" "$esdeThemeName"
	ESDE_migrateDownloadedMedia
	#ESDE_addSteamInputProfile
	ESDE_symlinkGamelists
	addSteamInputCustomIcons
	ESDE_flushToolLauncher
}


ESDE_junksettingsFile(){

	local junkSettingsFile="$ESDE_newConfigDirectory/settings"
	local customSystemsFile="$ESDE_newConfigDirectory/custom_systems"

	if [ -f "$junkSettingsFile" ]; then
		rm -f "$junkSettingsFile"
		echo ""$junkSettingsFile" deleted."
	else
		echo ""$junkSettingsFile" does not exist."
	fi

	if [ -f "$customSystemsFile" ]; then
		rm -f "$customSystemsFile"
		echo ""$customSystemsFile" deleted."
	else
		echo ""$customSystemsFile" does not exist."
	fi


}

ESDE_addCustomSystemsFile(){

	# Separate function so it can be copied and used in the emulator scripts.
	mkdir -p "$ESDE_newConfigDirectory/custom_systems/"
	rsync -avhp --mkpath "$emudeckBackend/configs/emulationstation/custom_systems/es_systems.xml" "$(dirname "$es_systemsFile")" --ignore-existing

}


ESDE_addCustomSystems(){

	# Some reported issues where these custom systems are not always being applied properly. Added here as a fail-safe.

	BigPEmu_addESConfig
	CemuProton_addESConfig
	Model2_addESConfig
	Xenia_addESConfig
	Yuzu_addESConfig
	Citron_addESConfig
	ESDE_addArmCores
}

ESDE_addArmCores(){
	if [ "$CPUarch" != "arm" ]; then
		return
	fi
	sed -i "s|<!--armcores||g" "$es_systemsFile"
	sed -i "s|armcores-->||g" "$es_systemsFile"
	sed -i "s|<!--armcores||g" "$es_rulesFile"
	sed -i "s|armcores-->||g" "$es_rulesFile"
	sed -i "s|PCSX2|ARMSX2|g" "$ESDE_newConfigDirectory/gamelists/ps2/gamelist.xml"
	
}

#update
ESDE_applyTheme(){
	local themeUrl=$1
	local themeName=$2

	echo "ESDE: applyTheme $themeName"
	mkdir -p "$ESDE_newConfigDirectory/themes/"
	if [ -d "$ESDE_newConfigDirectory/themes/$themeName" ]; then
		cd "$ESDE_newConfigDirectory/themes/$themeName" && git pull
	else
		git clone $themeUrl "$ESDE_newConfigDirectory/themes/$themeName"
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

	echo "updating $es_settingsFile"

}

ESDE_setDefaultSettings(){

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
	mkdir -p  "$ESDE_newConfigDirectory/gamelists/"
	ESDE_setEmu 'Dolphin (Standalone)' gc
	ESDE_setEmu 'PPSSPP (Standalone)' psp
	ESDE_setEmu 'Dolphin (Standalone)' wii
	ESDE_setEmu 'PCSX2 (Standalone)' ps2
	ESDE_setEmu 'melonDS DS' nds
	ESDE_setEmu 'Azahar (Standalone)' n3ds
	ESDE_setEmu 'Beetle Lynx' atarilynx
	ESDE_setEmu 'DuckStation (Standalone)' psx
	ESDE_setEmu 'Beetle Saturn' saturn
	ESDE_setEmu 'ScummVM (Standalone)' scummvm
	ESDE_setEmu 'Ryujinx (Standalone)' switch
}

ESDE_migrateDownloadedMedia(){
	echo "ESDE: Migrate Downloaded Media."

	originalESMediaFolder="$ESDE_newConfigDirectory/downloaded_media"
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
	local gamelistFile="$ESDE_newConfigDirectory/gamelists/$system/gamelist.xml"
	if [ ! -f "$gamelistFile" ]; then
		mkdir -p "$ESDE_newConfigDirectory/gamelists/$system" && cp "$emudeckBackend/configs/emulationstation/gamelists/$system/gamelist.xml" "$gamelistFile"
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
		rm -rf "$savesPath/es-de"
		linkToStorageFolder es-de gamelists "$ESDE_newConfigDirectory/gamelists/"
}

ESDE_migrateEpicNoir(){
	FOLDER="$ESDE_newConfigDirectory/themes/es-epicnoir"

	if [ -f "$FOLDER" ]; then
		rm -rf "$FOLDER"
		git clone https://github.com/anthonycaccese/epic-noir-revisited-es-de "$ESDE_newConfigDirectory/themes/epic-noir-revisited" --depth=1
		changeLine '<string name="ThemeSet"' '<string name="ThemeSet" value="epic-noir-revisited-es-de" />' "$es_settingsFile"
	fi
}

ESDE_flushToolLauncher(){
	mkdir -p "$toolsPath/launchers/es-de"
	cp "$emudeckBackend/tools/launchers/es-de/es-de.sh" "$toolsPath/launchers/es-de/es-de.sh"
	chmod +x "$toolsPath/launchers/es-de/es-de.sh"
}


ESDE_refreshCustomEmus(){
	rsync -avhp --mkpath "$emudeckBackend/configs/emulationstation/custom_systems/es_systems.xml" "$(dirname "$es_systemsFile")" --backup --suffix=.bak
	rsync -avhp --mkpath "$emudeckBackend/configs/emulationstation/custom_systems/es_find_rules.xml" "$(dirname "$es_rulesFile")" --backup --suffix=.bak
	sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" "$es_rulesFile"
	ESDE_setDefaultEmulators
}

ESDE_ensureRyujinxFindRule(){
	[ -f "$es_rulesFile" ] || return 0
	grep -q 'name="RYUJINX"' "$es_rulesFile" && return 0
	local ruleBlock="    <emulator name=\"RYUJINX\">\n        <rule type=\"staticpath\">\n            <entry>${toolsPath}/launchers/ryujinx.sh</entry>\n        </rule>\n    </emulator>"
	sed -i "s|</ruleList>|${ruleBlock}\n</ruleList>|" "$es_rulesFile"
}

ESDE_ensureDolphinFindRule(){
	[ -f "$es_rulesFile" ] || return 0
	local launcher="${toolsPath}/launchers/dolphin-emu.sh"
	grep -q "<entry>${launcher}</entry>" "$es_rulesFile" && return 0
	if grep -q 'name="DOLPHIN"' "$es_rulesFile"; then
		sed -i "/<emulator name=\"DOLPHIN\">/,/<\/emulator>/ s|<entry>.*</entry>|<entry>${launcher}</entry>|" "$es_rulesFile"
	else
		local ruleBlock="    <emulator name=\"DOLPHIN\">\n        <rule type=\"staticpath\">\n            <entry>${launcher}</entry>\n        </rule>\n    </emulator>"
		sed -i "s|</ruleList>|${ruleBlock}\n</ruleList>|" "$es_rulesFile"
	fi
}

ESDE_ensureCemuFindRule(){
	[ -f "$es_rulesFile" ] || return 0
	local launcher="${toolsPath}/launchers/cemu.sh"
	grep -q "<entry>${launcher}</entry>" "$es_rulesFile" && return 0
	if grep -q 'name="CEMU"' "$es_rulesFile"; then
		sed -i "/<emulator name=\"CEMU\">/,/<\/emulator>/ s|<entry>.*</entry>|<entry>${launcher}</entry>|" "$es_rulesFile"
	else
		local ruleBlock="    <emulator name=\"CEMU\">\n        <rule type=\"staticpath\">\n            <entry>${launcher}</entry>\n        </rule>\n    </emulator>"
		sed -i "s|</ruleList>|${ruleBlock}\n</ruleList>|" "$es_rulesFile"
	fi
}

ESDE_ensureSystemsPath(){
	[ -f "$es_systemsFile" ] || return 0
	grep -q '/run/media/mmcblk0p1/Emulation' "$es_systemsFile" || return 0
	[ "$emulationPath" = "/run/media/mmcblk0p1/Emulation" ] && return 0
	sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" "$es_systemsFile"
}

ESDE_ensurePS3Emulators(){
	local ps3Roms="$romsPath/ps3"
	local gamelist="$ESDE_newConfigDirectory/gamelists/ps3/gamelist.xml"
	[ -d "$ps3Roms" ] || return 0
	PS3_ROMS_DIR="$ps3Roms" PS3_GAMELIST="$gamelist" python3 "$emudeckBackend/tools/esdePS3Emulators.py" >/dev/null 2>&1
}

ESDE_launch_fixes(){
	ESDE_ensureRyujinxFindRule
	ESDE_ensureDolphinFindRule
	ESDE_ensureCemuFindRule
	ESDE_ensureSystemsPath
	ESDE_ensurePS3Emulators
}
