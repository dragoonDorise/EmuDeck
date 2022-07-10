#!/bin/bash

#variables
DuckStation_emuName="DuckStation"
DuckStation_emuType="FlatPak"
DuckStation_emuPath="org.duckstation.DuckStation"
DuckStation_releaseURL=""

#cleanupOlderThings
DuckStation.cleanup(){
 echo "NYI"
}

#Install
DuckStation.install(){
	setMSG "Installing $DuckStation_emuName"		

	installEmuFP "${DuckStation_emuName}" "${DuckStation_emuPath}"	
	flatpak override "${DuckStation_emuPath}" --filesystem=host --user	
}

#ApplyInitialSettings
DuckStation.init(){
	setMSG "Initializing $DuckStation_emuName settings."
	configEmuFP "${DuckStation_emuName}" "${DuckStation_emuPath}" "true"
	DuckStation.setupStorage
	DuckStation.setEmulationFolder
	DuckStation.setupSaves
	DuckStation.addSteamInputProfile
}

#update
DuckStation.update(){
	setMSG "Updating $DuckStation_emuName settings."
	configEmuFP "${DuckStation_emuName}" "${DuckStation_emuPath}"
	DuckStation.setupStorage
	DuckStation.setEmulationFolder
	DuckStation.setupSaves
	DuckStation.addSteamInputProfile
}

#ConfigurePaths
DuckStation.setEmulationFolder(){
	setMSG "Setting $DuckStation_emuName Emulation Folder"	
  	configFile="$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini"
    gameDirOpt='RecursivePaths = '
    newGameDirOpt="${gameDirOpt}""${romsPath}psx"
	biosDir='SearchDirectory = '
	biosDirSetting="${biosDir}""${biosPath}"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
    sed -i "/${biosDir}/c\\${biosDirSetting}" "$configFile"
}

#SetupSaves
DuckStation.setupSaves(){
	linkToSaveFolder duckstation saves "$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/memcards"
	linkToSaveFolder duckstation states "$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/savestates"
}


#SetupStorage
DuckStation.setupStorage(){
	echo "NYI"
}


#WipeSettings
DuckStation.wipe(){
	setMSG "Wiping $DuckStation_emuName settings folder."	
   	rm -rf "$HOME/.var/app/$DuckStation_emuPath"
}


#Uninstall
DuckStation.uninstall(){
	setMSG "Uninstalling ${DuckStation_emuName}."	
    flatpak uninstall "$DuckStation_emuPath" --user -y
}

#setABXYstyle
DuckStation.setABXYstyle(){
    	echo "NYI"
}

#Migrate
DuckStation.migrate(){
	echo "NYI"
}

#WideScreenOn
DuckStation.wideScreenOn(){
	setMSG "${DuckStation_emuName}: Widescreen On"
    echo ""
    configFile="$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini"
    wideScreenHack='WidescreenHack = '
    wideScreenHackSetting='WidescreenHack = true'
    #aspectRatio='AspectRatio = '
    #aspectRatioSetting='AspectRatio = 0'
    sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$configFile"
	#sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$configFile"
}

#WideScreenOff
DuckStation.wideScreenOff(){
	setMSG "${DuckStation_emuName}: Widescreen Off"
    echo ""
    configFile="$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini"
    wideScreenHack='WidescreenHack = '
    wideScreenHackSetting='WidescreenHack = false'
    #aspectRatio='AspectRatio = '
    #aspectRatioSetting='AspectRatio = 0'
    sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$configFile"
	#sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$configFile"
}

#BezelOn
DuckStation.bezelOn(){
echo "NYI"
}

#BezelOff
DuckStation.bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
DuckStation.finalize(){
	echo "NYI"
}

DuckStation.addSteamInputProfile(){
	setMSG "Adding $DuckStation_emuName Steam Input Profile."
	rsync -r "$EMUDECKGIT/configs/steam-input/duckstation_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}