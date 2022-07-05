#!/bin/bash

#variables
emuName="PPSSPP"
emuType="FlatPak"
emuPath="org.ppsspp.PPSSPP"
releaseURL=""

#cleanupOlderThings
cleanupPPSSPP() {
	#na
}

#Install
installPPSSPP() {
	installEmuFP "${emuName}" "${emuPath}"
	flatpak override "${emuPath}" --filesystem=host --user
	flatpak override "${emuName}" --share=network --user
}

#ApplyInitialSettings
initPPSSPP() {
	configEmuFP "${emuName}" "${emuPath}" "true"
	setupStoragePPSSPP
	setEmulationFolderPPSSPP
	setupSavesPPSSPP
}

#update
updatePPSSPP() {
	configEmuFP "${emuName}" "${emuPath}"
	setupStoragePPSSPP
	setEmulationFolderPPSSPP
	setupSavesPPSSPP
}

#ConfigurePaths
setEmulationFolderPPSSPP() {
	configFile="$HOME/.var/app/${emuPath}}/config/dolphin-emu/Dolphin.ini"
	gameDirOpt='CurrentDirectory = '
	newGameDirOpt='CurrentDirectory = '"${romsPath}PPSSPP"
	sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
}

#SetupSaves
setupSavesPPSSPP() {
	linkToSaveFolder ppsspp saves "$HOME/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/SAVEDATA"
	linkToSaveFolder ppsspp states "$HOME/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/PPSSPP_STATE"
}

#SetupStorage
setupStoragePPSSPP() {
	#TBD
}

#WipeSettings
wipePPSSPP() {
	rm -rf "$HOME/.var/app/$emuPath"
}

#Uninstall
uninstallPPSSPP() {
	flatpack uninstall "$emuPath" -y
}

#setABXYstyle
setABXYstylePPSSPP() {

}

#Migrate
migratePPSSPP() {

}

#WideScreenOn
wideScreenOnPPSSPP() {

}

#WideScreenOff
wideScreenOffPPSSPP() {

}

#BezelOn
bezelOnPPSSPP() {
	#na
}

#BezelOff
bezelOffPPSSPP() {
	#na
}

#finalExec - Extra stuff
finalizePPSSPP() {
	#na
}
