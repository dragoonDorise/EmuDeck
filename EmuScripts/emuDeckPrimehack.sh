#!/bin/bash

#variables
Primehack_emuName="Primehack"
Primehack_emuType="FlatPak"
Primehack_emuPath="io.github.shiiion.primehack"
releaseURL=""

#cleanupOlderThings
Primehack.cleanup(){
 echo "NYI"
}

#Install
Primehack.install() {
	installEmuFP "${Primehack_emuName}" "${Primehack_emuPath}"
	flatpak override "${Primehack_emuPath}" --filesystem=host --user
}

#ApplyInitialSettings
Primehack.init() {
	configEmuFP "${Primehack_emuName}" "${Primehack_emuPath}" "true"
	Primehack.setupStorage
	Primehack.setEmulationFolder
	Primehack.setupSaves
}

#update
Primehack.update() {
	configEmuFP "${Primehack_emuName}" "${Primehack_emuPath}"
	Primehack.setupStorage
	Primehack.setEmulationFolder
	Primehack.setupSaves
}

#ConfigurePaths
Primehack.setEmulationFolder() {
	configFile="$HOME/.var/app/${Primehack_emuPath}}/config/dolphin-emu/Dolphin.ini"
	gameDirOpt='ISOPath0 = '
	newGameDirOpt='ISOPath0 = '"${romsPath}primehacks"
	sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
}

#SetupSaves
Primehack.setupSaves(){
	linkToSaveFolder primehack GC "$HOME/.var/app/io.github.shiiion.primehack/data/dolphin-emu/GC"
	linkToSaveFolder primehack Wii "$HOME/.var/app/io.github.shiiion.primehack/data/dolphin-emu/Wii"
	linkToSaveFolder primehack states "$HOME/.var/app/io.github.shiiion.primehack/data/dolphin-emu/states"
}


#SetupStorage
Primehack.setupStorage(){
    #TBD
}


#WipeSettings
Primehack.wipe() {
	rm -rf "$HOME/.var/app/${Primehack_emuPath}"
}


#Uninstall
Primehack.uninstall() {
	flatpack uninstall "${Primehack_emuPath}" -y
}

#setABXYstyle
Primehack.setABXYstyle(){
    	echo "NYI"
}

#Migrate
Primehack.migrate(){
    	echo "NYI"
}

#WideScreenOn
Primehack.wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
Primehack.wideScreenOff(){
	echo "NYI"
}

#BezelOn
Primehack.bezelOn(){
echo "NYI"
}

#BezelOff
Primehack.BezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Primehack.finalize(){
	echo "NYI"
}

