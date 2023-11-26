#!/bin/bash
#variables
ScummVM_emuName="ScummVM"
ScummVM_emuType="FlatPak"
ScummVM_emuPath="org.scummvm.ScummVM"
ScummVM_releaseURL=""
ScummVM_configFile="$HOME/.var/app/org.scummvm.ScummVM/config/scummvm/scummvm.ini"

#cleanupOlderThings
ScummVM_cleanup(){
 echo "NYI"
}

#Install
ScummVM_install(){
	installEmuFP "${ScummVM_emuName}" "${ScummVM_emuPath}"
	flatpak override "${ScummVM_emuPath}" --filesystem=host --user
	flatpak override "${ScummVM_emuPath}" --share=network --user
}

#ApplyInitialSettings
ScummVM_init(){
	configEmuFP "${ScummVM_emuName}" "${ScummVM_emuPath}" "true"
	ScummVM_setupStorage
	ScummVM_setEmulationFolder
	ScummVM_setupSaves
}

#update
ScummVM_update(){
	configEmuFP "${ScummVM_emuName}" "${ScummVM_emuPath}"
	ScummVM_setupStorage
	ScummVM_setEmulationFolder
	ScummVM_setupSaves
}

#ConfigurePaths
ScummVM_setEmulationFolder(){
    gameDirOpt='browser_lastpath='
    newGameDirOpt="$gameDirOpt""${romsPath}/scummvm"
	changeLine "$gameDirOpt" "$newGameDirOpt" "$ScummVM_configFile"


}

#SetupSaves
ScummVM_setupSaves(){
	savepath_directoryOpt='savepath='
	newsavepath_directoryOpt="$savepath_directoryOpt""$savesPath/scummvm/saves"
	changeLine "$savepath_directoryOpt" "$newsavepath_directoryOpt" "$ScummVM_configFile"

	moveSaveFolder scummvm saves "$HOME/.var/app/org.scummvm.ScummVM/data/scummvm/saves"
}


#SetupStorage
ScummVM_setupStorage(){
	echo "NYI"
}


#WipeSettings
ScummVM_wipe(){
	echo "NYI"
}


#Uninstall
ScummVM_uninstall(){
    flatpak uninstall "$ScummVM_emuPath" --user -y
}

#setABXYstyle
ScummVM_setABXYstyle(){
	echo "NYI"
}

#Migrate
ScummVM_migrate(){
	echo "NYI"
}

#WideScreenOn
ScummVM_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
ScummVM_wideScreenOff(){
	echo "NYI"
}

#BezelOn
ScummVM_bezelOn(){
echo "NYI"
}

#BezelOff
ScummVM_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
ScummVM_finalize(){
	echo "NYI"
}

ScummVM_IsInstalled(){
	isFpInstalled "$ScummVM_emuPath"
}

ScummVM_resetConfig(){
	ScummVM_init &>/dev/null && echo "true" || echo "false"
}