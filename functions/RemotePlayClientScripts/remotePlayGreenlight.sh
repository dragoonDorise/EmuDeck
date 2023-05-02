#!/bin/bash

# Variables
Greenlight_emuName="Greenlight"
Greenlight_emuType="AppImage"
Greenlight_emuPath="$romsPath/remoteplay/Greenlight.AppImage"

# Install
Greenlight_install() {
    echo "Begin Greenlight Install"

	local showProgress="$1"
	if installEmuAI "Greenlight" "$(getReleaseURLGH "unknownskl/greenlight" ".AppImage")" "" "$showProgress"; then
		return 1
	else
		return 0
	fi
}

# ApplyInitialSettings
Greenlight_init() {
	echo "NYI"
	# setMSG "Initializing $Greenlight_emuName settings."	
	# configEmuFP "$Greenlight_emuName" "$Greenlight_emuPath" "true"
	# $Greenlight_addSteamInputProfile
}

# Update appimage by reinstalling
Greenlight_update() {
	setMSG "Updating $Greenlight_emuName."
	rm -rf "$Greenlight_emuPath"
	Greenlight_install
	# configEmuAI "$Greenlight_emuName" "config" "$HOME/.config/greenlilght" "$EMUDECKGIT/configs/Greenlight/.config/greenlight"
	# Greenlight_addSteamInputProfile
}

# Uninstall
Greenlight_uninstall() {
	setMSG "Uninstalling $Greenlight_emuName."
	rm -rf "$Greenlight_emuPath"
	rm "$romsPath/remoteplay/Greenlight Remote Play Client.sh"
}

# Check if installed
Greenlight_IsInstalled() {
	if [ -e "$Greenlight_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

# Import steam profile
Greenlight_addSteamInputProfile() {
	echo "NYI"
	# rsync -r "$EMUDECKGIT/configs/steam-input/emudeck_Greenlight_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
