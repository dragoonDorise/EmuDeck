#!/bin/bash
#variables
PCSX2QT_emuName="PCSX2-QT"
PCSX2QT_emuType="AppImage"
PCSX2QT_emuPath="$HOME/Applications/pcsx2-Qt.AppImage"
PCSX2QT_configFile="$HOME/.config/PCSX2/inis/PCSX2.ini"

#cleanupOlderThings
PCSX2QT_cleanup(){
	echo "NYI"
}

#Install
PCSX2QT_install(){
	echo "Begin PCSX2-QT Install"
	local showProgress="$1"
	if installEmuAI "pcsx2-Qt" "$(getReleaseURLGH "PCSX2/pcsx2" "Qt.AppImage")" "" "$showProgress"; then #pcsx2-Qt.AppImage
		:
	else
		return 1
	fi
}

#ApplyInitialSettings
PCSX2QT_init(){
	setMSG "Initializing $PCSX2QT_emuName settings."	
	configEmuAI "$PCSX2QT_emuName" "config" "$HOME/.config/PCSX2" "$EMUDECKGIT/configs/pcsx2qt/.config/PCSX2" "true"
	PCSX2QT_setEmulationFolder
	PCSX2QT_setupStorage
	PCSX2QT_setupSaves #
	# PCSX2QT_addSteamInputProfile #
}

#update
PCSX2QT_update(){
	setMSG "Updating $PCSX2QT_emuName settings."
	configEmuAI "$PCSX2QT_emuName" "config" "$HOME/.config/PCSX2" "$EMUDECKGIT/configs/pcsx2qt/.config/PCSX2"
	PCSX2QT_setEmulationFolder
	PCSX2QT_setupStorage
	PCSX2QT_setupSaves
	PCSX2QT_addSteamInputProfile
}

#ConfigurePaths
PCSX2QT_setEmulationFolder(){
	setMSG "Setting $PCSX2QT_emuName Emulation Folder"

	biosDirOpt='Bios = '
	snapShotsDirOpt='Snapshots = '
	saveStatesDirOpt='SaveStates = '
	memoryCardsDirOpt='MemoryCards = '
	cacheDirOpt='Cache = '
	texturesDirOpt='Textures = '
	coversDirOpt='Covers = '
	recursivePathsDirOpt='RecursivePaths = '

	newBiosDirOpt='Bios = '"${biosPath}"
	newsnapShotsDirOpt='Snapshots = '"${storagePath}/pcsx2/snaps"
	newsaveStatesDirOpt='SaveStates = '"${savesPath}/pcsx2/states"
	newmemoryCardsDirOpt='MemoryCards = '"${savesPath}/pcsx2/saves"
	newcacheDirOpt='Cache = '"${storagePath}/pcsx2/cache"
	newtexturesDirOpt='Textures = '"${storagePath}/pcsx2/textures"
	newcoversDirOpt='Covers = '"${storagePath}/pcsx2/covers"
	newrecursivePathsDirOpt='RecursivePaths = '"${romsPath}/ps2"


	changeLine "$biosDirOpt" "$newBiosDirOpt" "$PCSX2QT_configFile"
	changeLine "$snapShotsDirOpt" "$newsnapShotsDirOpt" "$PCSX2QT_configFile"
	changeLine "$saveStatesDirOpt" "$newsaveStatesDirOpt" "$PCSX2QT_configFile"
	changeLine "$memoryCardsDirOpt" "$newmemoryCardsDirOpt" "$PCSX2QT_configFile"
	changeLine "$cacheDirOpt" "$newcacheDirOpt" "$PCSX2QT_configFile"
	changeLine "$texturesDirOpt" "$newtexturesDirOpt" "$PCSX2QT_configFile"
	changeLine "$coversDirOpt" "$newcoversDirOpt" "$PCSX2QT_configFile"
	changeLine "$recursivePathsDirOpt" "$newrecursivePathsDirOpt" "$PCSX2QT_configFile"


}

#SetupSaves
PCSX2QT_setupSaves(){
	#link fp and ap saves / states?
	moveSaveFolder pcsx2 saves "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards"
	moveSaveFolder pcsx2 states "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates"
}


#SetupStorage
PCSX2QT_setupStorage(){
	echo "Begin PCSX2-QT storage config"
	mkdir -p "${storagePath}/pcsx2/snaps"
	mkdir -p "${storagePath}/pcsx2/cache"
	mkdir -p "${storagePath}/pcsx2/textures"
	mkdir -p "${storagePath}/pcsx2/covers"
}


#WipeSettings
PCSX2QT_wipe(){
	setMSG "Wiping $PCSX2QT_emuName settings."
	rm -rf "$HOME/.config/PCSX2"
	# prob not cause roms are here
}


#Uninstall
PCSX2QT_uninstall(){
	setMSG "Uninstalling $PCSX2QT_emuName."
	rm -rf "$emuPath"
}

#setABXYstyle
PCSX2QT_setABXYstyle(){
	echo "NYI"
}

#Migrate
PCSX2QT_migrate(){
	echo "NYI"
}

#WideScreenOn
PCSX2QT_wideScreenOn(){

	local EnableWideScreenPatches='EnableWideScreenPatches = '
	local EnableWideScreenPatchesOpt='EnableWideScreenPatches = '"true"
	
	changeLine "$EnableWideScreenPatches" "$EnableWideScreenPatchesOpt" "$PCSX2QT_configFile"

}

#WideScreenOff
PCSX2QT_wideScreenOff(){
	local EnableWideScreenPatches='EnableWideScreenPatches = '
	local EnableWideScreenPatchesOpt='EnableWideScreenPatches = '"false"

	changeLine "$EnableWideScreenPatches" "$EnableWideScreenPatchesOpt" "$PCSX2QT_configFile"
}

#BezelOn
PCSX2QT_bezelOn(){
echo "NYI"
}

#BezelOff
PCSX2QT_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
PCSX2QT_finalize(){
	echo "NYI"
}

PCSX2QT_IsInstalled(){
	if [ -e "$PCSX2QT_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

PCSX2QT_resetConfig(){
	PCSX2QT_init &>/dev/null && echo "true" || echo "false"
}

PCSX2QT_addSteamInputProfile(){
	echo "NYI"
}


PCSX2QT_retroAchievementsOn(){
	iniFieldUpdate "$PCSX2QT_configFile" "Achievements" "Enabled" "True"
}
PCSX2QT_retroAchievementsOff(){
	iniFieldUpdate "$PCSX2QT_configFile" "Achievements" "Enabled" "False"
}

PCSX2QT_retroAchievementsHardCoreOn(){
	iniFieldUpdate "$PCSX2QT_configFile" "Achievements" "ChallengeMode" "True"
	
}
PCSX2QT_retroAchievementsHardCoreOff(){
	iniFieldUpdate "$PCSX2QT_configFile" "Achievements" "ChallengeMode" "False"
}


PCSX2QT_retroAchievementsSetLogin(){	
	rau=$(cat "$HOME/.config/EmuDeck/.rau")
	rat=$(cat "$HOME/.config/EmuDeck/.rat")
	echo "Evaluate RetroAchievements Login."
	if [ ${#rat} -lt 1 ]; then
		echo "--No token."
	elif [ ${#rau} -lt 1 ]; then
		echo "--No username."
	else
		echo "Valid Retroachievements Username and Password length"
		iniFieldUpdate "$PCSX2QT_configFile" "Achievements" "Username" "$rau"
		iniFieldUpdate "$PCSX2QT_configFile" "Achievements" "Token" "$rat"
		PCSX2QT_retroAchievementsOn
	fi
}