#!/bin/bash
#variables
PPSSPP_emuName="PPSSPP"
PPSSPP_emuType="FlatPak"
PPSSPP_emuPath="org.ppsspp.PPSSPP"
PPSSPP_releaseURL=""

#cleanupOlderThings
PPSSPP.cleanup(){
 #na
}

#Install
PPSSPP.install(){
	installEmuFP "${PPSSPP_emuName}" "${PPSSPP_emuPath}"	
	flatpak override "${PPSSPP_emuPath}" --filesystem=host --user
	flatpak override "${PPSSPP_emuName}" --share=network --user
}

#ApplyInitialSettings
PPSSPP.init(){
	configEmuFP "${PPSSPP_emuName}" "${PPSSPP_emuPath}" "true"
	PPSSPP.setupStorage
	PPSSPP.setEmulationFolder
	PPSSPP.setupSaves
}

#update
PPSSPP.update(){
	configEmuFP "${PPSSPP_emuName}" "${PPSSPP_emuPath}"
	PPSSPP.setupStorage
	PPSSPP.setEmulationFolder
	PPSSPP.setupSaves
}

#ConfigurePaths
PPSSPP.setEmulationFolder(){
  	configFile="$HOME/.var/app/${PPSSPP_emuPath}}/config/dolphin-emu/Dolphin.ini"
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
   rm -rf "$HOME/.var/app/$PPSSPP_emuPath"
}


#Uninstall
PPSSPP.uninstall(){
    flatpack uninstall "$PPSSPP_emuPath" -y
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

