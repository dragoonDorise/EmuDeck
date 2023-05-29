#!/bin/bash
#variables
ares_emuName="ares"
ares_emuType="FlatPak"
ares_emuPath="dev.ares.ares"
ares_configFile="$HOME/.var/app/dev.ares.ares/data/ares/settings.bml"

#cleanupOlderThings
ares_cleanup(){
 echo "NYI"
}

#Install
ares_install() {
	setMSG "Installing $ares_emuName"	

	installEmuFP "${ares_emuName}" "${ares_emuPath}"
	flatpak override "${ares_emuPath}" --filesystem=host --user
}

#ApplyInitialSettings

ares_init() {

    setMSG "Initializing $ares_emuName settings."

	configEmuFP "${ares_emuName}" "${ares_emuPath}" "true"
	ares_setupStorage
	ares_setEmulationFolder
	ares_setupSaves
	ares_addSteamInputProfile

}

#update
ares_update() {
	setMSG "Installing $ares_emuName"		

	configEmuFP "${ares_emuName}" "${ares_emuPath}"
	ares_setupStorage
	ares_setEmulationFolder
	ares_setupSaves
	ares_addSteamInputProfile

}

#ConfigurePaths
ares_setEmulationFolder(){
	setMSG "Setting $ares_emuName Emulation Folder"


    # ROM Paths
	UserROMsPath='/home/deck/Emulation/roms/'
	sed -i "s|$UserROMsPath|${romsPath}\/|g" "$ares_configFile"

	# BIOS Paths
	UserBIOSPath='/home/deck/Emulation/bios/'
	sed -i "s|$UserBIOSPath|${biosPath}\/|g" "$ares_configFile"

}

#SetupSaves
ares_setupSaves(){

    # Create saves folder
 	mkdir -p "${savesPath}/ares/"
    
	# Set saves path
	UserSavesPath='/home/deck/Emulation/saves'
	sed -i "s|$UserSavesPath|${savesPath}|g" "$ares_configFile"
}


#SetupStorage
ares_setupStorage(){
	
	# Create storage folder
	mkdir -p "${storagePath}/ares/"
	mkdir -p "${storagePath}/ares/screenshots"

	# Set Storage path
	UserStoragePath='/home/deck/Emulation/storage'
	sed -i "s|$UserStoragePath|${storagePath}|g" "$ares_configFile"
}


#WipeSettings
ares_wipe(){
	rm -rf "$HOME/.var/app/$ares_emuPath"
}


#Uninstall
ares_uninstall(){
    flatpak uninstall "$ares_emuPath" --user -y
}

#setABXYstyle
ares_setABXYstyle(){
	echo "NYI"    
}

#Migrate
ares_migrate(){
	echo "NYI"    
}

#WideScreenOn
ares_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
ares_wideScreenOff(){
	echo "NYI"
}

#BezelOn
ares_bezelOn(){
echo "NYI"
}

#BezelOff
ares_bezelOff(){
echo "NYI"
}

ares_IsInstalled(){
	isFpInstalled "$ares_emuPath"
}

ares_resetConfig(){
	ares_init &>/dev/null && echo "true" || echo "false"
}

ares_addSteamInputProfile(){
	addSteamInputCustomIcons
	setMSG "Adding $ares_emuName Steam Input Profile."
	rsync -r "$EMUDECKGIT/configs/steam-input/ares_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

#finalExec - Extra stuff
ares_finalize(){
	echo "NYI"
}

