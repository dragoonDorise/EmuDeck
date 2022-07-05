#!/bin/bash

#variables
emuName="PCSX2"
emuType="FlatPak"
emuPath="net.pcsx2.PCSX2"
releaseURL=""

#cleanupOlderThings
PCSX2.cleanup() {
	#na
}

#Install
PCSX2.install() {
	installEmuFP "${emuName}" "${emuPath}"
	flatpak override "${emuPath}" --filesystem=host --user
	flatpak override "${emuPath}" --share=network --user
}

#ApplyInitialSettings
PCSX2.init() {
	configEmuFP "${emuName}" "${emuPath}" "true"
	setEmulationFolderPcsx2
	setupSavesPcsx2
}

#update
PCSX2.update() {
	configEmuFP "${emuName}" "${emuPath}"
	setEmulationFolderPcsx2
	setupSavesPcsx2
}

#ConfigurePaths
PCSX2.setEmulationFolder() {
	configFile = "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/inis/PCSX2_ui.ini"
	biosDirOpt='Bios=/'
	newBiosDirOpt='Bios='"${biosPath}"
	sed -i "/${biosDirOpt}/c\\${newBiosDirOpt}" $configFile
}

#SetupSaves
PCSX2.setupSaves() {
	linkToSaveFolder pcsx2 saves "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards"
	linkToSaveFolder pcsx2 states "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates"
}

#SetupStorage
PCSX2.setupStorage() {
	#na
}

#WipeSettings
PCSX2.wipe() {
	rm -rf "$HOME/.var/app/$emuPath"
	# prob not cause roms are here
}

#Uninstall
PCSX2.uninstall() {
	flatpack uninstall $emuPath -y
}

#setABXYstyle
PCSX2.setABXYstyle() {

}

#Migrate
PCSX2.migrate() {

}

#WideScreenOn
PCSX2.wideScreenOn() {
	#na
}

#WideScreenOff
PCSX2.wideScreenOff() {
	#na
}

#BezelOn
PCSX2.bezelOn() {
	#na
}

#BezelOff
PCSX2.bezelOff() {
	#na
}

#finalExec - Extra stuff
PCSX2.finalize() {
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
