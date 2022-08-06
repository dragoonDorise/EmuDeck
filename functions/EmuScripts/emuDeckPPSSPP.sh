#!/bin/bash
#variables
PPSSPP_emuName="PPSSPP"
PPSSPP_emuType="FlatPak"
PPSSPP_emuPath="org.ppsspp.PPSSPP"
PPSSPP_releaseURL=""

#cleanupOlderThings
PPSSPP_cleanup(){
 echo "NYI"
}

#Install
PPSSPP_install(){
	installEmuFP "${PPSSPP_emuName}" "${PPSSPP_emuPath}"	
	flatpak override "${PPSSPP_emuPath}" --filesystem=host --user
	flatpak override "${PPSSPP_emuPath}" --share=network --user
}

#ApplyInitialSettings
PPSSPP_init(){
	configEmuFP "${PPSSPP_emuName}" "${PPSSPP_emuPath}" "true"
	PPSSPP_setupStorage
	PPSSPP_setEmulationFolder
	PPSSPP_setupSaves
}

#update
PPSSPP_update(){
	configEmuFP "${PPSSPP_emuName}" "${PPSSPP_emuPath}"
	PPSSPP_setupStorage
	PPSSPP_setEmulationFolder
	PPSSPP_setupSaves
}

#ConfigurePaths
PPSSPP_setEmulationFolder(){
  	configFile="$HOME/.var/app/${PPSSPP_emuPath}/config/ppsspp/PSP/SYSTEM/ppsspp.ini"
    gameDirOpt='CurrentDirectory = '
    newGameDirOpt='CurrentDirectory = '"${romsPath}/psp"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
}

#SetupSaves
PPSSPP_setupSaves(){
	linkToSaveFolder ppsspp saves "$HOME/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/SAVEDATA"
	linkToSaveFolder ppsspp states "$HOME/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/PPSSPP_STATE"
}


#SetupStorage
PPSSPP_setupStorage(){
	echo "NYI"
}


#WipeSettings
PPSSPP_wipe(){
   rm -rf "$HOME/.var/app/$PPSSPP_emuPath"
}


#Uninstall
PPSSPP_uninstall(){
    flatpak uninstall "$PPSSPP_emuPath" --user -y
}

#setABXYstyle
PPSSPP_setABXYstyle(){
	echo "NYI"    
}

#Migrate
PPSSPP_migrate(){
	echo "NYI"    
}

#WideScreenOn
PPSSPP_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
PPSSPP_wideScreenOff(){
	echo "NYI"
}

#BezelOn
PPSSPP_bezelOn(){
echo "NYI"
}

#BezelOff
PPSSPP_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
PPSSPP_finalize(){
	echo "NYI"
}

