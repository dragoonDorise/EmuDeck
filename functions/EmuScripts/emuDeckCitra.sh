#!/usr/bin/env bash

# emuDeckCitra

# Variables
Citra_emuName="Citra"
# shellcheck disable=2034,2154
Citra_emuType="${emuDeckEmuTypeAppImage}"
# shellcheck disable=2154
Citra_emuPath="${emusFolder}/citra-qt.AppImage"
# shellcheck disable=2034
Citra_releaseURL=""
Citra_configFile="${HOME}/.config/citra-emu/qt-config.ini"
Citra_configPath="${HOME}/.config/citra-emu"
# shellcheck disable=2034
Citra_texturesPath="${HOME}/.config/citra-emu/load/textures"

# Install
Citra_install () {
	echo "Begin ${Citra_emuName} Install"
	local showProgress="${1}"
	if installEmuAI "${Citra_emuName}" "" "https://github.com/PabloMK7/citra/releases/download/r608383e/citra-linux-appimage-20240927-608383e.tar.gz" "citra" "tar.gz" "emulator" "$showProgress"; then #citra-qt.AppImage
	#if installEmuAI "$Citra_emuName" "" "https://github.com/PabloMK7/citra/releases/download/r518f723/citra-linux-appimage-20240717-518f723.tar.gz" "citra" "tar.gz" "emulator" "$showProgress"; then #citra-qt.AppImage
		mkdir "${emusFolder}/citra-temp"
		tar -xvzf "${emusFolder}/citra.tar.gz" -C "${emusFolder}/citra-temp" --strip-components 1
		mv "${emusFolder}/citra-temp/citra-qt.AppImage" "${emusFolder}"
		rm -rf "${emusFolder}/citra-temp"
		rm -rf "${emusFolder}/citra.tar.gz"
		chmod +x "${emusFolder}/citra-qt.AppImage"
	else
		return 1
	fi
}

# ApplyInitialSettings
Citra_init () {
	setMSG "Initializing ${Citra_emuName} settings."
	# shellcheck disable=2154
	configEmuAI "${Citra_emuName}" "citra-emu"  "${HOME}/.config/citra-emu" "${emudeckBackend}/configs/citra-emu" "true"
	Citra_setEmulationFolder
	Citra_setupStorage
	Citra_setupSaves
	Citra_addSteamInputProfile
	Citra_flushEmulatorLauncher
	Citra_flushSymlinks
	Citra_setupTextures
}

# Update
Citra_update () {
	setMSG "Updating ${Citra_emuName} settings."
	configEmuAI "${Citra_emuName}" "citra-emu" "${HOME}/.config/citra-emu" "${emudeckBackend}/configs/citra-emu"
	Citra_setupStorage
	Citra_setEmulationFolder
	Citra_setupSaves
	Citra_addSteamInputProfile
	Citra_flushEmulatorLauncher
	Citra_flushSymlinks
	Citra_setupTextures
}

# Setup Storage
Citra_setupStorage () {
	# shellcheck disable=2154
	mkdir -p "${storagePath}/citra/"

	# SDMC and NAND
	if [ ! -d "${storagePath}/citra/sdmc" ] && { [ -d "${HOME}/.var/app/org.citra_emu.citra" ] || [ -d "${HOME}/.local/share/citra-emu" ]; }; then
		echo "Citra SDMC does not exist in storage path"

		echo -e ""
		setMSG "Moving Citra SDMC to the Emulation/storage folder"
		echo -e ""

		mkdir -p "${storagePath}/citra"

		# shellcheck disable=2154
		if [ -d "${savesPath}/citra/sdmc" ]; then
			mv -f "${savesPath}/citra/sdmc" "${storagePath}/citra/"

		elif [ -d "${HOME}/.var/app/org.citra_emu.citra/data/citra-emu/sdmc" ]; then
			rsync -av "${HOME}/.var/app/org.citra_emu.citra/data/citra-emu/sdmc" "${storagePath}/citra/" && rm -rf "${HOME}/.var/app/org.citra_emu.citra/data/citra-emu/sdmc"

		elif [ -d "${HOME}/.local/share/citra-emu/sdmc" ]; then
			rsync -av "${HOME}/.local/share/citra-emu/sdmc" "${storagePath}/citra/" && rm -rf "${HOME}/.local/share/citra-emu/sdmc"
		else
			mkdir -p "${storagePath}/citra/sdmc"
		fi
	else
		mkdir -p "${storagePath}/citra/sdmc"
	fi

	if [ ! -d "${storagePath}/citra/nand" ] && { [ -d "${HOME}/.var/app/org.citra_emu.citra" ] || [ -d "${HOME}/.local/share/citra-emu" ]; }; then
		echo "Citra NAND does not exist in storage path"

		echo -e ""
		setMSG "Moving Citra NAND to the Emulation/storage folder"
		echo -e ""

		mkdir -p "${storagePath}/citra"

		if [ -d "${savesPath}/citra/nand" ]; then
			mv -f "${savesPath}/citra/nand" "${storagePath}/citra/"

		elif [ -d "${HOME}/.var/app/org.citra_emu.citra/data/citra-emu/nand" ]; then
			rsync -av "${HOME}/.var/app/org.citra_emu.citra/data/citra-emu/nand" "${storagePath}/citra/" && rm -rf "${HOME}/.var/app/org.citra_emu.citra/data/citra-emu/nand"

		elif [ -d "${HOME}/.local/share/citra-emu/nand" ]; then
			rsync -av "${HOME}/.local/share/citra-emu/nand" "${storagePath}/citra/" && rm -rf "${HOME}/.local/share/citra-emu/nand"
		else
			mkdir -p "${storagePath}/citra/nand"
		fi
	else
		mkdir -p "${storagePath}/citra/nand"
	fi

	# Cheats and Texture Packs
	# Cheats
	mkdir -p "${HOME}/.local/share/citra-emu/cheats"
	linkToStorageFolder citra cheats "${HOME}/.local/share/citra-emu/cheats"
	# Texture Pack
	mkdir -p "${HOME}/.local/share/citra-emu/load/textures"
	linkToStorageFolder citra textures "${HOME}/.local/share/citra-emu/load/textures"
}

