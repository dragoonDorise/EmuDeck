#!/bin/bash

# Variables
Flatseal_emuName="Flatseal"
Flatseal_emuType="$emuDeckEmuTypeFlatpak"
Flatseal_emuPath="com.github.tchx84.Flatseal"
Flatseal_releaseURL=""

# Install
Flatseal_install() {
	setMSG "Installing $Flatseal_emuName."
	installEmuFP "${Flatseal_emuName}" "${Flatseal_emuPath}" "genericapplication" ""
}

# ApplyInitialSettings
Flatseal_init() {
	setMSG "Initializing $Flatseal_emuName settings."	
	configEmuFP "$Flatseal_emuName" "$Flatseal_emuPath" "true"
}

# Update flatpak & launcher script
Flatseal_update() {
	setMSG "Updating $Flatseal_emuName settings."
	updateEmuFP "${Flatseal_emuName}" "${Flatseal_emuPath}" "genericapplication" ""
}

# Uninstall
Flatseal_uninstall() {
	setMSG "Uninstalling $Flatseal_emuName."
    uninstallEmuFP "$Flatseal_emuName" "$Flatseal_emuPath" "genericapplication" ""
}

# Check if installed
Flatseal_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Flatseal_emuPath")" == "$Flatseal_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Flatseal_addSteamInputProfile() {
	echo "NYI"
}
