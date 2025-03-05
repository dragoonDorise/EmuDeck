#!/usr/bin/env bash

# emuDeckMelonDS

# Variables
melonDS_emuName="MelonDS"
# shellcheck disable=2034,2154
melonDS_emuType="$emuDeckEmuTypeFlatpak"
melonDS_emuPath="net.kuribo64.melonDS"
# shellcheck disable=2034
melonDS_releaseURL=""
melonDS_configFile="${HOME}/.var/app/net.kuribo64.melonDS/config/melonDS/melonDS.ini"

# cleanupOlderThings
# shellcheck disable=2317
melonDS_finalize () {
	echo "NYI"
}

# Install
melonDS_install () {
	setMSG "Installing ${melonDS_emuName}"
	installEmuFP "${melonDS_emuName}" "${melonDS_emuPath}" "emulator" ""
}

# Fix for autoupdate
Melonds_install () {
	melonDS_install
}

# ApplyInitialSettings
melonDS_init () {
	setMSG "Initializing ${melonDS_emuName} settings."
	configEmuFP "${melonDS_emuName}" "${melonDS_emuPath}" "true"
	melonDS_setupStorage
	melonDS_setEmulationFolder
	melonDS_setupSaves
	#SRM_createParsers
	melonDS_addSteamInputProfile
	melonDS_flushEmulatorLauncher
	melonDS_addParser
}

# update
melonDS_update () {
	setMSG "Updating ${melonDS_emuName} settings."
	configEmuFP "${melonDS_emuName}" "${melonDS_emuPath}"
	updateEmuFP "${melonDS_emuName}" "${melonDS_emuPath}" "emulator" ""
	melonDS_setupStorage
	melonDS_setEmulationFolder
	melonDS_setupSaves
	melonDS_addSteamInputProfile
	melonDS_flushEmulatorLauncher
}

# ConfigurePaths
melonDS_setEmulationFolder () {
	setMSG "Setting ${melonDS_emuName} Emulation Folder"

	BIOS9PathSetting='BIOS9Path='
	BIOS7PathSetting='BIOS7Path='
	FirmwarePathSetting='FirmwarePath='
	DSiBIOS9PathSetting='DSiBIOS9Path='
	DSiBIOS7PathSetting='DSiBIOS7Path='
	DSiFirmwarePathSetting='DSiFirmwarePath='
	DSiNANDPathSetting='DSiNANDPath='
	LastROMFolderSetting='LastROMFolder='

	# shellcheck disable=2154
	changeLine "${BIOS9PathSetting}" "${BIOS9PathSetting}${biosPath}/bios9.bin" "${melonDS_configFile}"
	changeLine "${BIOS7PathSetting}" "${BIOS7PathSetting}${biosPath}/bios7.bin" "${melonDS_configFile}"
	changeLine "${FirmwarePathSetting}" "${FirmwarePathSetting}${biosPath}/firmware.bin" "${melonDS_configFile}"
	changeLine "${DSiBIOS9PathSetting}" "${DSiBIOS9PathSetting}${biosPath}/dsi_bios9.bin" "${melonDS_configFile}"
	changeLine "${DSiBIOS7PathSetting}" "${DSiBIOS7PathSetting}${biosPath}/dsi_bios7.bin" "${melonDS_configFile}"
	changeLine "${DSiFirmwarePathSetting}" "${DSiFirmwarePathSetting}${biosPath}/dsi_firmware.bin" "${melonDS_configFile}"
	changeLine "${DSiNANDPathSetting}" "${DSiNANDPathSetting}${biosPath}/dsi_nand.bin" "${melonDS_configFile}"
	# shellcheck disable=2154
	changeLine "${LastROMFolderSetting}" "${LastROMFolderSetting}${romsPath}/nds" "${melonDS_configFile}"
}

# SetupSaves
melonDS_setupSaves () {
	setMSG "Setting ${melonDS_emuName} Saves Folder"

	# shellcheck disable=2154
	mkdir -p "${savesPath}/melonds/saves"
	mkdir -p "${savesPath}/melonds/states"

	SaveFilePathSetting='SaveFilePath='
	SavestatePathSetting='SavestatePath='

	changeLine "${SaveFilePathSetting}" "${SaveFilePathSetting}${savesPath}/melonds/saves" "${melonDS_configFile}"
	changeLine "${SavestatePathSetting}" "${SavestatePathSetting}${savesPath}/melonds/states" "${melonDS_configFile}"
}

