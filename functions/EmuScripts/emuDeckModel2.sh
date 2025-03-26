#!/usr/bin/env bash

# emuDeckModel2

# Variables
Model2_emuName="Model-2-Emulator"
# shellcheck disable=2034,2154
Model2_emuType="${emuDeckEmuTypeWindows}"
# shellcheck disable=2154
Model2_emuPath="${romsPath}/model2/EMULATOR.EXE"
Model2_configFile="${romsPath}/model2/EMULATOR.INI"
Model2_ProtonGEVersion="8.0-5-3"
Model2_ProtonGEURL="https://github.com/Open-Wine-Components/ULWGL-Proton/releases/download/ULWGL-Proton-${Model2_ProtonGEVersion}/ULWGL-Proton-${Model2_ProtonGEVersion}.tar.gz"
ULWGL_toolPath="${HOME}/.local/share/ULWGL"
# shellcheck disable=2034
ULWGL_githubRepo="https://github.com/Open-Wine-Components/ULWGL-launcher.git"
# shellcheck disable=2034
ULWGL_githubBranch="main"

# cleanupOlderThings
Model2_cleanup () {
	echo "NYI"
}

# Install
Model2_install () {
	setMSG "Installing ${Model2_emuName}"

	# Create the ROMs and pfx directory if they do not exist
	mkdir -p "${romsPath}/model2/roms"
	mkdir -p "${romsPath}/model2/pfx"

	# shellcheck disable=2154
	if safeDownload "Model2" "https://github.com/PhoenixInteractiveNL/edc-repo0004/raw/master/m2emulator/1.1a.7z" "${romsPath}/model2/Model2.7z" "${showProgress}"; then
		7za e -y "${romsPath}/model2/Model2.7z" -o"${romsPath}/model2"
		rm -f "${romsPath}/model2/Model2.7z"
	else
		return 1
	fi

	# shellcheck disable=2154
	cp "${emudeckBackend}/tools/launchers/model-2-emulator.sh" "${toolsPath}/launchers/model-2-emulator.sh"
	cp "${emudeckBackend}/tools/launchers/model-2-emulator.sh" "${romsPath}/model2/model-2-emulator.sh"
	cp "${emudeckBackend}/tools/launchers/model-2-emulator.sh" "${romsPath}/emulators/model-2-emulator.sh"

	chmod +x "${toolsPath}/launchers/model-2-emulator.sh"
	chmod +x "${romsPath}/emulators/model-2-emulator.sh"
	chmod +x "${romsPath}/model2/model-2-emulator.sh"

  	createDesktopShortcut   "${HOME}/.local/share/applications/Model 2 Emulator (Proton).desktop" \
							"${Model2_emuName} (Proton)" \
							"${toolsPath}/launchers/model-2-emulator.sh"  \
							"False"
}

# ApplyInitialSettings
Model2_init () {
	setMSG "Initializing ${Model2_emuName} settings."
	rsync -avhp "${emudeckBackend}/configs/model2/" "${romsPath}/model2" --backup --suffix=.bak
	Model2_downloadProtonGE
	Model2ULWGL_install
	#SRM_createParsers
	Model2_flushEmulatorLauncher
	Model2_addSteamInputProfile
	# shellcheck disable=2154
	if [ -e "${ESDE_toolPath}" ] || [ -f "${toolsPath}/${ESDE_downloadedToolName}" ] || [ -f "${toolsPath}/$ESDE_oldtoolName.AppImage" ]; then
		Model2_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi
}

# addESConfig
Model2_addESConfig () {
	ESDE_junksettingsFile
	ESDE_addCustomSystemsFile
	ESDE_setEmulationFolder

	# shellcheck disable=2154
	if [[ $(grep -rnw "${es_systemsFile}" -e 'model2') == "" ]]; then
		# shellcheck disable=2016 # These variables aren't for bash.
		xmlstarlet ed -S --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'model2' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Sega Model 2' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/model2/roms' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.zip .ZIP' \
		--subnode '$newSystem' --type elem --name 'commandP' -v "/usr/bin/bash ${toolsPath}/launchers/model-2-emulator.sh %BASENAME%" \
		--insert '$newSystem/commandP' --type attr --name 'label' --value "Model 2 Emulator (Proton)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'arcade' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'model2' \
		-r 'systemList/system/commandP' -v 'command' \
		"${es_systemsFile}"

		#format doc to make it look nice
		xmlstarlet fo "${es_systemsFile}" > "${es_systemsFile}.tmp" && mv "${es_systemsFile}.tmp" "${es_systemsFile}"
		echo "Model 2 added to EmulationStation-DE custom_systems"
	fi
}

# update
Model2_update () {
	setMSG "Updating ${Model2_emuName} settings."
	rsync -avhp "${emudeckBackend}/configs/model2/" "${romsPath}/model2" --ignore-existing
	Model2ULWGL_install
	Model2_flushEmulatorLauncher
	Model2_addSteamInputProfile
}

