#!/usr/bin/env bash

# genericApplicationLutris

# Variables
Lutris_emuName="Lutris"
# shellcheck disable=2034,2154
Lutris_emuType="${emuDeckEmuTypeFlatpak}"
Lutris_emuPath="net.lutris.Lutris"
# shellcheck disable=2034
Lutris_releaseURL=""

# Install
Lutris_install () {
	setMSG "Installing $Lutris_emuName."
	installEmuFP "${Lutris_emuName}" "${Lutris_emuPath}" "genericapplication" ""
}

# ApplyInitialSettings
Lutris_init () {
	setMSG "Initializing $Lutris_emuName settings."	
	configEmuFP "$Lutris_emuName" "$Lutris_emuPath" "true"
}

# Update flatpak & launcher script
Lutris_update () {
	setMSG "Updating $Lutris_emuName settings."
	updateEmuFP "${Lutris_emuName}" "${Lutris_emuPath}" "genericapplication" ""
}

# Uninstall
Lutris_uninstall () {
	setMSG "Uninstalling $Lutris_emuName."
    uninstallEmuFP "$Lutris_emuName" "$Lutris_emuPath" "genericapplication" ""
}

# Check if installed
Lutris_IsInstalled () {
	if [ "$(flatpak --columns=app list | grep "$Lutris_emuPath")" == "$Lutris_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Lutris_addSteamInputProfile () {
	echo "NYI"
}
