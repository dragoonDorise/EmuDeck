#!/bin/bash
#variables
emuName="PPSSPP"
emuType="FlatPak"
emuPath="org.ppsspp.PPSSPP"
releaseURL=""

#cleanupOlderThings
PPSSPP.cleanup(){
 #na
}

#Install
PPSSPP.install(){
	installEmuFP "${emuName}" "${emuPath}"	
	flatpak override "${emuPath}" --filesystem=host --user
	flatpak override "${emuName}" --share=network --user
}

#ApplyInitialSettings
PPSSPP.init(){
	configEmuFP "${emuName}" "${emuPath}" "true"
	PPSSPP.setupStorage
	PPSSPP.setEmulationFolder
	PPSSPP.setupSaves
}

#update
PPSSPP.update(){
	configEmuFP "${emuName}" "${emuPath}"
	PPSSPP.setupStorage
	PPSSPP.setEmulationFolder
	PPSSPP.setupSaves
}

#ConfigurePaths
PPSSPP.setEmulationFolder(){
  	configFile="$HOME/.var/app/${emuPath}}/config/dolphin-emu/Dolphin.ini"
    gameDirOpt='CurrentDirectory = '
    newGameDirOpt='CurrentDirectory = '"${romsPath}PPSSPP"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
}

#SetupSaves
PPSSPP.setupSaves(){
	linkToSaveFolder ppsspp saves "$HOME/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/SAVEDATA"
	linkToSaveFolder ppsspp states "$HOME/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/PPSSPP_STATE"
}


#SetupStorage
PPSSPP.setupStorage(){
    #TBD
}


#WipeSettings
PPSSPP.wipe(){
   rm -rf "$HOME/.var/app/$emuPath"
}


#Uninstall
PPSSPP.uninstall(){
    flatpack uninstall "$emuPath" -y
}

#setABXYstyle
PPSSPP.setABXYstyle(){
    
}

#Migrate
PPSSPP.migrate(){
    
}

#WideScreenOn
PPSSPP.wideScreenOn(){

}

#WideScreenOff
PPSSPP.wideScreenOff(){

}

#BezelOn
PPSSPP.bezelOn(){
#na
}

#BezelOff
PPSSPP.bezelOff(){
#na
}

#finalExec - Extra stuff
PPSSPP.finalize(){
	#na
}

