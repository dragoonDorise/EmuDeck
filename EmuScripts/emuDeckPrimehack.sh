#!/bin/bashCitra

#variables
emuName="Primehack"
emuType="FlatPak"
emuPath="io.github.shiiion.primehack"
releaseURL=""

#cleanupOlderThings
cleanupPrimehack() {
	#na
}

#Install
installPrimehack() {
	installEmuFP "${emuName}" "${emuPath}"
	flatpak override "${emuPath}" --filesystem=host --user
}

#ApplyInitialSettings
initPrimehack() {
	configEmuFP "${emuName}" "${emuPath}" "true"
	setupStoragePrimehack
	setEmulationFolderPrimehack
	setupSavesPrimehack
}

#update
updatePrimehack() {
	configEmuFP "${emuName}" "${emuPath}"
	setupStoragePrimehack
	setEmulationFolderPrimehack
	setupSavesPrimehack
}

#ConfigurePaths
setEmulationFolderPrimehack() {
	configFile="$HOME/.var/app/${emuPath}}/config/dolphin-emu/Dolphin.ini"
	gameDirOpt='ISOPath0 = '
	newGameDirOpt='ISOPath0 = '"${romsPath}primehacks"
	sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
}

#SetupSaves
setupSavesPrimehack() {
	linkToSaveFolder primehack GC "$HOME/.var/app/io.github.shiiion.primehack/data/dolphin-emu/GC"
	linkToSaveFolder primehack Wii "$HOME/.var/app/io.github.shiiion.primehack/data/dolphin-emu/Wii"
	linkToSaveFolder primehack states "$HOME/.var/app/io.github.shiiion.primehack/data/dolphin-emu/states"
}

#SetupStorage
setupStoragePrimehack() {
	#TBD
}

#WipeSettings
wipePrimehack() {
	rm -rf "$HOME/.var/app/$emuPath"
}

#Uninstall
uninstallPrimehack() {
	flatpack uninstall "$emuPath" -y
}

#setABXYstyle
setABXYstylePrimehack() {

}

#Migrate
migratePrimehack() {

}

#WideScreenOn
wideScreenOnPrimehack() {

}

#WideScreenOff
wideScreenOffPrimehack() {

}

#BezelOn
bezelOnPrimehack() {
	#na
}

#BezelOff
bezelOffPrimehack() {
	#na
}

#finalExec - Extra stuff
finalizePrimehack() {
	#na
}
