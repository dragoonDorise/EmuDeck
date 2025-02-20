#!/bin/bash

# Variables
Chiaki_emuName="Chiaki"
Chiaki_emuType="$emuDeckEmuTypeFlatpak"
Chiaki_emuPath="re.chiaki.Chiaki"
Chiaki_releaseURL=""

# Install
Chiaki_install() {
	setMSG "Installing $Chiaki_emuName."
	installEmuFP "${Chiaki_emuName}" "${Chiaki_emuPath}" "remoteplay" "Chiaki Remote Play Client"
}

# ApplyInitialSettings
Chiaki_init() {
	setMSG "Initializing $Chiaki_emuName settings."	
	configEmuFP "$Chiaki_emuName" "$Chiaki_emuPath" "true"
	#Chiaki_addSteamInputProfile
}

# Update flatpak & launcher script
Chiaki_update() {
	setMSG "Updating $Chiaki_emuName settings."
	updateEmuFP "${Chiaki_emuName}" "${Chiaki_emuPath}" "remoteplay" "Chiaki Remote Play Client"
}

# Uninstall
Chiaki_uninstall() {
	setMSG "Uninstalling $Chiaki_emuName."
    uninstallEmuFP "$Chiaki_emuName" "$Chiaki_emuPath" "remoteplay" "Chiaki Remote Play Client"
}

# Check if installed
Chiaki_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Chiaki_emuPath")" == "$Chiaki_emuPath" ]; then
		# Uninstall if previously installed to the "system" level
		flatpak list | grep "$Chiaki_emuPath" | grep "system"
		if [ $? == 0 ]; then
			Chiaki_uninstall
			Chiaki_install
		fi
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Chiaki_addSteamInputProfile() {
	echo "NYI"
	#rsync -r "$EMUDECKGIT/configs/steam-input/emudeck_chiaki_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
