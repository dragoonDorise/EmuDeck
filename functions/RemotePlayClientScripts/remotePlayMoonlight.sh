#!/bin/bash

# Variables
Moonlight_emuName="Moonlight"
Moonlight_emuType="FlatPak"
Moonlight_emuPath="com.moonlight_stream.Moonlight"
Moonlight_releaseURL=""

# Install
Moonlight_install() {
	setMSG "Installing $Moonlight_emuName."
	local ID="$Moonlight_emuPath"
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo --user
	flatpak install flathub "$ID" -y --user
	flatpak override "$ID" --filesystem=host --user
	flatpak override "$ID" --share=network --user
	cp "$EMUDECKGIT/tools/remoteplayclients/Moonlight Game Streaming.sh" "$romsPath/remoteplay"
	chmod +x "$romsPath/remoteplay/Moonlight Game Streaming.sh"
	Moonlight_addSteamInputProfile
}

# ApplyInitialSettings
Moonlight_init() {
	setMSG "Initializing $Moonlight_emuName settings."	
	configEmuFP "$Moonlight_emuName" "$Moonlight_emuPath" "true"
	$Moonlight_addSteamInputProfile
}

# Update flatpak & launcher script
Moonlight_update() {
	setMSG "Updating $Moonlight_emuName settings."
	local ID="$Moonlight_emuPath"
	flatpak update $ID -y --user	
	flatpak override $ID --filesystem=host --user
	flatpak override $ID --share=network --user
	rm "$romsPath/remoteplay/Moonlight Game Streaming.sh"
	cp "$EMUDECKGIT/tools/remoteplayclients/Moonlight Game Streaming.sh" "$romsPath/remoteplay"
	chmod +x "$romsPath/remoteplay/Moonlight Game Streaming.sh"
}

# Uninstall
Moonlight_uninstall() {
	setMSG "Uninstalling $Moonlight_emuName."
    uninstallEmuFP "$Moonlight_emuPath"
	rm "$romsPath/remoteplay/Moonlight Game Streaming.sh"
}

# Check if installed
Moonlight_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Moonlight_emuPath")" == "$Moonlight_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Moonlight_addSteamInputProfile() {
	rsync -r "$EMUDECKGIT/configs/steam-input/emudeck_moonlight_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
