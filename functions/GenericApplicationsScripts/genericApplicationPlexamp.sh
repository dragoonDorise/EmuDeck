#!/bin/bash

# Variables
Plexamp_emuName="Plexamp"
Plexamp_emuType="$emuDeckEmuTypeFlatpak"
Plexamp_emuPath="com.plexamp.Plexamp"
Plexamp_releaseURL=""

# Install
Plexamp_install() {
	setMSG "Installing $Plexamp_emuName."
	installEmuFP "${Plexamp_emuName}" "${Plexamp_emuPath}" "genericapplication" ""
}

# ApplyInitialSettings
Plexamp_init() {
	setMSG "Initializing $Plexamp_emuName settings."	
	configEmuFP "$Plexamp_emuName" "$Plexamp_emuPath" "true"
}

# Update flatpak & launcher script
Plexamp_update() {
	setMSG "Updating $Plexamp_emuName settings."
	updateEmuFP "${Plexamp_emuName}" "${Plexamp_emuPath}" "genericapplication" ""
}

# Uninstall
Plexamp_uninstall() {
	setMSG "Uninstalling $Plexamp_emuName."
    uninstallEmuFP "$Plexamp_emuName" "$Plexamp_emuPath" "genericapplication" ""
}

# Check if installed
Plexamp_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Plexamp_emuPath")" == "$Plexamp_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Plexamp_addSteamInputProfile() {
	echo "NYI"
}
