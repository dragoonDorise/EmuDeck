#!/bin/bash

# Variables
Greenlight_emuName="Greenlight"
Greenlight_emuType="$emuDeckEmuTypeAppImage"
Greenlight_emuPath="$HOME/Applications/Greenlight.AppImage"


# Install
Greenlight_install() {
    echo "Begin Greenlight Install"

	local showProgress="$1"
	installEmuAI "$Greenlight_emuName" "" "$(getReleaseURLGH "unknownskl/greenlight" ".AppImage")" "" "" "remoteplay" "$showProgress"
	
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
	rm -f "$Greenlight_emuPath"
	Greenlight_install
	# configEmuAI "$Greenlight_emuName" "config" "$HOME/.config/greenlilght" "$EMUDECKGIT/configs/Greenlight/.config/greenlight"
	# Greenlight_addSteamInputProfile
}

# Uninstall
Greenlight_uninstall() {
	setMSG "Uninstalling $Greenlight_emuName."
	uninstallEmuAI "$Greenlight_emuName" "" "" "remoteplay"
}

# Check if installed
Greenlight_IsInstalled() {
	if [ -f "$Greenlight_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Greenlight_addSteamInputProfile() {
	echo "NYI"
	# rsync -r "$EMUDECKGIT/configs/steam-input/emudeck_Greenlight_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
