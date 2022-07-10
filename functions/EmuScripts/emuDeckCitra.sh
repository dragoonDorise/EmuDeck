#!/bin/bash
#variables
Citra_emuName="Citra"
Citra_emuType="FlatPak"
Citra_emuPath="org.citra_emu.citra"
Citra_releaseURL=""

#cleanupOlderThings
Citra.finalize(){
 echo "NYI"
}

#Install
Citra.install(){
	setMSG "Installing $Citra_emuName"	
	installEmuFP "${Citra_emuName}" "${Citra_emuPath}"	
	flatpak override "${Citra_emuPath}" --filesystem=host --user	
}

#ApplyInitialSettings
Citra.init(){
	setMSG "Initializing $Citra_emuName settings."	
	configEmuFP "${Citra_emuName}" "${Citra_emuPath}" "true"
	Citra.setupStorage
	Citra.setEmulationFolder
	Citra.setupSaves
	Citra.addSteamInputProfile
}

#update
Citra.update(){
	setMSG "Updating $Citra_emuName settings."	
	configEmuFP "${Citra_emuName}" "${Citra_emuPath}"
	Citra.setupStorage
	Citra.setEmulationFolder
	Citra.setupSaves
	Citra.addSteamInputProfile
}

#ConfigurePaths
Citra.setEmulationFolder(){
	setMSG "Setting $Citra_emuName Emulation Folder"	
  	configFile="$HOME/.var/app/org.citra_emu.citra/config/citra-emu/qt-config.ini"
    gameDirOpt='Paths\\gamedirs\\3\\path='
    newGameDirOpt='Paths\\gamedirs\\3\\path='"${romsPath}3ds"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
}

#SetupSaves
Citra.setupSaves(){
	linkToSaveFolder citra saves "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/sdmc"
	linkToSaveFolder citra states "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/states"
}


#SetupStorage
Citra.setupStorage(){
    echo "NYI"
}


#WipeSettings
Citra.wipe(){
	setMSG "Wiping $Citra_emuName config directory. (factory reset)"
	rm -rf "$HOME/.var/app/$Citra_emuPath"
}


#Uninstall
Citra.uninstall(){
	setMSG "Uninstalling $Citra_emuName."
    flatpak uninstall "$Citra_emuPath" --user -y
}

#setABXYstyle
Citra.setABXYstyle(){
    	echo "NYI"
}

#Migrate
Citra.migrate(){
    	echo "NYI"
}

#WideScreenOn
Citra.wideScreenOn(){
echo "NYI"
}

#WideScreenOff
Citra.wideScreenOff(){
echo "NYI"
}

#BezelOn
Citra.bezelOn(){
echo "NYI"
}

#BezelOff
Citra.bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Citra.finalize(){
	echo "NYI"
}

Citra.addSteamInputProfile(){
	rsync -r "$EMUDECKGIT/configs/steam-input/citra_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}