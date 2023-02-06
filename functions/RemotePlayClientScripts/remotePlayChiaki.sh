#!/bin/bash

# Variables
Chiaki_emuName="Chiaki"
Chiaki_emuType="FlatPak"
Chiaki_emuPath="re.chiaki.Chiaki"
Chiaki_releaseURL=""

# Cleanup
Chiaki_finalize() {
	echo "NYI"
}

# Install
Chiaki_install() {
	setMSG "Installing $Chiaki_emuName."
	installEmuFP "$Chiaki_emuName" "$Chiaki_emuPath"
	Chiaki_addSteamInputProfile
}

# ApplyInitialSettings
Chiaki_init() {
	setMSG "Initializing $Chiaki_emuName settings."	
	configEmuFP "$Chiaki_emuName" "$Chiaki_emuPath" "true"
	$Chiaki_addSteamInputProfile
}

# Update flatpak
Chiaki_update() {
	setMSG "Updating $Chiaki_emuName settings."	
	updateEmuFP "$Chiaki_emuName" "$Chiaki_emuPath"
}

# Uninstall
Chiaki_uninstall() {
	setMSG "Uninstalling $Chiaki_emuName."
    uninstallEmuFP "$Chiaki_emuPath"
}

# Check if installed
Chiaki_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Chiaki_emuPath")" == "$Chiaki_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Chiaki_addSteamInputProfile() {
	rsync -r "$EMUDECKGIT/configs/steam-input/Chiaki_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
