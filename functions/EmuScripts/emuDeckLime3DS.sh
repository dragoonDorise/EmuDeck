#!/usr/bin/env bash

# emuDeckLime3DS

# Variables
Lime3DS_emuName="Lime3DS"
# shellcheck disable=2034,2154
Lime3DS_emuType="${emuDeckEmuTypeAppImage}"
# shellcheck disable=2154
Lime3DS_emuPath="${emusFolder}/lime3ds-gui.AppImage"
# shellcheck disable=2034
Lime3DS_releaseURL=""
Lime3DS_configFile="${HOME}/.config/lime3ds-emu/qt-config.ini"
Lime3DS_configPath="${HOME}/.config/lime3ds-emu"
# shellcheck disable=2034
Lime3DS_texturesPath="${HOME}/.config/lime3ds-emu/load/textures"

# Install
Lime3DS_install () {
	echo "Begin ${Lime3DS_emuName} Install"
	local showProgress="${1}"
	if installEmuAI "${Lime3DS_emuName}" "" "$(getReleaseURLGH "Lime3DS/lime3ds-archive" "tar.gz" "")" "lime3ds" "tar.gz" "emulator" "${showProgress}"; then #lime3ds-gui.AppImage
		mkdir "${emusFolder}/lime3ds-temp"
		tar -xvzf "${emusFolder}/lime3ds.tar.gz" -C "${emusFolder}/lime3ds-temp" --strip-components 1
		if [ -f "${emusFolder}/lime3ds-temp/lime3ds-gui.AppImage" ]; then
			mv "${emusFolder}/lime3ds-temp/lime3ds-gui.AppImage" "${Lime3DS_emuPath}"
		elif [ -f "${emusFolder}/lime3ds-temp/lime3ds.AppImage" ]; then
			mv "${emusFolder}/lime3ds-temp/lime3ds.AppImage" "${Lime3DS_emuPath}"
		else
			rm -rf "${emusFolder}/lime3ds-temp"
			rm -rf "${emusFolder}/lime3ds.tar.gz"
			return 1
		fi
		chmod +x "${emusFolder}/lime3ds-gui.AppImage"
		rm -rf "${emusFolder}/lime3ds-temp"
		rm -rf "${emusFolder}/lime3ds.tar.gz"
	else
		return 1
	fi
}

# ApplyInitialSettings
Lime3DS_init () {
	setMSG "Initializing ${Lime3DS_emuName} settings."
	# shellcheck disable=2154
	configEmuAI "${Lime3DS_emuName}" "lime3ds-emu"  "${Lime3DS_configPath}" "${emudeckBackend}/configs/lime3ds" "true"
	Lime3DS_setEmulationFolder
	Lime3DS_setupStorage
	Lime3DS_setupSaves
	Lime3DS_addSteamInputProfile
	Lime3DS_flushEmulatorLauncher
	Lime3DS_setupTextures
	Lime3DS_addParser
}

# Update
Lime3DS_update () {
	setMSG "Updating ${Lime3DS_emuName} settings."
	configEmuAI "${Lime3DS_emuName}" "lime3ds-emu"  "${Lime3DS_configPath}" "${emudeckBackend}/configs/lime3ds"
	Lime3DS_setupStorage
	Lime3DS_setEmulationFolder
	Lime3DS_setupSaves
	Lime3DS_addSteamInputProfile
	Lime3DS_flushEmulatorLauncher
	Lime3DS_setupTextures
}

