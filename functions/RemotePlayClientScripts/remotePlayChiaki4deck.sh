#!/bin/bash

# Variables
Chiaki4deck_emuName="Chiaki4deck"
Chiaki4deck_emuType="$emuDeckEmuTypeAppImage"
Chiaki4deck_emuPath="$HOME/Applications/Chiaki4deck.AppImage"

# Install
Chiaki4deck_install() {
	setMSG "Installing $Chiaki4deck_emuName."

    local showProgress=$1
	installEmuAI "$Chiaki4deck_emuName" "$(getReleaseURLGH "streetpea/chiaki4deck" ".AppImage")" "" "" "remoteplay" "$showProgress"
	Chiaki4deck_copySettings
}

# ApplyInitialSettings
Chiaki4deck_init() {
	echo "NYI"
}

# Update appimage
Chiaki4deck_update() {
	setMSG "Updating $Chiaki4deck_emuName settings."
	rm -f "$Chiaki4deck_emuPath"
	Chiaki4deck_install
	Chiaki4deck_copySettings
}




# Uninstall
Chiaki4deck_uninstall() {
	setMSG "Uninstalling $Chiaki4deck_emuName."
	uninstallEmuAI "$Chiaki4deck_emuName" "" "" "remoteplay"
}

# Check if installed
Chiaki4deck_IsInstalled() {
	if [ -f "$Chiaki4deck_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

Chiaki4deck_copySettings(){

	# Copy settings from the Chiaki Flatpak if it exists and if there is not currently a settings file for the Chiaki4deck AppImage
	if [ -f "$HOME/.var/app/re.chiaki.Chiaki/config/Chiaki/Chiaki.conf" ]; then 
		rsync -av --ignore-existing "$HOME/.var/app/re.chiaki.Chiaki/config/Chiaki/Chiaki.conf" "$HOME/.config/Chiaki/Chiaki.conf"
	fi
}
