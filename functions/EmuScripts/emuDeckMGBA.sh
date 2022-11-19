#!/bin/bash
#variables
mGBA_emuName="mGBA"
mGBA_emuType="FlatPak"
mGBA_emuPath="io.mgba.mGBA"
mGBA_releaseURL=""

#cleanupOlderThings
mGBA_cleanup(){
 echo "NYI"
}

#Install
mGBA_install(){
	installEmuFP "${mGBA_emuName}" "${mGBA_emuPath}"	
	flatpak override "${mGBA_emuPath}" --filesystem=host --user
	flatpak override "${mGBA_emuPath}" --share=network --user
}

#ApplyInitialSettings
mGBA_init(){
	configEmuFP "${mGBA_emuName}" "${mGBA_emuPath}" "true"
	mGBA_setupStorage
	mGBA_setEmulationFolder
	mGBA_setupSaves
	mGBA_addSteamInputProfile
}

#update
mGBA_update(){
	configEmuFP "${mGBA_emuName}" "${mGBA_emuPath}"
	mGBA_setupStorage
	mGBA_setEmulationFolder
	mGBA_setupSaves
	mGBA_addSteamInputProfile
}

#ConfigurePaths
mGBA_setEmulationFolder(){
  	configFile="$HOME/.var/app/${mGBA_emuPath}/config/mGBA/PSP/SYSTEM/mGBA.ini"
    gameDirOpt='CurrentDirectory = '
    newGameDirOpt='CurrentDirectory = '"${romsPath}/gba"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
}

#SetupSaves
mGBA_setupSaves(){
	linkToSaveFolder mGBA saves "$HOME/.var/app/io.mgba.mGBA/config/mGBA/PSP/SAVEDATA"
	linkToSaveFolder mGBA states "$HOME/.var/app/io.mgba.mGBA/config/mGBA/PSP/mGBA_STATE"
}


#SetupStorage
mGBA_setupStorage(){
	echo "NYI"
}


#WipeSettings
mGBA_wipe(){
   rm -rf "$HOME/.var/app/$mGBA_emuPath"
}


#Uninstall
mGBA_uninstall(){
    flatpak uninstall "$mGBA_emuPath" --user -y
}

#setABXYstyle
mGBA_setABXYstyle(){
	echo "NYI"    
}

#Migrate
mGBA_migrate(){
	echo "NYI"    
}

#WideScreenOn
mGBA_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
mGBA_wideScreenOff(){
	echo "NYI"
}

#BezelOn
mGBA_bezelOn(){
echo "NYI"
}

#BezelOff
mGBA_bezelOff(){
echo "NYI"
}

mGBA_IsInstalled(){
	if [ "$(flatpak --columns=app list | grep "$mGBA_emuPath")" == "$mGBA_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

mGBA_resetConfig(){
	mGBA_init &>/dev/null && echo "true" || echo "false"
}

#finalExec - Extra stuff
mGBA_finalize(){
	echo "NYI"
}

mGBA_addSteamInputProfile(){
	setMSG "Adding $mGBA_emuName Steam Input Profile."
	rsync -r "$EMUDECKGIT/configs/steam-input/mGBA_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}