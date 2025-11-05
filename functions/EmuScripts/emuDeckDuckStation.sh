#!/bin/bash

#variables
DuckStation_emuName="DuckStation"
DuckStation_emuType="$emuDeckEmuTypeAppImage"
DuckStation_emuPath="$emusFolder/DuckStation.AppImage"
DuckStation_releaseURL=""
DuckStation_configPath="$HOME/.local/share/duckstation"
DuckStation_configFile="$HOME/.local/share/duckstation/settings.ini"

#Install
Duckstation_install(){
	echo "Begin $DuckStation_emuName Install"
	local showProgress="$1"
	local url=$(getReleaseURLGH "stenzek/duckstation" "AppImage" "x64.")

	if installEmuAI "$DuckStation_emuName" "" "$url" "DuckStation" "AppImage" "emulator" "$showProgress"; then
		mv "$emusFolder/DuckStation.AppImage" "$DuckStation_emuPath"
		chmod +x "$DuckStation_emuPath"
	else
		return 1
	fi

	if [ -d "$HOME/.var/app/org.duckstation.DuckStation/config/duckstation" ]; then
		zenity --info --width=400 --text="DuckStation flatpak detected, we will now migrate your data to the new AppImage format"
		mv "$HOME/.var/app/org.duckstation.DuckStation/config/duckstation" "$HOME/.local/share"
		DuckStation_flushEmulatorLauncher
		flatpak uninstall org.duckstation.DuckStation -y
	fi
}

#ApplyInitialSettings
DuckStation_init(){
	setMSG "Initializing $DuckStation_emuName settings."
	configEmuAI "$DuckStation_emuName" "duckstation"  "$DuckStation_configPath" "$emudeckBackend/configs/duckstation" "true"
	DuckStation_setupStorage
	DuckStation_setEmulationFolder
	DuckStation_setupSaves
	#DuckStation_addSteamInputProfile
	DuckStation_retroAchievementsSetLogin
	DuckStation_setCustomizations
	RetroArch_setRetroAchievements
	#SRM_createParsers
	DuckStation_flushEmulatorLauncher
}

#update
DuckStation_update(){
	setMSG "Updating $DuckStation_emuName settings."
	configEmuAI "$DuckStation_emuName" "duckstation"  "$DuckStation_configPath" "$emudeckBackend/configs/duckstation"
	DuckStation_setupStorage
	DuckStation_setEmulationFolder
	DuckStation_setupSaves
	#DuckStation_addSteamInputProfile
	DuckStation_flushEmulatorLauncher
}

#ConfigurePaths
DuckStation_setEmulationFolder(){
	setMSG "Setting $DuckStation_emuName Emulation Folder"
    gameDirOpt='RecursivePaths = '
    newGameDirOpt="${gameDirOpt}""${romsPath}/psx"

	biosDir='SearchDirectory = '
	biosDirSetting="${biosDir}""${biosPath}"

	statesDir='SaveStates = '
	statesDirSetting="${statesDir}""${savesPath}/duckstation/states"

	memCardDir='Directory = '
	memCardDirSetting="${memCardDir}""${savesPath}/duckstation/saves"

	changeLine "$gameDirOpt" "$newGameDirOpt" "$DuckStation_configFile"
	changeLine "$biosDir" "$biosDirSetting" "$DuckStation_configFile"
	changeLine "$statesDir" "$statesDirSetting" "$DuckStation_configFile"
	changeLine "$memCardDir" "$memCardDirSetting" "$DuckStation_configFile"

}

#SetupSaves
DuckStation_setupSaves(){
	moveSaveFolder duckstation saves "$DuckStation_configPath/memcards"
	moveSaveFolder duckstation states "$DuckStation_configPath/savestates"
}


#SetupStorage
DuckStation_setupStorage(){
	echo "NYI"
}


#WipeSettings
DuckStation_wipe(){
	setMSG "Wiping $DuckStation_emuName settings folder."
   	rm -rf "$HOME/.var/app/$DuckStation_emuPath"
}


#Uninstall
DuckStation_uninstall(){
	setMSG "Uninstalling ${DuckStation_emuName}."
	uninstallEmuAI $DuckStation_emuName "DuckStation" "" "emulator"
}

