#!/bin/bash
#variables
MAME_emuName="MAME"
MAME_emuType="FlatPak"
MAME_emuPath="org.mamedev.MAME"
MAME_releaseURL=""

#cleanupOlderThings
MAME_cleanup(){
 echo "NYI"
}

#Install
MAME_install(){
	installEmuFP "${MAME_emuName}" "${MAME_emuPath}"	
	flatpak override "${MAME_emuPath}" --filesystem=host --user
	flatpak override "${MAME_emuPath}" --share=network --user
}

#ApplyInitialSettings
MAME_init(){
	configEmuFP "${MAME_emuName}" "${MAME_emuPath}" "true"
	MAME_setupStorage
	MAME_setEmulationFolder
	MAME_setupSaves
}

#update
MAME_update(){
	configEmuFP "${MAME_emuName}" "${MAME_emuPath}"
	MAME_setupStorage
	MAME_setEmulationFolder
	MAME_setupSaves
}

#ConfigurePaths
MAME_setEmulationFolder(){
  	configFile="$HOME/.var/app/${MAME_emuPath}/config/MAME/PSP/SYSTEM/MAME.ini"
    gameDirOpt='CurrentDirectory = '
    newGameDirOpt='CurrentDirectory = '"${romsPath}/psp"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
}

#SetupSaves
MAME_setupSaves(){
	linkToSaveFolder MAME saves "$HOME/.var/app/org.MAME.MAME/config/MAME/PSP/SAVEDATA"
	linkToSaveFolder MAME states "$HOME/.var/app/org.MAME.MAME/config/MAME/PSP/MAME_STATE"
}


#SetupStorage
MAME_setupStorage(){
	echo "NYI"
}


#WipeSettings
MAME_wipe(){
   rm -rf "$HOME/.var/app/$MAME_emuPath"
}


#Uninstall
MAME_uninstall(){
    flatpak uninstall "$MAME_emuPath" --user -y
}

#setABXYstyle
MAME_setABXYstyle(){
	echo "NYI"    
}

#Migrate
MAME_migrate(){
	echo "NYI"    
}

#WideScreenOn
MAME_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
MAME_wideScreenOff(){
	echo "NYI"
}

#BezelOn
MAME_bezelOn(){
echo "NYI"
}

#BezelOff
MAME_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
MAME_finalize(){
	echo "NYI"
}

