#!/bin/bash
#variables
mGBA_emuName="mGBA"
mGBA_emuType="FlatPak"
mGBA_emuPath="io.mgba.mGBA"
mGBA_releaseURL=""
mGBA_configFile="$HOME/.var/app/io.mgba.mGBA/config/mgba/config.ini"

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
	echo "NYI"
}

#SetupSaves
mGBA_setupSaves(){
	mkdir -p "$savesPath/mgba/saves"
	mkdir -p "$savesPath/mgba/states"
	flatpak override "${mGBA_emuPath}" --filesystem="${savesPath}/mgba":rw --user
}


#SetupStorage
mGBA_setupStorage(){
	mkdir -p "$storagePath/mgba/cheats"
	mkdir -p "$storagePath/mgba/patches"
	mkdir -p "$storagePath/mgba/screenshots"
	flatpak override "${mGBA_emuPath}" --filesystem="${storagePath}/mgba":rw --user
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