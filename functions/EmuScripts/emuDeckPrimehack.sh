#!/bin/bash

#variables
Primehack_emuName="Primehack"
Primehack_emuType="$emuDeckEmuTypeFlatpak"
Primehack_emuPath="io.github.shiiion.primehack"
Primehack_configFile="$HOME/.var/app/io.github.shiiion.primehack/config/dolphin-emu/Dolphin.ini"
Primehack_configFileGFX="$HOME/.var/app/io.github.shiiion.primehack/config/dolphin-emu/GFX.ini"
releaseURL=""

#cleanupOlderThings
Primehack_cleanup(){
 echo "NYI"
}

#Install
Primehack_install() {
	setMSG "Installing $Primehack_emuName"
	installEmuFP "${Primehack_emuName}" "${Primehack_emuPath}" "emulator" ""
}

#ApplyInitialSettings
Primehack_init() {
	setMSG "Initializing $Primehack_emuName settings."
	configEmuFP "${Primehack_emuName}" "${Primehack_emuPath}" "true"
	Primehack_setupStorage
	Primehack_setEmulationFolder
	Primehack_setupSaves
	#SRM_createParsers
	#Primehack_migrate
	Primehack_flushEmulatorLauncher
}

#update
Primehack_update() {
	setMSG "Updating $Primehack_emuName settings."
	configEmuFP "${Primehack_emuName}" "${Primehack_emuPath}" 
	updateEmuFP "${Primehack_emuName}" "${Primehack_emuPath}" "emulator" ""
	Primehack_setupStorage
	Primehack_setEmulationFolder
	Primehack_setupSaves
	Primehack_flushEmulatorLauncher
}

#ConfigurePaths
Primehack_setEmulationFolder() {
	setMSG "Setting $Primehack_emuName Emulation Folder"
	configFile="$HOME/.var/app/${Primehack_emuPath}/config/dolphin-emu/Dolphin.ini"
	gameDirOpt='ISOPath0 = '
	newGameDirOpt='ISOPath0 = '"${romsPath}/primehacks"
	sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
}

#SetupSaves
Primehack_setupSaves(){
	unlink "$savesPath/primehack/states"
	linkToSaveFolder primehack GC "$HOME/.var/app/io.github.shiiion.primehack/data/dolphin-emu/GC"
	linkToSaveFolder primehack Wii "$HOME/.var/app/io.github.shiiion.primehack/data/dolphin-emu/Wii"
	linkToSaveFolder primehack StateSaves "$HOME/.var/app/io.github.shiiion.primehack/data/dolphin-emu/StateSaves/"
}


#SetupStorage
Primehack_setupStorage(){
   	echo "NYI"
}


#WipeSettings
Primehack_wipe() {
	rm -rf "$HOME/.var/app/${Primehack_emuPath}"
}


#Uninstall
Primehack_uninstall() {
	uninstallEmuFP "${Primehack_emuName}" "${Primehack_emuPath}" "emulator" ""
}

#setABXYstyle
Primehack_setABXYstyle(){
    	echo "NYI"
}

#Migrate
Primehack_migrate(){
	migrateDolphinStates "primehack" "io.github.shiiion.primehack" 
}

#WideScreenOn
Primehack_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
Primehack_wideScreenOff(){
	echo "NYI"
}

#BezelOn
Primehack_bezelOn(){
echo "NYI"
}

#BezelOff
Primehack_BezelOff(){
echo "NYI"
}

Primehack_IsInstalled(){
	isFpInstalled "$Primehack_emuPath"
}

Primehack_resetConfig(){
	Primehack_init &>/dev/null && echo "true" || echo "false"
}

#finalExec - Extra stuff
Primehack_finalize(){
	echo "NYI"
}


Primehack_setResolution(){

	case $dolphinResolution in
		"720P") multiplier=2;;
		"1080P") multiplier=3;;
		"1440P") multiplier=4;;
		"4K") multiplier=6;;
		*) echo "Error"; return 1;;
	esac

	RetroArch_setConfigOverride "InternalResolution" $multiplier "$Primehack_configFileGFX"

}

Primehack_flushEmulatorLauncher(){


	flushEmulatorLaunchers "primehack"

}