#!/bin/bash

# Variables
Lutris_emuName="Lutris"
Lutris_emuType="$emuDeckEmuTypeFlatpak"
Lutris_emuPath="net.lutris.Lutris"
Lutris_releaseURL=""

# Install
Lutris_install() {
	setMSG "Installing $Lutris_emuName."
	installEmuFP "${Lutris_emuName}" "${Lutris_emuPath}" "genericapplication" ""
}

# ApplyInitialSettings
Lutris_init() {
	setMSG "Initializing $Lutris_emuName settings."	
	configEmuFP "$Lutris_emuName" "$Lutris_emuPath" "true"
}

# Update flatpak & launcher script
Lutris_update() {
	setMSG "Updating $Lutris_emuName settings."
	updateEmuFP "${Lutris_emuName}" "${Lutris_emuPath}" "genericapplication" ""
}

# Uninstall
Lutris_uninstall() {
	setMSG "Uninstalling $Lutris_emuName."
    uninstallEmuFP "$Lutris_emuName" "$Lutris_emuPath" "genericapplication" ""
}

# Check if installed
Lutris_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Lutris_emuPath")" == "$Lutris_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Lutris_addSteamInputProfile() {
	echo "NYI"
}