# setupStorage
Lime3DS_setupStorage () {
	# shellcheck disable=2154
	mkdir -p "${storagePath}/lime3ds/"

	if [ ! -d "${storagePath}/lime3ds/sdmc" ] && { [ ! -d "${HOME}/.var/app/io.github.lime3ds.Lime3DS/data/lime3ds-emu/sdmc" ] || [ ! -d "${HOME}/.local/share/lime3ds-emu" ]; } && { [ -d "${HOME}/.var/app/org.citra_emu.citra/data/citra-emu/sdmc" ] || [ -d "${HOME}/.local/share/citra-emu/sdmc" ] || [ -d "${storagePath}/citra/sdmc" ]; } ; then
		echo "Lime3DS SDMC does not exist in storage path and does not exist in the original Flatpak or AppImage paths. Citra SDMC folder found, copying Citra SDMC folder."

		echo -e ""
		setMSG "Copying Citra SDMC to the Lime3DS SDMC folder"
		echo -e ""

		mkdir -p "${storagePath}/lime3ds"

		if [ -d "${storagePath}/citra/sdmc" ]; then
			rsync -av  --ignore-existing "${storagePath}/citra/sdmc" "${storagePath}"/lime3ds
		elif [ -d "${HOME}/.var/app/org.citra_emu.citra/data/citra-emu/sdmc" ]; then
			rsync -av --ignore-existing "${HOME}/.var/app/org.citra_emu.citra/data/citra-emu/sdmc" "${storagePath}"/lime3ds
		elif [ -d "${HOME}/.local/share/citra-emu/sdmc" ]; then
			rsync -av  --ignore-existing "${HOME}/.local/share/citra-emu/sdmc" "${storagePath}"/lime3ds
		else
			mkdir -p "${storagePath}/citra/sdmc"
		fi
	fi

	if [ ! -d "${storagePath}/lime3ds/sdmc" ] && { [ -d "${HOME}/.var/app/io.github.lime3ds.Lime3DS/data/lime3ds-emu/sdmc" ] || [ -d "${HOME}/.local/share/lime3ds-emu/sdmc" ]; }; then
		echo "Lime3DS SDMC does not exist in storage path. Found Lime3DS SDMC in original path, copying to storage folder."

		echo -e ""
		setMSG "Copying Lime3DS SDMC to the Emulation/storage folder"
		echo -e ""

		mkdir -p "${storagePath}/lime3ds"

		if [ -d "${HOME}/.var/app/io.github.lime3ds.Lime3DS/data/lime3ds-emu/sdmc" ]; then
			rsync -av  --ignore-existing "${HOME}/.var/app/io.github.lime3ds.Lime3DS/data/lime3ds-emu/sdmc" "${storagePath}"/lime3ds/ && rm -rf "${HOME}/.var/app/io.github.lime3ds.Lime3DS/data/lime3ds-emu/sdmc"

		elif [ -d "${HOME}/.local/share/lime3ds-emu/sdmc" ]; then
			rsync -av  --ignore-existing "${HOME}/.local/share/lime3ds-emu/sdmc" "${storagePath}"/lime3ds/ && rm -rf "${HOME}/.local/share/lime3ds-emu/sdmc"
		else
			mkdir -p "${storagePath}/lime3ds/sdmc"
		fi
	else
		echo "Lime3DS SDMC does not exist anywhere. Creating SDMC folder."
		mkdir -p "${storagePath}/lime3ds/sdmc"
	fi

	if [ ! -d "${storagePath}/lime3ds/nand" ] && { [ ! -d "${HOME}/.var/app/io.github.lime3ds.Lime3DS/data/lime3ds-emu/nand" ] || [ ! -d "${HOME}/.local/share/lime3ds-emu" ]; } && { [ -d "${HOME}/.var/app/org.citra_emu.citra/data/citra-emu/nand" ] || [ -d "${HOME}/.local/share/citra-emu/nand" ] || [ -d "${storagePath}/citra/nand" ]; }; then
		echo "Lime3DS NAND does not exist in storage path and does not exist in the original Flatpak or AppImage paths. Citra NAND folder found, copying Citra NAND folder."

		echo -e ""
		setMSG "Copying Citra NAND to the Lime3DS folder"
		echo -e ""

		mkdir -p "${storagePath}/lime3ds"

		if [ -d "${storagePath}/citra/nand" ]; then
			rsync -av  --ignore-existing "${storagePath}/citra/nand" "${storagePath}"/lime3ds
		elif [ -d "${HOME}/.var/app/org.citra_emu.citra/data/citra-emu/nand" ]; then
			rsync -av  --ignore-existing "${HOME}/.var/app/org.citra_emu.citra/data/citra-emu/nand" "${storagePath}"/lime3ds
		elif [ -d "${HOME}/.local/share/citra-emu/nand" ]; then
			rsync -av  --ignore-existing "${HOME}/.local/share/citra-emu/nand" "${storagePath}"/lime3ds
		else
			mkdir -p "${storagePath}/citra/nand"
		fi
	fi

	if [ ! -d "${storagePath}/lime3ds/nand" ] && { [ -d "${HOME}/.var/app/io.github.lime3ds.Lime3DS/data/lime3ds-emu/nand" ] || [ -d "${HOME}/.local/share/lime3ds-emu/nand" ]; }; then
		echo "Lime3DS NAND does not exist in storage path. Found Lime3DS NAND in original path, copying to storage folder."

		echo -e ""
		setMSG "Copying Citra NAND to the Lime3DS NAND folder"
		echo -e ""

		mkdir -p "${storagePath}/lime3ds"

		if [ -d "${HOME}/.var/app/io.github.lime3ds.Lime3DS/data/lime3ds-emu/nand" ]; then
			rsync -av  --ignore-existing "${HOME}/.var/app/io.github.lime3ds.Lime3DS/data/lime3ds-emu/nand" "${storagePath}"/lime3ds/ && rm -rf "${HOME}/.var/app/io.github.lime3ds.Lime3DS/data/lime3ds-emu/nand"
		elif [ -d "${HOME}/.local/share/lime3ds-emu/nand" ]; then
			rsync -av  --ignore-existing "${HOME}/.local/share/lime3ds-emu/nand" "${storagePath}"/lime3ds/ && rm -rf "${HOME}/.local/share/lime3ds-emu/nand"
		else
			mkdir -p "${storagePath}/lime3ds/nand"
		fi
	else
		echo "Lime3DS NAND does not exist anywhere. Creating NAND folder."
		mkdir -p "${storagePath}/lime3ds/nand"
	fi

	# Cheats and Texture Packs
	# Cheats
	mkdir -p "${HOME}/.local/share/lime3ds-emu/cheats"
	linkToStorageFolder lime3ds cheats "${HOME}/.local/share/lime3ds-emu/cheats"
	# Texture Pack
	mkdir -p "${HOME}/.local/share/lime3ds-emu/load/textures"
	linkToStorageFolder lime3ds textures "${HOME}/.local/share/lime3ds-emu/load/textures"
}

