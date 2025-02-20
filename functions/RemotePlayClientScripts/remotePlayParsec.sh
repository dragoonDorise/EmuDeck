#!/bin/bash

# Variables
Parsec_emuName="Parsec"
Parsec_emuType="$emuDeckEmuTypeFlatpak"
Parsec_emuPath="com.parsecgaming.parsec"
Parsec_releaseURL=""

# Install
Parsec_install() {
	setMSG "Installing $Parsec_emuName."
	installEmuFP "${Parsec_emuName}" "${Parsec_emuPath}" "remoteplay" ""
}

# ApplyInitialSettings
Parsec_init() {
	setMSG "Initializing $Parsec_emuName settings."	
	configEmuFP "$Parsec_emuName" "$Parsec_emuPath" "true"
	#Parsec_addSteamInputProfile
}

# Update flatpak & launcher script
Parsec_update() {
	setMSG "Updating $Parsec_emuName settings."
	updateEmuFP "${Parsec_emuName}" "${Parsec_emuPath}" "remoteplay" ""
}

# Uninstall
Parsec_uninstall() {
	setMSG "Uninstalling $Parsec_emuName."
    uninstallEmuFP "$Parsec_emuName" "$Parsec_emuPath" "remoteplay" ""
}

# Check if installed
Parsec_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Parsec_emuPath")" == "$Parsec_emuPath" ]; then
		# Uninstall if previously installed to the "system" level
		flatpak list | grep "$Parsec_emuPath" | grep "system"
		if [ $? == 0 ]; then
			Parsec_uninstall
			Parsec_install
		fi
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Parsec_addSteamInputProfile() {
	echo "NYI"
	#rsync -r "$EMUDECKGIT/configs/steam-input/emudeck_parsec_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
