#!/bin/bash
#variables
RMG_emuName="RMG"
RMG_emuType="FlatPak"
RMG_emuPath="com.github.Rosalie241.RMG"
RMG_releaseURL=""
RMG_configFile="$HOME/.var/app/com.github.Rosalie241.RMG/config/RMG/mupen64plus.cfg"

#cleanupOlderThings
RMG_cleanup(){
 echo "NYI"
}

#Install
RMG_install(){
	installEmuFP "${RMG_emuName}" "${RMG_emuPath}"	
	flatpak override "${RMG_emuPath}" --filesystem=host --user
}

#ApplyInitialSettings
RMG_init(){
	configEmuAI "${RMG_emuName}" "RMG" "$HOME/.RMG" "${EMUDECKGIT}/configs/RMG" "true"
	RMG_setupStorage
	RMG_setEmulationFolder
	RMG_setupSaves
	RMG_addSteamInputProfile

}

#update
RMG_update(){
	configEmuAI "${RMG_emuName}" "RMG" "$HOME/.RMG" "${EMUDECKGIT}/configs/RMG" 
	RMG_setupStorage
	RMG_setEmulationFolder
	RMG_setupSaves
	RMG_addSteamInputProfile

}

#ConfigurePaths
RMG_setEmulationFolder(){
	setMSG "Setting $RMG_emuName Emulation Folder"

  	RMG_configFile="$HOME/.var/app/com.github.Rosalie241.RMG/config/RMG/mupen64plus.cfg"
    gameDirOpt1='Paths\\gamedirs\\3\\path='
    newGameDirOpt1='Paths\\gamedirs\\3\\path='"${romsPath}/n64"
	gameDirOpt2='Paths\\gamedirs\\3\\path='
    newGameDirOpt2='Paths\\gamedirs\\3\\path='"${romsPath}/n64dd"
    sed -i "/${gameDirOpt1}/c\\${newGameDirOpt1}" "$configFile"
    sed -i "/${gameDirOpt2}/c\\${newGameDirOpt2}" "$configFile"

	SaveStatePath='SaveStates = '
	SaveStateSetting="${SaveStatePath}""${savesPath}/RMG/states"
	SaveSRAMPath='Directory = '
	SaveSRAMPathSetting="${SaveSRAMPath}""${savesPath}/RMG/saves"

	changeLine "$SaveStatePath" "$SaveStateSetting" "$RMG_configFile"
	changeLine "$SaveSRAMPath" "$SaveSRAMPathSetting" "$RMG_configFile"

}

#SetupSaves
RMG_setupSaves(){

	moveSaveFolder RMG saves "$HOME/.var/app/com.github.Rosalie241.RMG/data/mupen64plus/Game"
	moveSaveFolder RMG states "$HOME/.var/app/com.github.Rosalie241.RMG/data/mupen64plus/State"
}


#SetupStorage
RMG_setupStorage(){
	
	#Setup symlink for texture packs
	mkdir -p "${storagePath}/RMG/"
	mkdir -p "$HOME/.var/app/com.github.Rosalie241.RMG/config/RMG/data/RMG/hires_texture"
    ln -sn "$HOME/.var/app/com.github.Rosalie241.RMG/config/RMG/data/RMG/hires_texture" "${biosPath}/citra/keys"


}


#WipeSettings
RMG_wipe(){
	rm -rf "$HOME/.var/app/$RMG_emuPath"
}


#Uninstall
RMG_uninstall(){
    flatpak uninstall "$RMG_emuPath" --user -y
}

#setABXYstyle
RMG_setABXYstyle(){
	echo "NYI"    
}

#Migrate
RMG_migrate(){
	echo "NYI"    
}

#WideScreenOn
RMG_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
RMG_wideScreenOff(){
	echo "NYI"
}

#BezelOn
RMG_bezelOn(){
echo "NYI"
}

#BezelOff
RMG_bezelOff(){
echo "NYI"
}

RMG_IsInstalled(){
	if [ "$(flatpak --columns=app list | grep "$RMG_emuPath")" == "$RMG_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

RMG_resetConfig(){
	RMG_init &>/dev/null && echo "true" || echo "false"
}

RMG_addSteamInputProfile(){
	setMSG "Adding $RMG_emuName Steam Input Profile."
	rsync -r "$EMUDECKGIT/configs/steam-input/rmg_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

#finalExec - Extra stuff
RMG_finalize(){
	echo "NYI"
}

