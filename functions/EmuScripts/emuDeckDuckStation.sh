#!/bin/bash

#variables
DuckStation_emuName="DuckStation"
DuckStation_emuType="FlatPak"
DuckStation_emuPath="org.duckstation.DuckStation"
DuckStation_configFile="$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini"
DuckStation_releaseURL=""

#cleanupOlderThings
DuckStation_cleanup(){
 echo "NYI"
}

#Install
DuckStation_install(){
	setMSG "Installing $DuckStation_emuName"		

	installEmuFP "${DuckStation_emuName}" "${DuckStation_emuPath}"	
	flatpak override "${DuckStation_emuPath}" --filesystem=host --user	
}

#ApplyInitialSettings
DuckStation_init(){
	setMSG "Initializing $DuckStation_emuName settings."
	configEmuFP "${DuckStation_emuName}" "${DuckStation_emuPath}" "true"
	DuckStation_setupStorage
	DuckStation_setEmulationFolder
	DuckStation_setupSaves
	DuckStation_addSteamInputProfile
}

#update
DuckStation_update(){
	setMSG "Updating $DuckStation_emuName settings."
	configEmuFP "${DuckStation_emuName}" "${DuckStation_emuPath}"
	DuckStation_setupStorage
	DuckStation_setEmulationFolder
	DuckStation_setupSaves
	DuckStation_addSteamInputProfile
}

#ConfigurePaths
DuckStation_setEmulationFolder(){
	setMSG "Setting $DuckStation_emuName Emulation Folder"	
    gameDirOpt='RecursivePaths = '
    newGameDirOpt="${gameDirOpt}""${romsPath}/psx"
	biosDir='SearchDirectory = '
	biosDirSetting="${biosDir}""${biosPath}"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$DuckStation_configFile"
    sed -i "/${biosDir}/c\\${biosDirSetting}" "$DuckStation_configFile"
}

#SetupSaves
DuckStation_setupSaves(){
	linkToSaveFolder duckstation saves "$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/memcards"
	linkToSaveFolder duckstation states "$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/savestates"
}


#SetupStorage
DuckStation_setupStorage(){
	echo "NYI"
}


#WipeSettings
DuckStation_wipe(){
	setMSG "Wiping $DuckStation_emuName settings folder."	
   	rm -rf "$HOME/.var/app/$DuckStation_emuPath"
}


#Uninstall
DuckStation_uninstall(){
	setMSG "Uninstalling ${DuckStation_emuName}."	
    flatpak uninstall "$DuckStation_emuPath" --user -y
}

#setABXYstyle
DuckStation_setABXYstyle(){
    	echo "NYI"
}

#Migrate
DuckStation_migrate(){
	echo "NYI"
}

#WideScreenOn
DuckStation_wideScreenOn(){
	setMSG "${DuckStation_emuName}: Widescreen On"
    echo ""
    wideScreenHack='WidescreenHack = '
    wideScreenHackSetting='WidescreenHack = true'
    aspectRatio='AspectRatio = '
    aspectRatioSetting='AspectRatio = 16:9'
    sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$DuckStation_configFile"
	sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$configFile"
}

#WideScreenOff
DuckStation_wideScreenOff(){
	setMSG "${DuckStation_emuName}: Widescreen Off"
    echo ""
    wideScreenHack='WidescreenHack = '
    wideScreenHackSetting='WidescreenHack = false'
    aspectRatio='AspectRatio = '
    aspectRatioSetting='AspectRatio = 4:3'
    sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$DuckStation_configFile"
	sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$configFile"
}

#BezelOn
DuckStation_bezelOn(){
echo "NYI"
}

#BezelOff
DuckStation_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
DuckStation_finalize(){
	echo "NYI"
}

DuckStation_addSteamInputProfile(){
	setMSG "Adding $DuckStation_emuName Steam Input Profile."
	rsync -r "$EMUDECKGIT/configs/steam-input/duckstation_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}