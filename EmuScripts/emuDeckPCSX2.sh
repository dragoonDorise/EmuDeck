#!/bin/bash
#variables
PCSX2_emuName="PCSX2"
PCSX2_emuType="FlatPak"
PCSX2_emuPath="net.pcsx2.PCSX2"
PCSX2_releaseURL=""

#cleanupOlderThings
PCSX2.cleanup(){
 #na
}

#Install
PCSX2.install(){
	installEmuFP "${PCSX2_emuName}" "${PCSX2_emuPath}"
	flatpak override "${PCSX2_emuPath}" --filesystem=host --user
	flatpak override "${PCSX2_emuPath}" --share=network --user 
}

#ApplyInitialSettings
PCSX2.init(){
	configEmuFP  "${PCSX2_emuName}" "${PCSX2_emuPath}" "true"
	setEmulationFolderPcsx2
	setupSavesPcsx2
}

#update
PCSX2.update(){
	configEmuFP  "${PCSX2_emuName}" "${PCSX2_emuPath}"
	setEmulationFolderPcsx2
	setupSavesPcsx2
}

#ConfigurePaths
PCSX2.setEmulationFolder(){
	configFile = "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/inis/PCSX2_ui.ini"
	biosDirOpt='Bios=/'
	newBiosDirOpt='Bios='"${biosPath}"
	sed -i "/${biosDirOpt}/c\\${newBiosDirOpt}" $configFile
}

#SetupSaves
PCSX2.setupSaves(){
	linkToSaveFolder pcsx2 saves "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards"
	linkToSaveFolder pcsx2 states "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates"
}


#SetupStorage
PCSX2.setupStorage(){
 #na
}


#WipeSettings
PCSX2.wipe(){
   rm -rf "$HOME/.var/app/$PCSX2_emuPath"
   # prob not cause roms are here
}


#Uninstall
PCSX2.uninstall(){
    flatpack uninstall $PCSX2_emuPath -y
}

#setABXYstyle
PCSX2.setABXYstyle(){
    
}

#Migrate
PCSX2.migrate(){
    
}

#WideScreenOn
PCSX2.wideScreenOn(){
#na
}

#WideScreenOff
PCSX2.wideScreenOff(){
#na
}

#BezelOn
PCSX2.bezelOn(){
#na
}

#BezelOff
PCSX2.bezelOff(){
#na
}

#finalExec - Extra stuff
PCSX2.finalize(){
	#na
}

