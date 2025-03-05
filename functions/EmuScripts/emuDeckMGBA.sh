#!/usr/bin/env bash

# emuDeckMGBA

# Variables
mGBA_emuName="mGBA"
# shellcheck disable=2034,2154
mGBA_emuType="${emuDeckEmuTypeAppImage}"
# shellcheck disable=SC2154
mGBA_emuPath="${emusFolder}/mGBA.AppImage"
mGBA_configFile="${HOME}/.config/mgba/config.ini"

# cleanupOlderThings
mGBA_cleanup () {
	echo "NYI"
}

# Install
# shellcheck disable=2120
mGBA_install () {
	echo "Begin mGBA Install"
	local showProgress="${1}"
	if installEmuAI "${mGBA_emuName}" "" "$(getReleaseURLGH "mgba-emu/mgba" "x64.appimage")" "" "" "emulator" "${showProgress}"; then #mGBA.AppImage
		:
	else
		return 1
	fi
}

# Fix for autoupdate
Mgba_install () {
	mGBA_install
}

# ApplyInitialSettings
mGBA_init () {
	setMSG "Initializing ${mGBA_emuName} settings."
	# shellcheck disable=2154
	configEmuAI "${mGBA_emuName}" "config" "${HOME}/.config/mgba" "${emudeckBackend}/configs/mgba" "true"
	mGBA_setupStorage
	mGBA_setEmulationFolder
	mGBA_setupSaves
	#SRM_createParsers
	mGBA_addSteamInputProfile
	mGBA_flushEmulatorLauncher
	mGBA_addParser
}

# update
mGBA_update () {
	setMSG "Updating ${mGBA_emuName} settings."
	configEmuAI "${mGBA_emuName}" "config" "${HOME}/.config/mgba" "${emudeckBackend}/configs/mgba"
	mGBA_setupStorage
	mGBA_setEmulationFolder
	mGBA_setupSaves
	mGBA_addSteamInputProfile
	mGBA_flushEmulatorLauncher
}

# ConfigurePaths
mGBA_setEmulationFolder () {
	setMSG "Setting ${mGBA_emuName} Emulation Folder"

	LastROMFolderSetting='lastDirectory='
	# shellcheck disable=2154
	changeLine "$LastROMFolderSetting" "${LastROMFolderSetting}${romsPath}/gba" "${mGBA_configFile}"
}

# SetupSaves
mGBA_setupSaves () {
	# shellcheck disable=2154
	mkdir -p "${savesPath}/mgba/saves"
	mkdir -p "${savesPath}/mgba/states"

	SaveFilePathSetting='savegamePath='
	SavestatePathSetting='savestatePath='

	changeLine "${SaveFilePathSetting}" "${SaveFilePathSetting}${savesPath}/mgba/saves" "${mGBA_configFile}"
	changeLine "${SavestatePathSetting}" "${SavestatePathSetting}${savesPath}/mgba/states" "${mGBA_configFile}"
}

# SetupStorage
mGBA_setupStorage () {
	# shellcheck disable=2154
	mkdir -p "${storagePath}/mgba/cheats"
	mkdir -p "${storagePath}/mgba/patches"
	mkdir -p "${storagePath}/mgba/screenshots"

	CheatsPathSetting='cheatsPath='
	PatchesPathSetting='patchPath='
	ScreenshotsPathSetting='screenshotPath='

	changeLine "${CheatsPathSetting}" "${CheatsPathSetting}${storagePath}/mgba/cheats" "${mGBA_configFile}"
	changeLine "${PatchesPathSetting}" "${PatchesPathSetting}${storagePath}/mgba/patches" "${mGBA_configFile}"
	changeLine "${ScreenshotsPathSetting}" "${ScreenshotsPathSetting}${storagePath}/mgba/screenshots" "${mGBA_configFile}"
}

# WipeSettings
mGBA_wipe () {
	setMSG "Wiping ${mGBA_emuName} settings."
	rm -rf "${HOME}/.config/mgba"
}

# Uninstall
mGBA_uninstall () {
	setMSG "Uninstalling ${mGBA_emuName}."
	removeParser "nintendo_gb_mgba.json"
	removeParser "nintendo_gba_mgba.json"
	removeParser "nintendo_gbc_mgba.json"
	uninstallEmuAI "${mGBA_emuName}" "" "" "emulator"
}

# setABXYstyle
mGBA_setABXYstyle () {
	echo "NYI"
}

# Migrate
mGBA_migrate () {
	echo "NYI"
}

# WideScreenOn
mGBA_wideScreenOn () {
	echo "NYI"
}

# WideScreenOff
mGBA_wideScreenOff () {
	echo "NYI"
}

# BezelOn
mGBA_bezelOn () {
	echo "NYI"
}

# BezelOff
mGBA_bezelOff () {
	echo "NYI"
}

# IsInstalled
mGBA_IsInstalled () {
	if [ -e "${mGBA_emuPath}" ]; then
		echo "true"
	else
		echo "false"
	fi
}

# resetConfig
mGBA_resetConfig () {
	mGBA_init &>/dev/null && echo "true" || echo "false"
}

# finalExec - Extra stuff
mGBA_finalize () {
	echo "NYI"
}

# Add Steam Input Profile
mGBA_addSteamInputProfile () {
	addSteamInputCustomIcons
	setMSG "Adding ${mGBA_emuName} Steam Input Profile."
	#rsync -r "${emudeckBackend}/configs/steam-input/mGBA_controller_config.vdf" "${HOME}/.steam/steam/controller_base/templates/"
	rsync -r --exclude='*/' "${emudeckBackend}/configs/steam-input/" "${HOME}/.steam/steam/controller_base/templates/"
}

# flushEmulatorLauncher
mGBA_flushEmulatorLauncher () {
	flushEmulatorLaunchers "mgba"
}

# addParser
mGBA_addParser () {
	addParser "nintendo_gb_mgba.json"
	addParser "nintendo_gba_mgba.json"
	addParser "nintendo_gbc_mgba.json"
}

