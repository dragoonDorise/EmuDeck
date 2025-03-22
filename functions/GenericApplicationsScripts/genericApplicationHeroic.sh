#!/usr/bin/env bash

# genericApplicationHeroic

# Variables
Heroic_emuName="Heroic-Games-Launcher"
# shellcheck disable=2034,2154
Heroic_emuType="${emuDeckEmuTypeAppImage}"
# shellcheck disable=2154
Heroic_emuPath="${emusFolder}/Heroic-Games-Launcher.AppImage"

# Install
# shellcheck disable=2120
Heroic_install () {
	setMSG "Installing ${Heroic_emuName}."

    local showProgress="${1}"
	installEmuAI "${Heroic_emuName}" "" "$( getReleaseURLGH "Heroic-Games-Launcher/HeroicGamesLauncher" ".AppImage" )" "" "" "genericapplication" "${showProgress}"
}

# ApplyInitialSettings
Heroic_init () {
	echo "NYI"
}

# Update appimage
Heroic_update () {
	setMSG "Updating ${Heroic_emuName} settings."
	rm -f "${Heroic_emuPath}"
	Heroic_install
}

# Uninstall
Heroic_uninstall () {
	setMSG "Uninstalling ${Heroic_emuName}."
	uninstallEmuAI "${Heroic_emuName}" "" "" "genericapplication"
}

# Check if installed
Heroic_IsInstalled () {
	if [ -f "${Heroic_emuPath}" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Heroic_addSteamInputProfile () {
	echo "NYI"
}
