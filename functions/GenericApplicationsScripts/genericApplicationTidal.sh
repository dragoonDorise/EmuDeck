#!/bin/bash

# Variables
Tidal_emuName="Tidal"
Tidal_emuType="$emuDeckEmuTypeFlatpak"
Tidal_emuPath="com.mastermindzh.tidal-hifi"
Tidal_releaseURL=""

# Install
Tidal_install() {
	setMSG "Installing $Tidal_emuName."
	installEmuFP "${Tidal_emuName}" "${Tidal_emuPath}" "genericapplication" ""
}

# ApplyInitialSettings
Tidal_init() {
	setMSG "Initializing $Tidal_emuName settings."	
	configEmuFP "$Tidal_emuName" "$Tidal_emuPath" "true"
}

# Update flatpak & launcher script
Tidal_update() {
	setMSG "Updating $Tidal_emuName settings."
	updateEmuFP "${Tidal_emuName}" "${Tidal_emuPath}" "genericapplication" ""
}

# Uninstall
Tidal_uninstall() {
	setMSG "Uninstalling $Tidal_emuName."
    uninstallEmuFP "$Tidal_emuName" "$Tidal_emuPath" "genericapplication" ""
}

# Check if installed
Tidal_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Tidal_emuPath")" == "$Tidal_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Tidal_addSteamInputProfile() {
	echo "NYI"
}
