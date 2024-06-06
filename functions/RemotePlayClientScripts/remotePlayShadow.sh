#!/bin/bash

# Variables
ShadowPC_emuName="ShadowPC"
ShadowPC_emuType="AppImage"
ShadowPC_emuPath="$HOME/Applications/ShadowPC.AppImage"
ShadowPC_releaseURL="https://update.Shadow.tech/launcher/prod/linux/ubuntu_18.04/ShadowPC.AppImage"

# Install
ShadowPC_install() {
	setMSG "Installing $ShadowPC_emuName."

    local showProgress=$1
	#local installShadowPC=$(wget -q $ShadowPC_releaseURL -P $ShadowPC_emuPath)
	installEmuAI "ShadowPC" $ShadowPC_releaseURL "" "" "$showProgress"


	cp "$EMUDECKGIT/tools/remoteplayclients/ShadowPC.sh" "$romsPath/remoteplay"
	chmod +x "$romsPath/remoteplay/ShadowPC.sh"
}

# ApplyInitialSettings
ShadowPC_init() {
	echo "NYI"
	#setMSG "Initializing $ShadowPC_emuName settings."	
	#$ShadowPC_addSteamInputProfile
}

# Update appimage
ShadowPC_update() {
	setMSG "Updating $ShadowPC_emuName settings."
	rm -f "$ShadowPC_emuPath"
	ShadowPC_install
}

# Uninstall
ShadowPC_uninstall() {
	setMSG "Uninstalling $ShadowPC_emuName."
	rm -f "$ShadowPC_emuPath"
	rm -f "$romsPath/remoteplay/ShadowPC.sh"
}

# Check if installed
ShadowPC_IsInstalled() {
	if [ -f "$ShadowPC_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
ShadowPC_addSteamInputProfile() {
	echo "NYI"
	#rsync -r "$EMUDECKGIT/configs/steam-input/emudeck_ShadowPC_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
