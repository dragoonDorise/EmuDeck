#!/usr/bin/bash

CemuNative_functions () {
	# Parameters
	declare -A CemuNative=(
		[emuName]="CemuNative"
		[emuType]="AppImage"
		[emuPath]="${HOME}/Applications/Cemu.AppImage"
		[configDir]="${HOME}/.config/Cemu"
		[configFile]="${HOME}/.config/Cemu/settings.xml"
	)
	
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
		# linkToSaveFolder Cemu saves "${romsPath}/wiiu/mlc01/usr/save"
		ln -sn "${romsPath}/wiiu/mlc01" "${HOME}/.local/share/Cemu/mlc01" # Symlink from Proton directory until we move it.
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
		configEmuAI "${CemuNative[emuName]}" "config" "${HOME}/.config/Cemu" "${EMUDECKGIT}/configs/Cemu" "true"
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

# Cleanup older things
CemuNative_cleanup () {
	CemuNative_functions "cleanup"
}

# Finalize
CemuNative_finalize () {
	CemuNative_functions "finalize"
}

# Set ABXY Style
CemuNative_setABXYstyle () {
	CemuNative_functions "setABXYstyle"
}

# Migrate
CemuNative_migrate () {
	CemuNative_functions "migrate"
}

# Widescreen ON
CemuNative_widescreenOn () {
	CemuNative_functions "widescreenOn"
}

# Widescreen OFF
CemuNative_widescreenOff () {
	CemuNative_functions "widescreenOff"
}

# Bezels ON
CemuNative_bezelOn () {
	CemuNative_functions "bezelOn"
}

# Bezels OFF
CemuNative_bezelOff () {
	CemuNative_functions "bezelOff"
}

# Configure Paths
CemuNative_setEmulationFolder () {
	CemuNative_functions "setEmulationFolder"
}

# Set Saves
CemuNative_setupSaves () {
	CemuNative_functions "setupSaves"
}

# Setup Storage
CemuNative_setupStorage () {
	CemuNative_functions "setupStorage"
}

# Wipe Settings
CemuNative_wipeSettings () {
	CemuNative_functions "wipeSettings"
}

# Uninstall
CemuNative_uninstall () {
	CemuNative_functions "uninstall"
}

# Install
CemuNative_install () {
	CemuNative_functions "install"
}

# Apply initial settings
CemuNative_init () {
	CemuNative_functions "init"
}

# Update
CemuNative_update () {
	CemuNative_functions "update"
}

# Is Installed
CemuNative_isInstalled () {
	CemuNative_functions "isInstalled"
}

# Reset Config
CemuNative_resetConfig () {
	CemuNative_functions "resetConfig"
}

# Add Steam Input Profile
CemuNative_addSteamInputProfile () {
	CemuNative_functions "addSteamInputProfile"
}
