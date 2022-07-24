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
	installEmuAI "pcsx2-Qt" "$(getReleaseURLGH "PCSX2/pcsx2" "Qt.AppImage")" #pcsx2-Qt.AppImage
}

#ApplyInitialSettings
PCSX2QT_init(){
	setMSG "Initializing $PCSX2QT_emuName settings."	
	configEmuAI "$PCSX2QT_emuName" "config" "$HOME/.config/PCSX2" "$EMUDECKGIT/configs/pcsx2qt/.config/PCSX2" "true"
	PCSX2QT_setEmulationFolder
	PCSX2QT_setupStorage
	PCSX2QT_setupSaves #
	PCSX2QT_addSteamInputProfile #
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

PCSX2QT_addSteamInputProfile(){
	setMSG "Adding $PCSX2QT_emuName Steam Input Profile."
	rsync -r "$EMUDECKGIT/configs/steam-input/PCSX2QT_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}