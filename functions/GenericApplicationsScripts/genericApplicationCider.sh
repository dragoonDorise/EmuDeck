#!/bin/bash

# Variables
Cider_emuName="Cider"
Cider_emuType="$emuDeckEmuTypeFlatpak"
Cider_emuPath="sh.cider.Cider"

# Install
Cider_install() {
	setMSG "Installing $Cider_emuName."
	installEmuFP "${Cider_emuName}" "${Cider_emuPath}" "genericapplication" ""
}

# ApplyInitialSettings
Cider_init() {
	setMSG "Initializing $Cider_emuName settings."	
	configEmuFP "$Cider_emuName" "$Cider_emuPath" "true"
}

# Update flatpak & launcher script
Cider_update() {
	setMSG "Updating $Cider_emuName settings."
	updateEmuFP "${Cider_emuName}" "${Cider_emuPath}" "genericapplication" ""
}

# Uninstall
Cider_uninstall() {
	setMSG "Uninstalling $Cider_emuName."
    uninstallEmuFP "$Cider_emuName" "$Cider_emuPath" "genericapplication" ""
}

# Check if installed
Cider_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Cider_emuPath")" == "$Cider_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Cider_addSteamInputProfile() {
	echo "NYI"
	#rsync -r "$EMUDECKGIT/configs/steam-input/emudeck_Cider_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