# ConfigurePaths
Citra_setEmulationFolder () {
	setMSG "Setting ${Citra_emuName} Emulation Folder"

	mkdir -p "${Citra_configPath}"
	gameDirOpt='Paths\\gamedirs\\3\\path='
	# shellcheck disable=2154
	newGameDirOpt='Paths\\gamedirs\\3\\path='"${romsPath}/n3ds"
	sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "${Citra_configFile}"

	nandDirOpt='nand_directory='
	newnandDirOpt='nand_directory='"${storagePath}/citra/nand/"
	sed -i "/${nandDirOpt}/c\\${newnandDirOpt}" "${Citra_configFile}"

	sdmcDirOpt='sdmc_directory='
	newsdmcDirOpt='sdmc_directory='"${storagePath}/citra/sdmc/"
	sed -i "/${sdmcDirOpt}/c\\${newsdmcDirOpt}" "${Citra_configFile}"

	mkdir -p "${storagePath}/citra/screenshots/"
	screenshotsDirOpt='Paths\\screenshotPath='
	newscreenshotDirOpt='Paths\\screenshotPath='"${storagePath}/citra/screenshots/"
	sed -i "/${screenshotsDirOpt}/c\\${newscreenshotDirOpt}" "${Citra_configFile}"

	# True/False configs
	sed -i 's/nand_directory\\default=true/nand_directory\\default=false/' "${Citra_configFile}"
	sed -i 's/sdmc_directory\\default=true/sdmc_directory\\default=false/' "${Citra_configFile}"
	sed -i 's/use_custom_storage=false/use_custom_storage=true/' "${Citra_configFile}"
	sed -i 's/use_custom_storage\\default=true/use_custom_storage\\default=false/' "${Citra_configFile}"

	# Vulkan Graphics
	sed -E 's/layout_option=[0-9]+/layout_option=5/g' "${Citra_configFile}"
	sed -i 's/layout_option\\default=true/layout_option\\default=false/' "${Citra_configFile}"

	#Setup symlink for AES keys
	# shellcheck disable=2154
	mkdir -p "${biosPath}/citra/"
	mkdir -p "${HOME}/.local/share/citra-emu/sysdata"
	ln -sn "${HOME}/.local/share/citra-emu/sysdata" "${biosPath}/citra/keys"
}



# SetupSaves
Citra_setupSaves () {
	mkdir -p "${HOME}/.local/share/citra-emu/states"
	linkToSaveFolder citra saves "${storagePath}/citra/sdmc"
	linkToSaveFolder citra states "${HOME}/.local/share/citra-emu/states"
}

# Set up textures
Citra_setupTextures () {
	mkdir -p "${HOME}/.local/share/citra-emu/load/textures"
	linkToTexturesFolder citra textures "${HOME}/.local/share/citra-emu/load/textures"
}

# WipeSettings
Citra_wipe () {
	setMSG "Wiping ${Citra_emuName} config directory. (factory reset)"
	rm -rf "${HOME}/.config/citra-emu"
}


# Uninstall
Citra_uninstall () {
	setMSG "Uninstalling ${Citra_emuName}."
	uninstallEmuAI "${Citra_emuName}" "citra-qt" "" "emulator"
}

# setABXYstyle
Citra_setABXYstyle () {
	sed -i '/button_a/s/button:1/button:0/' "${Citra_configFile}"
	sed -i '/button_b/s/button:0/button:1/' "${Citra_configFile}"
	sed -i '/button_x/s/button:3/button:2/' "${Citra_configFile}"
	sed -i '/button_y/s/button:2/button:3/' "${Citra_configFile}"

}

