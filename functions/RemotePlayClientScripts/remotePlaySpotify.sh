#!/bin/bash

# Variables
Spotify_emuName="Spotify"
Spotify_emuType="FlatPak"
Spotify_emuPath="com.spotify.Client"
Spotify_releaseURL=""

# Install
Spotify_install() {
	setMSG "Installing $Spotify_emuName."
	local ID="$Spotify_emuPath"
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo --user
	flatpak install flathub "$ID" -y --user
	flatpak override "$ID" --filesystem=host --user
	flatpak override "$ID" --share=network --user
	cp "$EMUDECKGIT/tools/remoteplayclients/Spotify.sh" "$romsPath/remoteplay"
	chmod +x "$romsPath/remoteplay/Spotify.sh"
	#Spotify_addSteamInputProfile
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
	local ID="$Spotify_emuPath"
	flatpak update $ID -y --user	
	flatpak override $ID --filesystem=host --user
	flatpak override $ID --share=network --user
	rm "$romsPath/remoteplay/Spotify.sh"
	cp "$EMUDECKGIT/tools/remoteplayclients/Spotify.sh" "$romsPath/remoteplay"
	chmod +x "$romsPath/remoteplay/Spotify.sh"
}

# Uninstall
Spotify_uninstall() {
	setMSG "Uninstalling $Spotify_emuName."
    uninstallEmuFP "$Spotify_emuPath"
	rm "$romsPath/remoteplay/Spotify.sh"
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