# ConfigurePaths
Lime3DS_setEmulationFolder () {
	setMSG "Setting ${Lime3DS_emuName} Emulation Folder"

	mkdir -p "${Lime3DS_configPath}"
	gameDirOpt='Paths\\gamedirs\\3\\path='
	# shellcheck disable=2154
	newGameDirOpt='Paths\\gamedirs\\3\\path='"${romsPath}/n3ds"
	sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "${Lime3DS_configFile}"

	nandDirOpt='nand_directory='
	newnandDirOpt='nand_directory='"${storagePath}/lime3ds/nand/"
	sed -i "/${nandDirOpt}/c\\${newnandDirOpt}" "${Lime3DS_configFile}"

	sdmcDirOpt='sdmc_directory='
	newsdmcDirOpt='sdmc_directory='"${storagePath}/lime3ds/sdmc/"
	sed -i "/${sdmcDirOpt}/c\\${newsdmcDirOpt}" "${Lime3DS_configFile}"

	mkdir -p "${storagePath}/lime3ds/screenshots/"
	screenshotsDirOpt='Paths\\screenshotPath='
	newscreenshotDirOpt='Paths\\screenshotPath='"${storagePath}/lime3ds/screenshots/"
	sed -i "/${screenshotsDirOpt}/c\\${newscreenshotDirOpt}" "${Lime3DS_configFile}"

	# True/False configs
	sed -i 's/nand_directory\\default=true/nand_directory\\default=false/' "${Lime3DS_configFile}"
	sed -i 's/sdmc_directory\\default=true/sdmc_directory\\default=false/' "${Lime3DS_configFile}"
	sed -i 's/use_custom_storage=false/use_custom_storage=true/' "${Lime3DS_configFile}"
	sed -i 's/use_custom_storage\\default=true/use_custom_storage\\default=false/' "${Lime3DS_configFile}"

	# Vulkan Graphics
	sed -E 's/layout_option=[0-9]+/layout_option=5/g' "${Lime3DS_configFile}"
	sed -i 's/layout_option\\default=true/layout_option\\default=false/' "${Lime3DS_configFile}"

	# Setup symlink for AES keys
	# shellcheck disable=2154
	mkdir -p "${biosPath}/lime3ds/"
	mkdir -p "${HOME}/.local/share/lime3ds-emu/sysdata"
	ln -sn "${HOME}/.local/share/lime3ds-emu/sysdata" "${biosPath}/lime3ds/keys"
}