# setBAYXstyle
Citra_setBAYXstyle () {
	sed -i '/button_a/s/button:0/button:1/' "${Citra_configFile}"
	sed -i '/button_b/s/button:1/button:0/' "${Citra_configFile}"
	sed -i '/button_x/s/button:2/button:3/' "${Citra_configFile}"
	sed -i '/button_y/s/button:3/button:2/' "${Citra_configFile}"
}

# finalExec - Extra stuff
Citra_finalize () {
	echo "NYI"
}

# IsInstalled
Citra_IsInstalled () {
	if [ -e "${Citra_emuPath}" ]; then
		echo "true"
	else
		echo "false"
	fi
}

# resetConfig
Citra_resetConfig () {
	Citra_init &>/dev/null && echo "true" || echo "false"
}

# Add Steam Input Profile
Citra_addSteamInputProfile () {
	addSteamInputCustomIcons
	setMSG "Adding ${Citra_emuName} Steam Input Profile."
	#rsync -r "$emudeckBackend/configs/steam-input/citra_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
	rsync -r --exclude='*/' "${emudeckBackend}/configs/steam-input/" "${HOME}/.steam/steam/controller_base/templates/"
}

# setResolution
Citra_setResolution () {
	# shellcheck disable=2154
	case "${citraResolution}" in
		"720P") multiplier=3;;
		"1080P") multiplier=5;;
		"1440P") multiplier=6;;
		"4K") multiplier=9;;
		*) echo "Error"; return 1;;
	esac

	setConfig "resolution_factor" $multiplier "${Citra_configFile}"
}

# flushEmulatorLauncher
Citra_flushEmulatorLauncher () {
	flushEmulatorLaunchers "citra"
}

