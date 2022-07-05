#!/bin/bash

#variables
emuName="DuckStation"
emuType="FlatPak"
emuPath="org.duckstation.DuckStation"
releaseURL=""

#cleanupOlderThings
DuckStation.cleanup() {
	#na
}

#Install
DuckStation.install() {
	installEmuFP "${emuName}" "${emuPath}"
	flatpak override "${emuPath}" --filesystem=host --user
}

#ApplyInitialSettings
DuckStation.init() {
	configEmuFP "${emuName}" "${emuPath}" "true"
	DuckStation.setupStorage
	DuckStation.setEmulationFolder
	DuckStation.setupSaves
}

#update
DuckStation.update() {
	configEmuFP "${emuName}" "${emuPath}"
	DuckStation.setupStorage
	DuckStation.setEmulationFolder
	DuckStation.setupSaves
}

#ConfigurePaths
DuckStation.setEmulationFolder() {
	configFile="$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini"
	gameDirOpt='RecursivePaths = '
	newGameDirOpt="${gameDirOpt}""${romsPath}psx"
	biosDir='SearchDirectory = '
	biosDirSetting="${biosDir}""${biosPath}"
	sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
	sed -i "/${biosDir}/c\\${biosDirSetting}" "$configFile"
}

#SetupSaves
DuckStation.setupSaves() {
	linkToSaveFolder duckstation saves "$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/memcards"
	linkToSaveFolder duckstation states "$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/savestates"
}

#SetupStorage
DuckStation.setupStorage() {
	#TBD
}

#WipeSettings
DuckStation.wipe() {
	rm -rf "$HOME/.var/app/$emuPath"
	# prob not cause roms are here
}

#Uninstall
DuckStation.uninstall() {
	flatpack uninstall "$emuPath" -y
}

#setABXYstyle
DuckStation.setABXYstyleDuckStation() {

}

#Migrate
DuckStation.migrate() {

}

#WideScreenOn
DuckStation.wideScreenOn() {
	configFile="$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini"
	wideScreenHack='WidescreenHack = '
	wideScreenHackSetting='WidescreenHack = true'
	#aspectRatio='AspectRatio = '
	#aspectRatioSetting='AspectRatio = 0'
	sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$configFile"
	#sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$configFile"
}

#WideScreenOff
DuckStation.wideScreenOff() {
	configFile="$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini"
	wideScreenHack='WidescreenHack = '
	wideScreenHackSetting='WidescreenHack = false'
	#aspectRatio='AspectRatio = '
	#aspectRatioSetting='AspectRatio = 0'
	sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$configFile"
	#sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$configFile"
}

#BezelOn
DuckStation.bezelOn() {
	#na
}

#BezelOff
DuckStation.bezelOff() {
	#na
}

#finalExec - Extra stuff
DuckStation.finalize() {
	#na
}
