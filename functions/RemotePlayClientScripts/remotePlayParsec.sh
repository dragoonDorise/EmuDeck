#!/bin/bash

# Variables
Parsec_emuName="Parsec"
Parsec_emuType="FlatPak"
Parsec_emuPath="com.parsecgaming.parsec"
Parsec_releaseURL=""

# Cleanup
Parsec_finalize() {
	echo "NYI"
}

# Install
Parsec_install() {
	setMSG "Installing $Parsec_emuName."
	installEmuFP "$Parsec_emuName" "$Parsec_emuPath"

	Parsec_addSteamInputProfile
}

# ApplyInitialSettings
Parsec_init() {
	setMSG "Initializing $Parsec_emuName settings."	
	configEmuFP "$Parsec_emuName" "$Parsec_emuPath" "true"
	$Parsec_addSteamInputProfile
}

# Update flatpak
Parsec_update() {
	setMSG "Updating $Parsec_emuName settings."	
	updateEmuFP "$Parsec_emuName" "$Parsec_emuPath"
}

# Uninstall
Parsec_uninstall() {
	setMSG "Uninstalling $Parsec_emuName."
    uninstallEmuFP "$Parsec_emuPath"
}

# Check if installed
Parsec_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Parsec_emuPath")" == "$Parsec_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Parsec_addSteamInputProfile() {
	rsync -r "$EMUDECKGIT/configs/steam-input/Parsec_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
