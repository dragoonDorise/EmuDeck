#!/bin/bash

# Variables
Parsec_emuName="Parsec"
Parsec_emuType="FlatPak"
Parsec_emuPath="com.parsecgaming.parsec"
Parsec_releaseURL=""

# Install
Parsec_install() {
	setMSG "Installing $Parsec_emuName."
	local ID="$Parsec_emuPath"
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo --user
	flatpak install flathub "$ID" -y --user
	flatpak override "$ID" --filesystem=host --user
	flatpak override "$ID" --share=network --user
	cp "$EMUDECKGIT/tools/remoteplayclients/Parsec.sh" "$romsPath/remoteplay"
	chmod +x "$romsPath/remoteplay/Parsec.sh"
	#Parsec_addSteamInputProfile
}

# ApplyInitialSettings
Parsec_init() {
	setMSG "Initializing $Parsec_emuName settings."	
	configEmuFP "$Parsec_emuName" "$Parsec_emuPath" "true"
	$Parsec_addSteamInputProfile
}

# Update flatpak & launcher script
Parsec_update() {
	setMSG "Updating $Parsec_emuName settings."
	local ID="$Parsec_emuPath"
	flatpak update $ID -y --user	
	flatpak override $ID --filesystem=host --user
	flatpak override $ID --share=network --user
	rm "$romsPath/remoteplay/Parsec.sh"
	cp "$EMUDECKGIT/tools/remoteplayclients/Parsec.sh" "$romsPath/remoteplay"
	chmod +x "$romsPath/remoteplay/Parsec.sh"
}

# Uninstall
Parsec_uninstall() {
	setMSG "Uninstalling $Parsec_emuName."
    uninstallEmuFP "$Parsec_emuPath"
	rm "$romsPath/remoteplay/Parsec.sh"
}

# Check if installed
Parsec_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Parsec_emuPath")" == "$Parsec_emuPath" ]; then
		# Uninstall if previously installed to the "system" level
		flatpak list | grep "$Parsec_emuPath" | grep "system"
		if [ $? == 0 ]; then
			Parsec_uninstall
			Parsec_install
		fi
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Parsec_addSteamInputProfile() {
	rsync -r "$EMUDECKGIT/configs/steam-input/emudeck_parsec_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
