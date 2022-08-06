#!/bin/bash
#variables
MAME_emuName="MAME"
MAME_emuType="FlatPak"
MAME_emuPath="org.mamedev.MAME"
MAME_releaseURL=""
MAME_configFile="$HOME/.mame/mame.ini"

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
	configEmuAI "${MAME_emuName}" "mame" "$HOME/.mame" "${EMUDECKGIT}/configs/mame" "true"
	MAME_setupStorage
	MAME_setEmulationFolder
	MAME_setupSaves
}

#update
MAME_update(){
	configEmuAI "${MAME_emuName}" "mame" "$HOME/.mame" "${EMUDECKGIT}/configs/mame" 
	MAME_setupStorage
	MAME_setEmulationFolder
	MAME_setupSaves
}

#ConfigurePaths
MAME_setEmulationFolder(){
  	
    gameDirOpt='rompath                   '
    newGameDirOpt="$gameDirOpt""${romsPath}/arcade;${biosPath};${biosPath}/mame"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$MAME_configFile"
}

#SetupSaves
MAME_setupSaves(){
	linkToSaveFolder MAME saves "$HOME/.mame/nvram"
	linkToSaveFolder MAME states "$HOME/.mame/sta"
}


#SetupStorage
MAME_setupStorage(){
	echo "NYI"
}


#WipeSettings
MAME_wipe(){
   rm -rf "$HOME/.mame"
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

