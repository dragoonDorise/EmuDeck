#!/bin/bash

# Variables
Spotify_emuName="Spotify"
Spotify_emuType="$emuDeckEmuTypeFlatpak"
Spotify_emuPath="com.spotify.Client"
Spotify_releaseURL=""

# Install
Spotify_install() {
	setMSG "Installing $Spotify_emuName."
	installEmuFP "${Spotify_emuName}" "${Spotify_emuPath}" "genericapplication" ""
}

# ApplyInitialSettings
Spotify_init() {
	setMSG "Initializing $Spotify_emuName settings."	
	configEmuFP "$Spotify_emuName" "$Spotify_emuPath" "true"
	#Spotify_addSteamInputProfile
}

# Update flatpak & launcher script
Spotify_update() {
	setMSG "Updating $Spotify_emuName settings."
	updateEmuFP "${Spotify_emuName}" "${Spotify_emuPath}" "genericapplication" ""
}

# Uninstall
Spotify_uninstall() {
	setMSG "Uninstalling $Spotify_emuName."
    uninstallEmuFP "$Spotify_emuName" "${Spotify_emuPath}" "genericapplication" ""
}

# Check if installed
Spotify_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Spotify_emuPath")" == "$Spotify_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Spotify_addSteamInputProfile() {
	echo "NYI"
	#rsync -r "$EMUDECKGIT/configs/steam-input/emudeck_spotify_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