# SetupSaves
Lime3DS_setupSaves () {
	mkdir -p "${HOME}/.local/share/lime3ds-emu/states"
	linkToSaveFolder lime3ds saves "${storagePath}/lime3ds/sdmc"
	linkToSaveFolder lime3ds states "${HOME}/.local/share/lime3ds-emu/states"
}

# Set up textures
Lime3DS_setupTextures () {
	mkdir -p "${HOME}/.local/share/lime3ds-emu/load/textures"
	linkToTexturesFolder lime3ds textures "${HOME}/.local/share/lime3ds-emu/load/textures"
}

# WipeSettings
Lime3DS_wipe () {
	setMSG "Wiping ${Lime3DS_emuName} config directory. (factory reset)"
	rm -rf "${HOME}/.config/lime3ds-emu"
}

# Uninstall
Lime3DS_uninstall () {
	setMSG "Uninstalling ${Lime3DS_emuName}."
	removeParser "nintendo_3ds_lime3ds.json"
	uninstallEmuAI "${Lime3DS_emuName}" "lime3ds-gui" "" "emulator"
}

# setABXYstyle
Lime3DS_setABXYstyle () {
	sed -i '/button_a/s/button:1/button:0/' "${Lime3DS_configFile}"
	sed -i '/button_b/s/button:0/button:1/' "${Lime3DS_configFile}"
	sed -i '/button_x/s/button:3/button:2/' "${Lime3DS_configFile}"
	sed -i '/button_y/s/button:2/button:3/' "${Lime3DS_configFile}"
}

# setBAYXstyle
Lime3DS_setBAYXstyle () {
	sed -i '/button_a/s/button:0/button:1/' "${Lime3DS_configFile}"
	sed -i '/button_b/s/button:1/button:0/' "${Lime3DS_configFile}"
	sed -i '/button_x/s/button:2/button:3/' "${Lime3DS_configFile}"
	sed -i '/button_y/s/button:3/button:2/' "${Lime3DS_configFile}"
}

# finalExec - Extra stuff
Lime3DS_finalize () {
	echo "NYI"
}

# IsInstalled
Lime3DS_IsInstalled () {
	if [ -e "${Lime3DS_emuPath}" ]; then
		echo "true"
	else
		echo "false"
	fi
}

# resetConfig
Lime3DS_resetConfig () {
	Lime3DS_init &>/dev/null && echo "true" || echo "false"
}

# Add Steam Input Profile
Lime3DS_addSteamInputProfile () {
	addSteamInputCustomIcons
	setMSG "Adding ${Lime3DS_emuName} Steam Input Profile."
	#rsync -r "${emudeckBackend}/configs/steam-input/Lime3DS_controller_config.vdf" "${HOME}/.steam/steam/controller_base/templates/"
	rsync -r --exclude='*/' "${emudeckBackend}/configs/steam-input/" "${HOME}/.steam/steam/controller_base/templates/"
}

# setResolution
Lime3DS_setResolution () {
	# shellcheck disable=2154
	case "${lime3dsResolution}" in
		"720P") multiplier=3;;
		"1080P") multiplier=5;;
		"1440P") multiplier=6;;
		"4K") multiplier=9;;
		*) echo "Error"; return 1;;
	esac

	setConfig "resolution_factor" "${multiplier}" "${Lime3DS_configFile}"
}

# flushEmulatorLauncher
Lime3DS_flushEmulatorLauncher () {
	flushEmulatorLaunchers "lime3ds"
}

# addParser
Lime3DS_addParser () {
	addParser "nintendo_3ds_lime3ds.json"
}