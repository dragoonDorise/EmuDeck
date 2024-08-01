#!/bin/bash

# Variables
Chiaking_emuName="chiaki-ng"
Chiaking_emuType="$emuDeckEmuTypeAppImage"
Chiaking_emuPath="$HOME/Applications/chiaki-ng.AppImage"

# Install
Chiaking_install() {
	setMSG "Installing $Chiaking_emuName."

    local showProgress=$1
	installEmuAI "$Chiaking_emuName" "$Chiaking_emuName" "$(getReleaseURLGH "streetpea/chiaki-ng" ".AppImage.zip")" "" "zip" "remoteplay" "$showProgress"
	unzip -o "$HOME/Applications/chiaki-ng.zip" -d "$HOME/Applications" && rm -rf "$HOME/Applications/chiaki-ng.zip"
	chmod +x $Chiaking_emuPath
	Chiaking_copySettings
}

# ApplyInitialSettings
Chiaking_init() {
	echo "NYI"
}

# Update appimage
Chiaking_update() {
	setMSG "Updating $Chiaking_emuName settings."
	rm -f "$Chiaking_emuPath"
	Chiaking_install
	Chiaking_copySettings
}




# Uninstall
Chiaking_uninstall() {
	setMSG "Uninstalling $Chiaking_emuName."
	uninstallEmuAI "$Chiaking_emuName" "" "" "remoteplay"
}

# Check if installed
Chiaking_IsInstalled() {
	if [ -f "$Chiaking_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

Chiaking_copySettings(){

	# Copy settings from the Chiaki Flatpak if it exists and if there is not currently a settings file for the chiaki-ng AppImage
	if [ -f "$HOME/.var/app/re.chiaki.Chiaki/config/Chiaki/Chiaki.conf" ]; then 
		rsync -av --ignore-existing "$HOME/.var/app/re.chiaki.Chiaki/config/Chiaki/Chiaki.conf" "$HOME/.config/Chiaki/Chiaki.conf"
	fi
}
