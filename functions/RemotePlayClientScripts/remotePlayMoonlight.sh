#!/bin/bash

# Variables
Moonlight_emuName="Moonlight"
Moonlight_emuType="FlatPak"
Moonlight_emuPath="com.moonlight_stream.Moonlight"
Moonlight_releaseURL=""

# Cleanup
Moonlight_finalize() {
	echo "NYI"
}

# Install
Moonlight_install() {
	setMSG "Installing $Moonlight_emuName."
	installEmuFP "$Moonlight_emuName" "$Moonlight_emuPath"
	Moonlight_addSteamInputProfile
}

# ApplyInitialSettings
Moonlight_init() {
	setMSG "Initializing $Moonlight_emuName settings."	
	configEmuFP "$Moonlight_emuName" "$Moonlight_emuPath" "true"
	$Moonlight_addSteamInputProfile
}

# Update flatpak
Moonlight_update() {
	setMSG "Updating $Moonlight_emuName settings."	
	updateEmuFP "$Moonlight_emuName" "$Moonlight_emuPath"
}

# Uninstall
Moonlight_uninstall() {
	setMSG "Uninstalling $Moonlight_emuName."
    uninstallEmuFP "$Moonlight_emuPath"
}

# Check if installed
Moonlight_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Moonlight_emuPath")" == "$Moonlight_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Moonlight_addSteamInputProfile() {
	rsync -r "$EMUDECKGIT/configs/steam-input/Moonlight_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
