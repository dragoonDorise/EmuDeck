#!/usr/bin/bash

# Parameters
declare -A CemuNative=(
	[emuName]="CemuNative"
	[emuType]="AppImage"
	[emuPath]="${HOME}/Applications/Cemu.AppImage"
	[configDir]="${HOME}/.config/Cemu"
	[configFile]="${HOME}/.config/Cemu/settings.xml"
)

CemuNative_functions () {
	# Cleanup older things
	cleanup () {
		echo "NYI"
	}

	# Finalize
	finalize () {
		cleanup
	}

	# Set ABXY Style
	setABXYstyle () {
		echo "NYI"
	}

	# Migrate
	migrate () {
		echo "NYI"
	}

	# Widescreen ON
	widescreenOn () {
		echo "NYI"
	}

	# Widescreen OFF
	widescreenOff () {
		echo "NYI"
	}

	# Bezels ON
	bezelOn () {
		echo "NYI"
	}
	
	# Bezels OFF
	bezelOff () {
		echo "NYI"
	}

	# Configure Paths
	setEmulationFolder () {
		setMSG "Setting ${CemuNative[emuName]} Emulation Folder"
		if [ -f "${CemuNative[configFile]}" ]; then
			gamePathEntryFound="$( xmlstarlet sel -t -m "//root/content/GamePaths/Entry" -v . -n "${CemuNative[configFile]}" )"

			if [[ ! "${gamePathEntryFound}" == *"${romsPath}/wiiu/roms"* ]]; then
				xmlstarlet ed --inplace  --subnode "content/GamePaths" --type elem -n Entry -v "${romsPath}/wiiu/roms" "${CemuNative[configFile]}"
			fi
		fi
	}

	# Set Saves
	setupSaves () {
		unlink "${savesPath}/Cemu/saves" # Fix for previous bad symlink
		linkToSaveFolder Cemu saves "${romsPath}/wiiu/mlc01/usr/save"
	}

	# Setup Storage
	setupStorage () {
		echo "NYI"
	}

	# Wipe Settings
	wipeSettings () {
		setMSG "Wiping ${CemuNative[emuName]} settings."
		rm -rf "${CemuNative[configDir]}"
	}

	# Uninstall
	uninstall () {
		setMSG "Uninstalling ${CemuNative[emuName]}."
		rm -rf "${CemuNative[emuPath]}"
	}

	# Install
	install () {
		echo "Begin Cemu - Native Install"
		installEmuAI "Cemu" "$( getReleaseURLGH "cemu-project/Cemu" ".AppImage" )" # Cemu.AppImage
	}

	# Apply initial settings
	init () {
		setMSG "Initialising ${CemuNative[emuName]} settings."
		configEmuAI "${CemuNative[emuName]}" "config" "${HOME}/.config/Cemu" "${EMUDECKGIT}/configs/cemu/.config/cemu" "true"
		setEmulationFolder
		setupStorage
		setupSaves
	}

	# Update
	update () {
		setMSG "Updating ${CemuNative[emuName]} settings."
		configEmuAI "${CemuNative[emuName]}" "config" "${HOME}/.config/cemu" "${EMUDECKGIT}/configs/cemu/.config/cemu"
		setEmulationFolder
		setupStorage
		setupSaves
		addSteamInputProfile
	}

	# Is Installed
	isInstalled () {
		if [ -e "${CemuNative[emuPath]}" ]; then
			echo "true"
		else
			echo "false"
		fi
	}

	# Reset Config
	resetConfig () {
		cp "${CemuNative[configFile]}"{,.bak}
		init && echo "true" || echo "false"
	}

	# Add Steam Input Profile
	addSteamInputProfile () {
		setMSG "Adding ${CemuNative[emuName]} Steam Input Profile."
		rsync -r "${EMUDECKGIT}/configs/steam-input/cemu_controller_config.vdf" "${HOME}/.steam/steam/controller_base/templates/"
	}

	"${1}" # Call the above functions
}
