#!/bin/bash

# Variables
Moonlight_emuName="Moonlight"
Moonlight_emuType="$emuDeckEmuTypeFlatpak"
Moonlight_emuPath="com.moonlight_stream.Moonlight"
Moonlight_releaseURL=""

# Install
Moonlight_install() {
	setMSG "Installing $Moonlight_emuName."
	installEmuFP "${Moonlight_emuName}" "${Moonlight_emuPath}" "remoteplay" "Moonlight Game Streaming"
}

# ApplyInitialSettings
Moonlight_init() {
	setMSG "Initializing $Moonlight_emuName settings."	
	configEmuFP "$Moonlight_emuName" "$Moonlight_emuPath" "true"
	#Moonlight_addSteamInputProfile
}

# Update flatpak & launcher script
Moonlight_update() {
	setMSG "Updating $Moonlight_emuName settings."
	updateEmuFP "${Moonlight_emuName}" "${Moonlight_emuPath}" "remoteplay" "Moonlight Game Streaming"
}

# Uninstall
Moonlight_uninstall() {
	setMSG "Uninstalling $Moonlight_emuName."
    uninstallEmuFP "$Moonlight_emuName" "$Moonlight_emuPath" "remoteplay" "Moonlight Game Streaming"
}

# Check if installed
Moonlight_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Moonlight_emuPath")" == "$Moonlight_emuPath" ]; then
		# Uninstall if previously installed to the "system" level
		flatpak list | grep "$Moonlight_emuPath" | grep "system"
		if [ $? == 0 ]; then
			Moonlight_uninstall
			Moonlight_install
		fi
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Moonlight_addSteamInputProfile() {
	echo "NYI"
	#rsync -r "$EMUDECKGIT/configs/steam-input/emudeck_moonlight_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
