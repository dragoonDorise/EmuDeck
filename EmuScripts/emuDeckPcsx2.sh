#!/bin/bash
#variables
emuName="pcsx2"
emuType="FlatPak"
emuPath="net.pcsx2.PCSX2"
releaseURL=""

#cleanupOlderThings
cleanupPcsx2(){
 #na
}

#Install
installPcsx2(){
	installEmuFP "PCSX2" "net.pcsx2.PCSX2"	
}

#ApplyInitialSettings
initPcsx2(){
	configEmuFP "PCSX2" "net.pcsx2.PCSX2" "true"
	setEmulationFolderPcsx2
	setupSavesPcsx2
}

#update
updatePcsx2(){
	configEmuFP "PCSX2" "net.pcsx2.PCSX2"
	setEmulationFolderPcsx2
	setupSavesPcsx2
}

#ConfigurePaths
setEmulationFolderPcsx2(){
	configFile = "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/inis/PCSX2_ui.ini"
	biosDirOpt='Bios=/'
	newBiosDirOpt='Bios='"${biosPath}"
	sed -i "/${biosDirOpt}/c\\${newBiosDirOpt}" $configFile
}

#SetupSaves
setupSavesPcsx2(){
	linkToSaveFolder pcsx2 saves $HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards
	linkToSaveFolder pcsx2 states $HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates
}


#SetupStorage
setupStoragePcsx2(){
 #na
}


#WipeSettings
wipePcsx2(){
   rm -rf "$HOME/.var/app/$emuPath"
   # prob not cause roms are here
}


#Uninstall
uninstallPcsx2(){
    flatpack uninstall $emuPath -y
}

#setABXYstyle
setABXYstylePcsx2(){
    
}

#Migrate
migratePcsx2(){
    
}

#WideScreenOn
wideScreenOnPcsx2(){
#na
}

#WideScreenOff
wideScreenOffPcsx2(){
#na
}

#BezelOn
bezelOnPcsx2(){
#na
}

#BezelOff
bezelOffPcsx2(){
#na
}

#finalExec - Extra stuff
finalizePcsx2(){
	#na
}

