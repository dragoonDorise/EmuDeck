#!/bin/bash

# Variables
Chiaki_emuName="Chiaki"
Chiaki_emuType="FlatPak"
Chiaki_emuPath="re.chiaki.Chiaki"
Chiaki_releaseURL=""

# Install
Chiaki_install() {
	setMSG "Installing $Chiaki_emuName."
	local ID="$Chiaki_emuPath"
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo --user
	flatpak install flathub "$ID" -y --user
	flatpak override "$ID" --filesystem=host --user
	flatpak override "$ID" --share=network --user
	cp "$EMUDECKGIT/tools/remoteplayclients/Chiaki Remote Play Client.sh" "$romsPath/remoteplay"
	chmod +x "$romsPath/remoteplay/Chiaki Remote Play Client.sh"
	#Chiaki_addSteamInputProfile
}

# ApplyInitialSettings
Chiaki_init() {
	setMSG "Initializing $Chiaki_emuName settings."	
	configEmuFP "$Chiaki_emuName" "$Chiaki_emuPath" "true"
	$Chiaki_addSteamInputProfile
}

# Update flatpak & launcher script
Chiaki_update() {
	setMSG "Updating $Chiaki_emuName settings."
	local ID="$Chiaki_emuPath"
	flatpak update $ID -y --user	
	flatpak override $ID --filesystem=host --user
	flatpak override $ID --share=network --user
	rm "$romsPath/remoteplay/Chiaki Remote Play Client.sh"
	cp "$EMUDECKGIT/tools/remoteplayclients/Chiaki Remote Play Client.sh" "$romsPath/remoteplay"
	chmod +x "$romsPath/remoteplay/Chiaki Remote Play Client.sh"
}

# Uninstall
Chiaki_uninstall() {
	setMSG "Uninstalling $Chiaki_emuName."
    uninstallEmuFP "$Chiaki_emuPath"
	rm "$romsPath/remoteplay/Chiaki Remote Play Client.sh"
}

# Check if installed
Chiaki_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Chiaki_emuPath")" == "$Chiaki_emuPath" ]; then
		# Uninstall if previously installed to the "system" level
		flatpak list | grep "$Chiaki_emuPath" | grep "system"
		if [ $? == 0 ]; then
			Chiaki_uninstall
			Chiaki_install
		fi
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Chiaki_addSteamInputProfile() {
	rsync -r "$EMUDECKGIT/configs/steam-input/emudeck_chiaki_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
