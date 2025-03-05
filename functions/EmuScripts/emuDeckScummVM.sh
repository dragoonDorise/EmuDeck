#!/usr/bin/env bash

# emuDeckScummVM

# Variables
ScummVM_emuName="ScummVM"
# shellcheck disable=2034,2154
ScummVM_emuType="${emuDeckEmuTypeFlatpak}"
ScummVM_emuPath="org.scummvm.ScummVM"
# shellcheck disable=2034
ScummVM_releaseURL=""
ScummVM_configFile="${HOME}/.var/app/org.scummvm.ScummVM/config/scummvm/scummvm.ini"

# cleanupOlderThings
ScummVM_cleanup () {
	echo "NYI"
}

# Install
ScummVM_install () {
	installEmuFP "${ScummVM_emuName}" "${ScummVM_emuPath}" "emulator" ""
}

# Fix for autoupdate
Scummvm_install () {
	ScummVM_install
}

# ApplyInitialSettings
ScummVM_init () {
	configEmuFP "${ScummVM_emuName}" "${ScummVM_emuPath}" "true"
	updateEmuFP "${ScummVM_emuName}" "${ScummVM_emuPath}" "emulator" ""
	ScummVM_setupStorage
	ScummVM_setEmulationFolder
	ScummVM_setupSaves
	#SRM_createParsers
	ScummVM_flushEmulatorLauncher
	ScummVM_setLanguage
}

# setLanguage
ScummVM_setLanguage () {
	setMSG "Setting ScummVM Language"
	# shellcheck disable=2155
	local language=$( locale | grep LANG | cut -d= -f2 | cut -d. -f1 )
	local languageOpt="gui_language="
	newLanguageOpt='gui_language='"${language}"
	changeLine "${languageOpt}" "${newLanguageOpt}" "${ScummVM_configFile}"
}

# update
ScummVM_update () {
	configEmuFP "${ScummVM_emuName}" "${ScummVM_emuPath}"
	ScummVM_setupStorage
	ScummVM_setEmulationFolder
	ScummVM_setupSaves
	ScummVM_flushEmulatorLauncher
}

# ConfigurePaths
ScummVM_setEmulationFolder () {
    gameDirOpt='browser_lastpath='
	# shellcheck disable=2154
    newGameDirOpt="$gameDirOpt""${romsPath}/scummvm"
	changeLine "$gameDirOpt" "$newGameDirOpt" "${ScummVM_configFile}"
}

# SetupSaves
ScummVM_setupSaves () {
	savepath_directoryOpt='savepath='
	newsavepath_directoryOpt="${savepath_directoryOpt}${savesPath}/scummvm/saves"
	changeLine "${savepath_directoryOpt}" "${newsavepath_directoryOpt}" "${ScummVM_configFile}"

	moveSaveFolder scummvm saves "${HOME}/.var/app/org.scummvm.ScummVM/data/scummvm/saves"
}

# SetupStorage
ScummVM_setupStorage () {
	echo "NYI"
}

# WipeSettings
ScummVM_wipe () {
	echo "NYI"
}

# Uninstall
ScummVM_uninstall () {
    uninstallEmuFP "${ScummVM_emuName}" "${ScummVM_emuPath}" "emulator" ""
}

# setABXYstyle
ScummVM_setABXYstyle () {
	echo "NYI"
}

# Migrate
ScummVM_migrate () {
	echo "NYI"
}

# WideScreenOn
ScummVM_wideScreenOn () {
	echo "NYI"
}

# WideScreenOff
ScummVM_wideScreenOff () {
	echo "NYI"
}

# BezelOn
ScummVM_bezelOn () {
	echo "NYI"
}

# BezelOff
ScummVM_bezelOff () {
	echo "NYI"
}

# finalExec - Extra stuff
ScummVM_finalize () {
	echo "NYI"
}

# IsInstalled
ScummVM_IsInstalled () {
	isFpInstalled "${ScummVM_emuPath}"
}

# resetConfig
ScummVM_resetConfig () {
	ScummVM_init &>/dev/null && echo "true" || echo "false"
}

# flushEmulatorLauncher
ScummVM_flushEmulatorLauncher () {
	flushEmulatorLaunchers "scummvm.sh"
}