# ConfigurePaths
Model2_setEmulationFolder () {
	setMSG "Setting ${Model2_emuName} Emulation Folder"
	echo "NYI"
}

# WipeSettings
Model2_wipeSettings () {
	# shellcheck disable=2154
	rm -rf "${Model2_Settings}"
}

# Uninstall
Model2_uninstall () {
	if [ -d "${HOME}/.local/share/Steam" ]; then
		STEAMPATH="${HOME}/.local/share/Steam"
	elif [ -d "${HOME}/.steam/steam" ]; then
		STEAMPATH="${HOME}/.steam/steam"
	else
		echo "Steam install not found"
	fi

	setMSG "Uninstalling ${Model2_emuName}. Saves and ROMs will be retained in the ROMs folder."
	{
		find "${romsPath}/model2" -mindepth 1 -name roms -prune -o -exec rm -rf '{}' \;
		rm -rf "${HOME}/.local/share/applications/Model 2 Emulator (Proton).desktop"
		rm -rf "${STEAMPATH}/compatibilitytools.d/ULWGL-Proton-8.0-5-3"
		rm -rf "${HOME}/.local/share/ULWGL"
	} &> /dev/null
	rm -rf "${toolsPath}/launchers/model-2-emulator.sh"
	rm -rf "${romsPath}/emulators/model-2-emulator.sh"
	rm -rf "${romsPath}/model2/model-2-emulator.sh"
    Model2_wipeSettings
}

# setABXYstyle
Model2_setABXYstyle () {
	echo "NYI"
}

# finalExec - Extra stuff
Model2_finalize () {
	Model2_cleanup
}

# IsInstalled
Model2_IsInstalled () {
	if [ -e "${Model2_emuPath}" ]; then
		echo "true"
	else
		echo "false"
	fi
}

# resetConfig
Model2_resetConfig () {
	mv  "${Model2_configFile}" "${Model2_configFile}.bak" &>/dev/null
	Model2_init &>/dev/null && echo "true" || echo "false"
}

# downloadProtonGE
Model2_downloadProtonGE () {
	if [ -d "${HOME}/.local/share/Steam" ]; then
		STEAMPATH="${HOME}/.local/share/Steam"
	elif [ -d "${HOME}/.steam/steam" ]; then
		STEAMPATH="${HOME}/.steam/steam"
	else
		echo "Steam install not found"
	fi

	mkdir -p "${STEAMPATH}/compatibilitytools.d"

	if [ ! -d "${STEAMPATH}/compatibilitytools.d/ULWGL-Proton-${Model2_ProtonGEVersion}" ]; then
		if safeDownload "Model2_ProtonGE" "$Model2_ProtonGEURL"  "${STEAMPATH}/compatibilitytools.d/${Model2_ProtonGEVersion}.tar.gz"  "${showProgress}"; then
			{ tar -xvzf "${STEAMPATH}/compatibilitytools.d/${Model2_ProtonGEVersion}.tar.gz" -C "${STEAMPATH}/compatibilitytools.d"; } &> /dev/null
			rm -f "${STEAMPATH}/compatibilitytools.d/${Model2_ProtonGEVersion}.tar.gz"
		else
			return 1
		fi
	else
		echo "${Model2_ProtonGEVersion} already installed"
		return 1
	fi
}

# ULWGL_install
Model2ULWGL_install() {
	mkdir -p "${ULWGL_toolPath}"

	#ulwglURL="$(getReleaseURLGH "Open-Wine-Components/ULWGL-launcher" "ULWGL-launcher.tar.gz")"
	# Freezing ULWGL for now.

	# shellcheck disable=2154
	echo "${ulwglURL}"

	if safeDownload "ULWGL" "https://github.com/Open-Wine-Components/ULWGL-launcher/releases/download/0.1-RC3/ULWGL-launcher.tar.gz" "${ULWGL_toolPath}/ULWGL-launcher.tar.gz" "${showProgress}"; then
		{ tar -xvzf "${ULWGL_toolPath}/ULWGL-launcher.tar.gz" -C "${ULWGL_toolPath}"; } &> /dev/null
	else
		return 1
	fi
}

# flushEmulatorLauncher
Model2_flushEmulatorLauncher () {
	flushEmulatorLaunchers "model-2-emulator"
}

# Add Steam Input Profile
Model2_addSteamInputProfile () {
	setMSG "Adding ${Model2_emuName} Steam Input Profile."
	rsync -r --exclude='*/' "${emudeckBackend}/configs/steam-input/emudeck_steam_deck_light_gun_controls.vdf" "${HOME}/.steam/steam/controller_base/templates/emudeck_steam_deck_light_gun_controls.vdf"
}
