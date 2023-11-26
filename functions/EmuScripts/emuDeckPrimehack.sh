#!/bin/bash

#variables
Primehack_emuName="Primehack"
Primehack_emuType="FlatPak"
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
	installEmuFP "${Primehack_emuName}" "${Primehack_emuPath}"
	flatpak override "${Primehack_emuPath}" --filesystem=host --user
}

#ApplyInitialSettings
Primehack_init() {
	configEmuFP "${Primehack_emuName}" "${Primehack_emuPath}" "true"
	Primehack_setupStorage
	Primehack_setEmulationFolder
	Primehack_setupSaves
	#Primehack_migrate
}

#update
Primehack_update() {
	configEmuFP "${Primehack_emuName}" "${Primehack_emuPath}"
	Primehack_setupStorage
	Primehack_setEmulationFolder
	Primehack_setupSaves
}

#ConfigurePaths
Primehack_setEmulationFolder() {
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
	flatpak uninstall "${Primehack_emuPath}" -y
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
		*) echo "Error"; exit 1;;
	esac

	RetroArch_setConfigOverride "InternalResolution" $multiplier "$Primehack_configFileGFX"

}