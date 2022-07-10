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
	installEmuFP "${DuckStation_emuName}" "${DuckStation_emuPath}"	
	flatpak override "${DuckStation_emuPath}" --filesystem=host --user	
}

#ApplyInitialSettings
DuckStation.init(){
	configEmuFP "${DuckStation_emuName}" "${DuckStation_emuPath}" "true"
	DuckStation.setupStorage
	DuckStation.setEmulationFolder
	DuckStation.setupSaves
	DuckStation.addSteamInputProfile
}

#update
DuckStation.update(){
	configEmuFP "${DuckStation_emuName}" "${DuckStation_emuPath}"
	DuckStation.setupStorage
	DuckStation.setEmulationFolder
	DuckStation.setupSaves
	DuckStation.addSteamInputProfile
}

#ConfigurePaths
DuckStation.setEmulationFolder(){
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
   rm -rf "$HOME/.var/app/$DuckStation_emuPath"
   # prob not cause roms are here
}


#Uninstall
DuckStation.uninstall(){
    flatpak uninstall "$DuckStation_emuPath" -y
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
	echo "DuckStation: Widescreen On"
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
	echo "DuckStation: Widescreen Off"
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
	rsync -r "$EMUDECKGIT/configs/steam-input/duckstation_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}