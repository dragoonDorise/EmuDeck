#!/usr/bin/env bash

# remotePlaySreamLink

# Variables
SteamLink_emuName="SteamLink"
# shellcheck disable=2034,2154
SteamLink_emuType="${emuDeckEmuTypeFlatpak}"
SteamLink_emuPath="com.valvesoftware.SteamLink"
# shellcheck disable=2034
SteamLink_releaseURL=""

# Install
SteamLink_install () {
	setMSG "Installing ${SteamLink_emuName}."
	installEmuFP "${SteamLink_emuName}" "${SteamLink_emuPath}" "remoteplay" ""
}

# ApplyInitialSettings
SteamLink_init () {
	setMSG "Initializing ${SteamLink_emuName} settings."	
	configEmuFP "${SteamLink_emuName}" "${SteamLink_emuPath}" "true"
	#SteamLink_addSteamInputProfile
}

# Update flatpak & launcher script
SteamLink_update () {
	setMSG "Updating ${SteamLink_emuName} settings."
	updateEmuFP "${SteamLink_emuName}" "${SteamLink_emuPath}" "remoteplay" ""
}

# Uninstall
SteamLink_uninstall () {
	setMSG "Uninstalling ${SteamLink_emuName}."
    uninstallEmuFP "${SteamLink_emuName}" "${SteamLink_emuPath}" "remoteplay" ""
}

# Check if installed
SteamLink_IsInstalled () {
	if [ "$(flatpak --columns=app list | grep "${SteamLink_emuPath}")" == "${SteamLink_emuPath}" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
SteamLink_addSteamInputProfile () {
	echo "NYI"
	#rsync -r "$emudeckBackend/configs/steam-input/emudeck_steamlink_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
