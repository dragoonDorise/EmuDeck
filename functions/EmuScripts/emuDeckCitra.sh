#!/bin/bash
#variables
Citra_emuName="Citra"
Citra_emuType="FlatPak"
Citra_emuPath="org.citra_emu.citra"
Citra_releaseURL=""

#cleanupOlderThings
Citra_finalize(){
 echo "NYI"
}

#Install
Citra_install(){
	setMSG "Installing $Citra_emuName"	
	installEmuFP "${Citra_emuName}" "${Citra_emuPath}"	
	flatpak override "${Citra_emuPath}" --filesystem=host --user	
}

#ApplyInitialSettings
Citra_init(){
	setMSG "Initializing $Citra_emuName settings."	
	configEmuFP "${Citra_emuName}" "${Citra_emuPath}" "true"
	Citra_setupStorage
	Citra_setEmulationFolder
	Citra_setupSaves
	Citra_addSteamInputProfile
}

#update
Citra_update(){
	setMSG "Updating $Citra_emuName settings."	
	configEmuFP "${Citra_emuName}" "${Citra_emuPath}"
	Citra_setupStorage
	Citra_setEmulationFolder
	Citra_setupSaves
	Citra_addSteamInputProfile
}

#ConfigurePaths
Citra_setEmulationFolder(){
	setMSG "Setting $Citra_emuName Emulation Folder"	
  	configFile="$HOME/.var/app/org.citra_emu.citra/config/citra-emu/qt-config.ini"
    gameDirOpt='Paths\\gamedirs\\3\\path='
    newGameDirOpt='Paths\\gamedirs\\3\\path='"${romsPath}/3ds"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
}

#SetupSaves
Citra_setupSaves(){
	linkToSaveFolder citra saves "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/sdmc"
	linkToSaveFolder citra states "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/states"
}


#SetupStorage
Citra_setupStorage(){
    echo "NYI"
}


#WipeSettings
Citra_wipe(){
	setMSG "Wiping $Citra_emuName config directory. (factory reset)"
	rm -rf "$HOME/.var/app/$Citra_emuPath"
}


#Uninstall
Citra_uninstall(){
	setMSG "Uninstalling $Citra_emuName."
    flatpak uninstall "$Citra_emuPath" --user -y
}

#setABXYstyle
Citra_setABXYstyle(){
    	echo "NYI"
}

#Migrate
Citra_migrate(){
    	echo "NYI"
}

#WideScreenOn
Citra_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
Citra_wideScreenOff(){
echo "NYI"
}

#BezelOn
Citra_bezelOn(){
echo "NYI"
}

#BezelOff
Citra_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Citra_finalize(){
	echo "NYI"
}

Citra_addSteamInputProfile(){
	rsync -r "$EMUDECKGIT/configs/steam-input/citra_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}