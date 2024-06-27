#!/bin/bash

#variables
DuckStation_emuName="DuckStation"
DuckStation_emuType="$emuDeckEmuTypeFlatpak"
DuckStation_emuPath="org.duckstation.DuckStation"
DuckStation_configFileNew="$HOME/.var/app/org.duckstation.DuckStation/config/duckstation/settings.ini"

#cleanupOlderThings
DuckStation_cleanup(){
 echo "NYI"
}

#Install
DuckStation_install(){
	setMSG "Installing $DuckStation_emuName"
	installEmuFP "${DuckStation_emuName}" "${DuckStation_emuPath}" "emulator" ""
}

#ApplyInitialSettings
DuckStation_init(){
	setMSG "Initializing $DuckStation_emuName settings."
	configEmuFP "${DuckStation_emuName}" "${DuckStation_emuPath}" "true"
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
	configEmuFP "${DuckStation_emuName}" "${DuckStation_emuPath}"
	updateEmuFP "${DuckStation_emuName}" "${DuckStation_emuPath}" "emulator" ""
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

	changeLine "$gameDirOpt" "$newGameDirOpt" "$DuckStation_configFileNew"
	changeLine "$biosDir" "$biosDirSetting" "$DuckStation_configFileNew"
	changeLine "$statesDir" "$statesDirSetting" "$DuckStation_configFileNew"
	changeLine "$memCardDir" "$memCardDirSetting" "$DuckStation_configFileNew"

}

#SetupSaves
DuckStation_setupSaves(){
	moveSaveFolder duckstation saves "$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/memcards"
	moveSaveFolder duckstation states "$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/savestates"
	moveSaveFolder duckstation saves "$HOME/.var/app/org.duckstation.DuckStation/config/duckstation/memcards"
	moveSaveFolder duckstation states "$HOME/.var/app/org.duckstation.DuckStation/config/duckstation/savestates"
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
    uninstallEmuFP "${DuckStation_emuName}" "${DuckStation_emuPath}" "emulator" ""
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
	sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$DuckStation_configFileNew"
	sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$DuckStation_configFileNew"
}

#WideScreenOff
DuckStation_wideScreenOff(){
	setMSG "${DuckStation_emuName}: Widescreen Off"
    echo ""
    wideScreenHack='WidescreenHack = '
    wideScreenHackSetting='WidescreenHack = false'
    aspectRatio='AspectRatio = '
    aspectRatioSetting='AspectRatio = 4:3'
	sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$DuckStation_configFileNew"
	sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$DuckStation_configFileNew"

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
	isFpInstalled "$DuckStation_emuPath"
}

DuckStation_resetConfig(){
	DuckStation_init &>/dev/null && echo "true" || echo "false"
}

DuckStation_addSteamInputProfile(){
	addSteamInputCustomIcons
	#echo "NYI"
	#setMSG "Adding $DuckStation_emuName Steam Input Profile."
	#rsync -r "$EMUDECKGIT/configs/steam-input/duckstation_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

DuckStation_retroAchievementsOn(){
	iniFieldUpdate "$DuckStation_configFileNew" "Cheevos" "Enabled" "True"
}
DuckStation_retroAchievementsOff(){
	iniFieldUpdate "$DuckStation_configFileNew" "Cheevos" "Enabled" "False"
}

DuckStation_retroAchievementsHardCoreOn(){
	iniFieldUpdate "$DuckStation_configFileNew" "Cheevos" "ChallengeMode" "True"

}
DuckStation_retroAchievementsHardCoreOff(){
	iniFieldUpdate "$DuckStation_configFileNew" "Cheevos" "ChallengeMode" "False"
}


DuckStation_retroAchievementsSetLogin(){
	rau=$(cat "$HOME/.config/EmuDeck/.rau")
	rat=$(cat "$HOME/.config/EmuDeck/.rat")
	echo "Evaluate RetroAchievements Login."
	if [ ${#rat} -lt 1 ]; then
		echo "--No token."
	elif [ ${#rau} -lt 1 ]; then
		echo "--No username."
	else
		echo "Valid Retroachievements Username and Password length"
		iniFieldUpdate "$DuckStation_configFileNew" "Cheevos" "Username" "$rau"
		iniFieldUpdate "$DuckStation_configFileNew" "Cheevos" "Token" "$rat"
		iniFieldUpdate "$DuckStation_configFileNew" "Cheevos" "LoginTimestamp" "$(date +%s)"
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

	RetroArch_setConfigOverride "ResolutionScale" $multiplier "$DuckStation_configFileNew"
}

DuckStation_flushEmulatorLauncher(){


	flushEmulatorLaunchers "duckstation"

}