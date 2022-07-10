#!/bin/bash
#variables
PPSSPP_emuName="PPSSPP"
PPSSPP_emuType="FlatPak"
PPSSPP_emuPath="org.ppsspp.PPSSPP"
PPSSPP_releaseURL=""

#cleanupOlderThings
PPSSPP.cleanup(){
 echo "NYI"
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
  	configFile="$HOME/.var/app/${PPSSPP_emuPath}/config/ppsspp/PSP/SYSTEM/ppsspp.ini"
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
	echo "NYI"
}


#WipeSettings
PPSSPP.wipe(){
   rm -rf "$HOME/.var/app/$PPSSPP_emuPath"
}


#Uninstall
PPSSPP.uninstall(){
    flatpak uninstall "$PPSSPP_emuPath" -y
}

#setABXYstyle
PPSSPP.setABXYstyle(){
	echo "NYI"    
}

#Migrate
PPSSPP.migrate(){
	echo "NYI"    
}

#WideScreenOn
PPSSPP.wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
PPSSPP.wideScreenOff(){
	echo "NYI"
}

#BezelOn
PPSSPP.bezelOn(){
echo "NYI"
}

#BezelOff
PPSSPP.bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
PPSSPP.finalize(){
	echo "NYI"
}

