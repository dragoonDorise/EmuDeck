#!/usr/bin/env bash

# emuDeckPPSSPP

# Variables
PPSSPP_emuName="PPSSPP"
# shellcheck disable=2034,2154
PPSSPP_emuType="${emuDeckEmuTypeFlatpak}"
PPSSPP_emuPath="org.ppsspp.PPSSPP"
# shellcheck disable=2034
PPSSPP_releaseURL=""
PPSSPP_configFile="${HOME}/.var/app/${PPSSPP_emuPath}/config/ppsspp/PSP/SYSTEM/ppsspp.ini"

# cleanupOlderThings
PPSSPP_cleanup () {
	echo "NYI"
}

# Install
PPSSPP_install () {
	setMSG "Installing ${PPSSPP_emuName}" 
	installEmuFP "${PPSSPP_emuName}" "${PPSSPP_emuPath}" "emulator" ""
}
# Fix for autoupdate
Ppsspp_install () {
	PPSSPP_install
}

# ApplyInitialSettings
PPSSPP_init () {
	setMSG "Initializing ${PPSSPP_emuName} settings."
	configEmuFP "${PPSSPP_emuName}" "${PPSSPP_emuPath}" "true"
	PPSSPP_setupStorage
	PPSSPP_setEmulationFolder
	PPSSPP_setupSaves
	#PPSSPP_addSteamInputProfile
	PPSSPP_setRetroAchievements
	#SRM_createParsers
	PPSSPP_flushEmulatorLauncher
}

# update
PPSSPP_update () {
	setMSG "Updating ${PPSSPP_emuName} settings."
	configEmuFP "${PPSSPP_emuName}" "${PPSSPP_emuPath}"
	updateEmuFP "${PPSSPP_emuName}" "${PPSSPP_emuPath}" "emulator" ""
	PPSSPP_setupStorage
	PPSSPP_setEmulationFolder
	PPSSPP_setupSaves
	#PPSSPP_addSteamInputProfile
	PPSSPP_flushEmulatorLauncher
}

# ConfigurePaths
PPSSPP_setEmulationFolder () {
	setMSG "Setting ${PPSSPP_emuName} Emulation Folder"
	# shellcheck disable=2154
	iniFieldUpdate "${PPSSPP_configFile}" "General" "CurrentDirectory" "${romsPath}/psp"
}

# SetupSaves
PPSSPP_setupSaves () {
	linkToSaveFolder ppsspp saves "${HOME}/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/SAVEDATA"
	linkToSaveFolder ppsspp states "${HOME}/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/PPSSPP_STATE"
}

# SetupStorage
PPSSPP_setupStorage () {
	echo "NYI"
}

# WipeSettings
PPSSPP_wipe () {
   rm -rf "${HOME}/.var/app/${PPSSPP_emuPath}"
}

# Uninstall
PPSSPP_uninstall () {
	uninstallEmuFP "${PPSSPP_emuName}" "${PPSSPP_emuPath}" "emulator" ""
}

# setABXYstyle
PPSSPP_setABXYstyle () {
	echo "NYI"
}

# Migrate
PPSSPP_migrate () {
	echo "NYI"
}

# WideScreenOn
PPSSPP_wideScreenOn () {
	echo "NYI"
}

# WideScreenOff
PPSSPP_wideScreenOff () {
	echo "NYI"
}

# BezelOn
PPSSPP_bezelOn () {
	echo "NYI"
}

# BezelOff
PPSSPP_bezelOff () {
	echo "NYI"
}

# IsInstalled
PPSSPP_IsInstalled () {
	isFpInstalled "${PPSSPP_emuPath}"
}

# resetConfig
PPSSPP_resetConfig () {
	PPSSPP_init &>/dev/null && echo "true" || echo "false"
}

# finalExec - Extra stuff
PPSSPP_finalize () {
	echo "NYI"
}

# retroAchievementsOn
PPSSPP_retroAchievementsOn() {
	iniFieldUpdate "${PPSSPP_configFile}" "Achievements" "AchievementsEnable" "True"
}

# retroAchievementsOff
PPSSPP_retroAchievementsOff() {
	iniFieldUpdate "${PPSSPP_configFile}" "Achievements" "AchievementsEnable" "False"
}

# retroAchievementsHardCoreOn
PPSSPP_retroAchievementsHardCoreOn() {
	iniFieldUpdate "${PPSSPP_configFile}" "Achievements" "AchievementsChallengeMode" "True"

}

# retroAchievementsHardCoreOff
PPSSPP_retroAchievementsHardCoreOff() {
	iniFieldUpdate "${PPSSPP_configFile}" "Achievements" "AchievementsChallengeMode" "False"
}

# retroAchievementsSetLogin
PPSSPP_retroAchievementsSetLogin() {
	# EmuDeck username and token files
	# shellcheck disable=2154
	rau=$(cat "${emudeckFolder}/.rau")
	rat=$(cat "${emudeckFolder}/.rat")

	# Create PPSSPP token file
	PPSSPP_token="${HOME}/.var/app/${PPSSPP_emuPath}/config/ppsspp/PSP/SYSTEM/ppsspp_retroachievements.dat"
	touch "${PPSSPP_token}"

	echo "Evaluate RetroAchievements Login."
	if [ ${#rat} -lt 1 ]; then
		echo "--No token."
	elif [ ${#rau} -lt 1 ]; then
		echo "--No username."
	else
		echo "Valid Retroachievements Username and Password length"

		# Insert username into PPSSPP config file
		iniFieldUpdate "${PPSSPP_configFile}" "Achievements" "AchievementsUserName" "${rau}"

		# Insert token into PPSSPP token file if file is empty. RetroAchievements login does not work if there are multiple tokens in the file.
		if [ -s "${PPSSPP_token}" ]; then
			echo "File is not empty"
		else
			echo "File is empty"
			echo "${rat}" >> "${PPSSPP_token}"
		fi

		# Enable RetroAchievements
		PPSSPP_retroAchievementsOn
	fi
}

# setRetroAchievements
PPSSPP_setRetroAchievements () {
	PPSSPP_retroAchievementsSetLogin
	# shellcheck disable=2154
	if [ "${achievementsHardcore}" == "true" ]; then
		PPSSPP_retroAchievementsHardCoreOn
	else
		PPSSPP_retroAchievementsHardCoreOff
	fi
}

# Add Steam Input Profile
PPSSPP_addSteamInputProfile () {
	addSteamInputCustomIcons
	#setMSG "Adding ${PPSSPP_emuName} Steam Input Profile."
	#rsync -r "$emudeckBackend/configs/steam-input/ppsspp_controller_config.vdf" "${HOME}/.steam/steam/controller_base/templates/"
}

# setResolution
PPSSPP_setResolution () {
	# shellcheck disable=2154
	"${ppssppResolution}"
	echo "NYI"
}

# flushEmulatorLauncher
PPSSPP_flushEmulatorLauncher () {
	flushEmulatorLaunchers "ppsspp"
}
