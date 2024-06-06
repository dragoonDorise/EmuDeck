#!/bin/bash

# Variables
SteamLink_emuName="SteamLink"
SteamLink_emuType="FlatPak"
SteamLink_emuPath="com.valvesoftware.SteamLink"
SteamLink_releaseURL=""

# Install
SteamLink_install() {
	setMSG "Installing $SteamLink_emuName."
	local ID="$SteamLink_emuPath"
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo --user
	flatpak install flathub "$ID" -y --user
	flatpak override "$ID" --filesystem=host --user
	flatpak override "$ID" --share=network --user
	cp "$EMUDECKGIT/tools/remoteplayclients/SteamLink.sh" "$romsPath/remoteplay"
	chmod +x "$romsPath/remoteplay/SteamLink.sh"
	#SteamLink_addSteamInputProfile
}

# ApplyInitialSettings
SteamLink_init() {
	setMSG "Initializing $SteamLink_emuName settings."	
	configEmuFP "$SteamLink_emuName" "$SteamLink_emuPath" "true"
	#SteamLink_addSteamInputProfile
}

# Update flatpak & launcher script
SteamLink_update() {
	setMSG "Updating $SteamLink_emuName settings."
	local ID="$SteamLink_emuPath"
	flatpak update $ID -y --user	
	flatpak override $ID --filesystem=host --user
	flatpak override $ID --share=network --user
	rm "$romsPath/remoteplay/SteamLink.sh"
	cp "$EMUDECKGIT/tools/remoteplayclients/SteamLink.sh" "$romsPath/remoteplay"
	chmod +x "$romsPath/remoteplay/SteamLink.sh"
}

# Uninstall
SteamLink_uninstall() {
	setMSG "Uninstalling $SteamLink_emuName."
    uninstallEmuFP "$SteamLink_emuPath"
	rm "$romsPath/remoteplay/SteamLink.sh"
}

# Check if installed
SteamLink_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$SteamLink_emuPath")" == "$SteamLink_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
SteamLink_addSteamInputProfile() {
	echo "NYI"
	#rsync -r "$EMUDECKGIT/configs/steam-input/emudeck_steamlink_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
