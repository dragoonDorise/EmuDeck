#!/usr/bin/env bash

# remotePlayShadow

# Variables
ShadowPC_emuName="ShadowPC"
# shellcheck disable=2034,2154
ShadowPC_emuType="${emuDeckEmuTypeAppImage}"
# shellcheck disable=2154
ShadowPC_emuPath="${emusFolder}/ShadowPC.AppImage"
ShadowPC_releaseURL="https://update.Shadow.tech/launcher/prod/linux/ubuntu_18.04/ShadowPC.AppImage"

# Install
# shellcheck disable=2120
ShadowPC_install () {
	setMSG "Installing ${ShadowPC_emuName}."

    local showProgress=$1
	#local installShadowPC=$(wget -q "${ShadowPC_releaseURL}" -P ${ShadowPC_emuPath})
	installEmuAI "${ShadowPC_emuName}" "" "${ShadowPC_releaseURL}" "" "" "remoteplay" "${showProgress}"
}

# ApplyInitialSettings
ShadowPC_init () {
	echo "NYI"
	#setMSG "Initializing ${ShadowPC_emuName} settings."	
	#$ShadowPC_addSteamInputProfile
}

# Update appimage
ShadowPC_update () {
	setMSG "Updating ${ShadowPC_emuName} settings." 
	rm -f "${ShadowPC_emuPath}"
	ShadowPC_install
}

# Uninstall
ShadowPC_uninstall () {
	setMSG "Uninstalling ${ShadowPC_emuName}."
	uninstallEmuAI "${ShadowPC_emuName}" "" "" "remoteplay"
}

# Check if installed
ShadowPC_IsInstalled () {
	if [ -f "${ShadowPC_emuPath}" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
ShadowPC_addSteamInputProfile () {
	echo "NYI"
	#rsync -r "$emudeckBackend/configs/steam-input/emudeck_ShadowPC_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
