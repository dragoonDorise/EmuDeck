#!/bin/bash

#variables
emuName="pcsx2"
emuType="FlatPak"
emuPath="net.pcsx2.PCSX2"
releaseURL=""

#cleanupOlderThings
cleanupPCSX2() {
	#na
}

#Install
installPCSX2() {
	installEmuFP "PCSX2" "net.pcsx2.PCSX2"
}

#ApplyInitialSettings
initPCSX2() {
	configEmuFP "PCSX2" "net.pcsx2.PCSX2" "true"
	setEmulationFolderPcsx2
	setupSavesPcsx2
}

#update
updatePCSX2() {
	configEmuFP "PCSX2" "net.pcsx2.PCSX2"
	setEmulationFolderPcsx2
	setupSavesPcsx2
}

#ConfigurePaths
setEmulationFolderPCSX2() {
	configFile = "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/inis/PCSX2_ui.ini"
	biosDirOpt='Bios=/'
	newBiosDirOpt='Bios='"${biosPath}"
	sed -i "/${biosDirOpt}/c\\${newBiosDirOpt}" $configFile
}

#SetupSaves
setupSavesPCSX2() {
	linkToSaveFolder pcsx2 saves "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards"
	linkToSaveFolder pcsx2 states "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates"
}

#SetupStorage
setupStoragePCSX2() {
	#na
}

#WipeSettings
wipePCSX2() {
	rm -rf "$HOME/.var/app/$emuPath"
	# prob not cause roms are here
}

#Uninstall
uninstallPCSX2() {
	flatpack uninstall $emuPath -y
}

#setABXYstyle
setABXYstylePCSX2() {

}

#Migrate
migratePCSX2() {

}

#WideScreenOn
wideScreenOnPCSX2() {
	#na
}

#WideScreenOff
wideScreenOffPCSX2() {
	#na
}

#BezelOn
bezelOnPCSX2() {
	#na
}

#BezelOff
bezelOffPCSX2() {
	#na
}

#finalExec - Extra stuff
finalizePCSX2() {
	#na
}