#setABXYstyle
DuckStation_setABXYstyle(){
    	echo "NYI"
}

#Migrate
DuckStation_migrate(){
	echo "NYI"
}

#WideScreenOn
DuckStation_wideScreenOn(){
	setMSG "${DuckStation_emuName}: Widescreen On"
    echo ""
    wideScreenHack='WidescreenHack = '
    wideScreenHackSetting='WidescreenHack = true'
    aspectRatio='AspectRatio = '
    aspectRatioSetting='AspectRatio = 16:9'
	sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$DuckStation_configFile"
	sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$DuckStation_configFile"
}

#WideScreenOff
DuckStation_wideScreenOff(){
	setMSG "${DuckStation_emuName}: Widescreen Off"
    echo ""
    wideScreenHack='WidescreenHack = '
    wideScreenHackSetting='WidescreenHack = false'
    aspectRatio='AspectRatio = '
    aspectRatioSetting='AspectRatio = 4:3'
	sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$DuckStation_configFile"
	sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$DuckStation_configFile"

}

#BezelOn
DuckStation_bezelOn(){
echo "NYI"
}

#BezelOff
DuckStation_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
DuckStation_finalize(){
	echo "NYI"
}

DuckStation_IsInstalled(){
	if [ -e "$DuckStation_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

DuckStation_resetConfig(){
	DuckStation_init &>/dev/null && echo "true" || echo "false"
}

DuckStation_addSteamInputProfile(){
	addSteamInputCustomIcons
	#echo "NYI"
	#setMSG "Adding $DuckStation_emuName Steam Input Profile."
	#rsync -r "$emudeckBackend/configs/steam-input/duckstation_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

DuckStation_retroAchievementsOn(){
	iniFieldUpdate "$DuckStation_configFile" "Cheevos" "Enabled" "True"
}
DuckStation_retroAchievementsOff(){
	iniFieldUpdate "$DuckStation_configFile" "Cheevos" "Enabled" "False"
}

DuckStation_retroAchievementsHardCoreOn(){
	iniFieldUpdate "$DuckStation_configFile" "Cheevos" "ChallengeMode" "True"

}
DuckStation_retroAchievementsHardCoreOff(){
	iniFieldUpdate "$DuckStation_configFile" "Cheevos" "ChallengeMode" "False"
}


DuckStation_retroAchievementsSetLogin(){
	rau=$(cat "$emudeckFolder/.rau")
	rat=$(cat "$emudeckFolder/.rat")
	echo "Evaluate RetroAchievements Login."
	if [ ${#rat} -lt 1 ]; then
		echo "--No token."
	elif [ ${#rau} -lt 1 ]; then
		echo "--No username."
	else
		echo "Valid Retroachievements Username and Password length"
		iniFieldUpdate "$DuckStation_configFile" "Cheevos" "Username" "$rau"
		iniFieldUpdate "$DuckStation_configFile" "Cheevos" "Token" "$rat"
		iniFieldUpdate "$DuckStation_configFile" "Cheevos" "LoginTimestamp" "$(date +%s)"
		DuckStation_retroAchievementsOn
	fi
}

DuckStation_setRetroAchievements(){
	DuckStation_retroAchievementsSetLogin
	if [ "$achievementsHardcore" == "true" ]; then
		DuckStation_retroAchievementsHardCoreOn
	else
		DuckStation_retroAchievementsHardCoreOff
	fi
}

DuckStation_setCustomizations(){
	if [ "$arClassic3D" == 169 ]; then
			DuckStation_wideScreenOn
	else
			DuckStation_wideScreenOff
	fi
}

DuckStation_setResolution(){

	case $duckstationResolution in
		"720P") multiplier=3;;
		"1080P") multiplier=5;;
		"1440P") multiplier=6;;
		"4K") multiplier=9;;
		*) echo "Error"; return 1;;
	esac

	RetroArch_setConfigOverride "ResolutionScale" $multiplier "$DuckStation_configFile"
}

DuckStation_flushEmulatorLauncher(){


	flushEmulatorLaunchers "duckstation"

}