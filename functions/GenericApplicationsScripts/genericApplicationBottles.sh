#!/bin/bash

# Variables
Bottles_emuName="Bottles"
Bottles_emuType="$emuDeckEmuTypeFlatpak"
Bottles_emuPath="com.usebottles.bottles"
Bottles_releaseURL=""

# Install
Bottles_install() {
	setMSG "Installing $Bottles_emuName."
	installEmuFP "${Bottles_emuName}" "${Bottles_emuPath}" "genericapplication" ""
}

# ApplyInitialSettings
Bottles_init() {
	setMSG "Initializing $Bottles_emuName settings."	
	configEmuFP "$Bottles_emuName" "$Bottles_emuPath" "true"
}

# Update flatpak & launcher script
Bottles_update() {
	setMSG "Updating $Bottles_emuName settings."
	updateEmuFP "${Bottles_emuName}" "${Bottles_emuPath}" "genericapplication" ""
}

# Uninstall
Bottles_uninstall() {
	setMSG "Uninstalling $Bottles_emuName."
    uninstallEmuFP "$Bottles_emuName" "$Bottles_emuPath" "genericapplication" ""
}

# Check if installed
Bottles_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Bottles_emuPath")" == "$Bottles_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Bottles_addSteamInputProfile() {
	echo "NYI"
}