# SetupStorage
melonDS_setupStorage () {
	setMSG "Setting ${melonDS_emuName} Storage Folder"

	# Leaving this so user can still place database files here if need be
	# shellcheck disable=2154
	mkdir -p "${storagePath}/melonDS/cheats"

	# Breaks saving cheats in melonDS, commenting out for now
	# CheatFilePathSetting='CheatFilePath='

	# changeLine "$CheatFilePathSetting" "${CheatFilePathSetting}${storagePath}/melonds/cheats" "${melonDS_configFile}"
}

# WipeSettings
melonDS_wipe () {
	setMSG "Wiping ${melonDS_emuName} config directory. (factory reset)"
	rm -rf "${HOME}/.var/app/${melonDS_emuPath}"
}

# Uninstall
melonDS_uninstall () {
	setMSG "Uninstalling ${melonDS_emuName}."
	removeParser "nintendo_nds_melonds.json"
	uninstallEmuFP "${melonDS_emuName}" "${melonDS_emuPath}" "emulator" ""
}

# setABXYstyle
# shellcheck disable=2317
melonDS_setABXYstyle () {
    echo "NYI"
}

# Migrate
melonDS_migrate () {
	echo "NYI"
}

# WideScreenOn
melonDS_wideScreenOn () {
	echo "NYI"
}

# WideScreenOff
melonDS_wideScreenOff () {
	echo "NYI"
}

# BezelOn
melonDS_bezelOn () {
	echo "NYI"
}

# BezelOff
melonDS_bezelOff () {
	echo "NYI"
}

# finalExec - Extra stuff
melonDS_finalize () {
	echo "NYI"
}

# IsInstalled
melonDS_IsInstalled () {
	isFpInstalled "${melonDS_emuPath}"
}

# resetConfig
melonDS_resetConfig () {
	melonDS_init &>/dev/null && echo "true" || echo "false"
}

# Add Steam Input Profile
melonDS_addSteamInputProfile () {
	addSteamInputCustomIcons
	setMSG "Adding ${melonDS_emuName} Steam Input Profile."
	#rsync -r "${emudeckBackend}/configs/steam-input/melonds_controller_config.vdf" "${HOME}/.steam/steam/controller_base/templates/"
	# shellcheck disable=2154
	rsync -r --exclude='*/' "${emudeckBackend}/configs/steam-input/" "${HOME}/.steam/steam/controller_base/templates/"
}

# setResolution
melonDS_setResolution () {
	# shellcheck disable=2154
	case "${melonDSResolution}" in
		"720P") WindowWidth=1024; WindowHeight=768;;
		"1080P") WindowWidth=1536; WindowHeight=1152;;
		"1440P") WindowWidth=2048; WindowHeight=1536;;
		"4K") WindowWidth=2816; WindowHeight=2112;;
		*) echo "Error"; return 1;;
	esac

	RetroArch_setConfigOverride "WindowWidth" "${WindowWidth}" "${melonDS_configFile}"
	RetroArch_setConfigOverride "WindowHeight" "${WindowHeight}" "${melonDS_configFile}"
}

# setABXYstyle
melonDS_setABXYstyle () {
	buttonA='Joy_A='
	buttonB='Joy_B='
	buttonX='Joy_X='
	buttonY='Joy_Y='

	changeLine "${buttonA}" "${buttonA}""0" "${melonDS_configFile}"
	changeLine "${buttonB}" "${buttonB}""1" "${melonDS_configFile}"
	changeLine "${buttonX}" "${buttonX}""2" "${melonDS_configFile}"
	changeLine "${buttonY}" "${buttonY}""3" "${melonDS_configFile}"
}

# setBAYXstyle
melonDS_setBAYXstyle () {
	buttonA='Joy_A='
	buttonB='Joy_B='
	buttonX='Joy_X='
	buttonY='Joy_Y='

	changeLine "${buttonA}" "${buttonA}""1" "${melonDS_configFile}"
	changeLine "${buttonB}" "${buttonB}""0" "${melonDS_configFile}"
	changeLine "${buttonX}" "${buttonX}""3" "${melonDS_configFile}"
	changeLine "${buttonY}" "${buttonY}""2" "${melonDS_configFile}"
}

# flushEmulatorLauncher
melonDS_flushEmulatorLauncher () {
	flushEmulatorLaunchers "melonds"
}

# addParser
melonDS_addParser () {
	addParser "nintendo_nds_melonds.json"
}