# flushSymlinks
Citra_flushSymlinks () {
	if [ -d "${HOME}/.local/share/Steam" ]; then
		STEAMPATH="${HOME}/.local/share/Steam"
	elif [ -d "${HOME}/.steam/steam" ]; then
		STEAMPATH="${HOME}/.steam/steam"
	else
		echo "Steam install not found"
	fi

	# shellcheck disable=2154
	if [ ! -f "${emudeckFolder}/.citralegacysymlinks" ] && [ -f "${emudeckFolder}/.citrasymlinks" ]; then

	mkdir -p "${romsPath}/n3ds"
	# Temporary deletion to check if there are any additional contents in the n3ds folder.
	rm -rf "${romsPath}/n3ds/media" &> /dev/null
	rm -rf "${romsPath}/n3ds/metadata.txt" &> /dev/null
	rm -rf "${romsPath}/n3ds/systeminfo.txt" &> /dev/null

	# The Pegasus install was accidentally overwriting the pre-existing n3ds symlink.
	# This checks if the n3ds folder is empty (post-removing the contents above) and if the original 3ds folder is still a folder and not a symlink (for those who have already migrated).
	# If all of this is true, the n3ds folder is deleted and the old symlink is temporarily recreated to proceed with the migration.
	if [[ ! "$( ls -A "${romsPath}/n3ds")" ]] && [ -d "${romsPath}/3ds" ] && [ ! -L "${romsPath}/3ds" ]; then
		rm -rf "${romsPath}/n3ds"
		ln -sfn "${romsPath}/3ds" "${romsPath}/n3ds"
			# Temporarily restores old directory structure.
	fi

	if [[ -L "${romsPath}/n3ds" && ! $(readlink -f "${romsPath}/n3ds") =~ ^"${romsPath}" ]] || [[ -L "${romsPath}/3ds" && ! $(readlink -f "${romsPath}/3ds") =~ ^"${romsPath}" ]]; then
		echo "User has symlinks that don't match expected paths located under ${romsPath}. Aborting symlink update."
	else
		if [[ ! -e "${romsPath}/3ds" && ! -e "${romsPath}/n3ds" ]]; then
			mkdir -p "${romsPath}/n3ds"
			ln -sfn "${romsPath}/n3ds" "${romsPath}/3ds"
		elif [[ -d "${romsPath}/3ds" && -L "${romsPath}/n3ds" ]]; then
			echo "Converting n3ds symlink to a regular directory..."
			unlink "${romsPath}/n3ds"
			mv "${romsPath}/3ds" "${romsPath}/n3ds"
			ln -sfn "${romsPath}/n3ds" "${romsPath}/3ds"
			echo "3ds symlink updated to point to n3ds"
		elif [[ -d "${romsPath}/3ds" && ! -e "${romsPath}/n3ds" ]]; then
			echo "Creating n3ds directory and updating 3ds symlink..."
			mv "${romsPath}/3ds" "${romsPath}/n3ds"
			ln -sfn "${romsPath}/n3ds" "${romsPath}/3ds"
			echo "3ds symlink updated to point to n3ds"
		elif [[ -d "${romsPath}/n3ds" && ! -e "${romsPath}/3ds" ]]; then
			echo "3ds symlink not found, creating..."
			ln -sfn "${romsPath}/n3ds" "${romsPath}/3ds"
			echo "3ds symlink created"
		fi
	fi

	rsync -avh "${emudeckBackend}/roms/n3ds/." "${romsPath}/n3ds/." --ignore-existing

	if [ -d "${toolsPath}/downloaded_media/n3ds" ] && [ ! -d "${romsPath}/n3ds/media" ]; then
		ln -s "${toolsPath}/downloaded_media/n3ds" "${romsPath}/n3ds/media"
	fi

	find "${STEAMPATH}/userdata" -name "shortcuts.vdf" -exec sed -i "s|${romsPath}/3ds|${romsPath}/n3ds|g" {} +
	touch "${emudeckFolder}/.citralegacysymlinks"
	echo "Citra symlink cleanup completed."

	else
		echo "Citra symlinks already cleaned."
	fi

	if [ ! -f "${emudeckFolder}/.citrasymlinks" ]; then
		mkdir -p "${romsPath}/n3ds"
		# Temporary deletion to check if there are any additional contents in the n3ds folder.
		{
			rm -rf "${romsPath}/n3ds/media"
			rm -rf "${romsPath}/n3ds/metadata.txt"
			rm -rf "${romsPath}/n3ds/systeminfo.txt"
		} &> /dev/null

		# The Pegasus install was accidentally overwriting the pre-existing n3ds symlink.
		# This checks if the n3ds folder is empty (post-removing the contents above) and if the original 3ds folder is still a folder and not a symlink (for those who have already migrated).
		# If all of this is true, the n3ds folder is deleted and the old symlink is temporarily recreated to proceed with the migration.
		if [[ ! "$( ls -A "${romsPath}/n3ds")" ]] && [ -d "${romsPath}/3ds" ] && [ ! -L "${romsPath}/3ds" ]; then
			rm -rf "${romsPath}/n3ds"
			ln -sfn "${romsPath}/3ds" "${romsPath}/n3ds"
			  # Temporarily restores old directory structure.
		fi

		if [[ -L "${romsPath}/n3ds" && ! $(readlink -f "${romsPath}/n3ds") =~ ^"${romsPath}" ]] || [[ -L "${romsPath}/3ds" && ! $(readlink -f "${romsPath}/3ds") =~ ^"${romsPath}" ]]; then
			echo "User has symlinks that don't match expected paths located under ${romsPath}. Aborting symlink update."
		else
			if [[ ! -e "${romsPath}/3ds" && ! -e "${romsPath}/n3ds" ]]; then
				mkdir -p "${romsPath}/n3ds"
				ln -sfn "${romsPath}/n3ds" "${romsPath}/3ds"
			elif [[ -d "${romsPath}/3ds" && -L "${romsPath}/n3ds" ]]; then
				echo "Converting n3ds symlink to a regular directory..."
				unlink "${romsPath}/n3ds"
				mv "${romsPath}/3ds" "${romsPath}/n3ds"
				ln -sfn "${romsPath}/n3ds" "${romsPath}/3ds"
				echo "3ds symlink updated to point to n3ds"
			elif [[ -d "${romsPath}/3ds" && ! -e "${romsPath}/n3ds" ]]; then
				echo "Creating n3ds directory and updating 3ds symlink..."
				mv "${romsPath}/3ds" "${romsPath}/n3ds"
				ln -sfn "${romsPath}/n3ds" "${romsPath}/3ds"
				echo "3ds symlink updated to point to n3ds"
			elif [[ -d "${romsPath}/n3ds" && ! -e "${romsPath}/3ds" ]]; then
				echo "3ds symlink not found, creating..."
				ln -sfn "${romsPath}/n3ds" "${romsPath}/3ds"
				echo "3ds symlink created"
			fi
		fi

		rsync -avh "${emudeckBackend}/roms/n3ds/." "${romsPath}/n3ds/." --ignore-existing

		if [ -d "${toolsPath}/downloaded_media/n3ds" ] && [ ! -d "${romsPath}/n3ds/media" ]; then
			ln -s "${toolsPath}/downloaded_media/n3ds" "${romsPath}/n3ds/media"
		fi

		find "${STEAMPATH}/userdata" -name "shortcuts.vdf" -exec sed -i "s|${romsPath}/3ds|${romsPath}/n3ds|g" {} +
		touch "${emudeckFolder}/.citrasymlinks"
		echo "Citra symlink cleanup completed."

	else
		echo "Citra symlinks already cleaned."
	fi
}
