#!/usr/bin/bash

CemuNative_functions () {
	local function="$1"
	local showProgress="$2"

	# Parameters
	declare -A CemuNative=(
		[emuName]="CemuNative"
		[emuType]="AppImage"
		[emuPath]="${HOME}/Applications/CemuNative.AppImage"
		[configDir]="${HOME}/.config/Cemu"
		[configFile]="${HOME}/.config/Cemu/settings.xml"
		[shareDir]="${HOME}/.local/share/Cemu"
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
		echo "Begin Cemu migration"
		migrationFlag="${HOME}/.config/EmuDeck/.${CemuNative[emuName]}MigrationCompleted"
		if [ ! -f "${migrationFlag}" ]; then
			# Check for Windows version mlc01
			if [ -d "${romsPath}/wiiu/mlc01" ]; then
				# Make sure we don't overwrite anything
				if [ -d "${storagePath}/cemu/mlc01" ]; then
					mv -f "${storagePath}/cemu/mlc01"{,.bak}
				fi
				# Move mlc01 to storage
				mv -f "${romsPath}/wiiu/mlc01" "${storagePath}/cemu/mlc01"
			fi
			# Check for Windows version graphicPacks
			if [ -d "${romsPath}/wiiu/graphicPacks" ]; then
				# Make sure we don't overwrite existing graphicPacks
				if [ -d "${storagePath}/cemu/graphicPacks" ]; then
					mv -f "${storagePath}/cemu/graphicPacks"{,.bak}
				fi
				# Move graphicPacks to storage
				mv -f "${romsPath}/wiiu/graphicPacks" "${storagePath}/cemu/graphicPacks"
			fi
			# Move Windows version keys.txt
			if [ -f "${romsPath}/wiiu/keys.txt" ]; then
				# Make sure we don't overwrite anything
				if [ -f "${CemuNative[configDir]}/keys.txt" ]; then
					mv -f "${CemuNative[configDir]}/keys.txt"{,.bak}
				fi
				mv -f "${romsPath}/wiiu/keys.txt" "${CemuNative[configDir]}/keys.txt"
			fi
			# Move Windows version wiiu_commonkey
			if [ -f "${romsPath}/wiiu/wiiu_commonkey" ]; then
				# Make sure we don't overwrite anything
				if [ -f "${CemuNative[configDir]}/wiiu_commonkey" ]; then
					mv -f "${CemuNative[configDir]}/wiiu_commonkey"{,.bak}
				fi
				mv -f "${romsPath}/wiiu/wiiu_commonkey" "${CemuNative[configDir]}/wiiu_commonkey"
			fi
			# Move Windows version gameProfiles
			if [ -d "${romsPath}/wiiu/gameProfiles" ]; then
				# Make sure we don't overwrite anything
				if [ -d "${CemuNative[configDir]}/gameProfiles" ]; then
					mv -f "${CemuNative[configDir]}/gameProfiles"{,.bak}
				fi
				mv -f "${romsPath}/wiiu/gameProfiles" "${CemuNative[configDir]}/gameProfiles"
			fi
			# Remove Windows version crashdump directory
			if [ -d "${romsPath}/wiiu/crashdump" ]; then
				rm -rf "${romsPath}/wiiu/crashdump"
			fi
			# Remove Windows version controllerProfiles directory
			if [ -d "${romsPath}/wiiu/controllerProfiles" ]; then
				rm -rf "${romsPath}/wiiu/controllerProfiles"
			fi
			# Remove Windows version shaderCache directory
			if [ -d "${romsPath}/wiiu/shaderCache" ]; then
				rm -rf "${romsPath}/wiiu/shaderCache"
			fi
			# Remove Windows version resources directory
			if [ -d "${romsPath}/wiiu/resources" ]; then
				rm -rf "${romsPath}/wiiu/resources"
			fi
			# Remove Windows version memorySearcher directory
			if [ -d "${romsPath}/wiiu/memorySearcher" ]; then
				rm -rf "${romsPath}/wiiu/memorySearcher"
			fi
			# Remove Windows version title list cache
			if [ -f "${romsPath}/wiiu/title_list_cache.xml" ]; then
				rm -rf "${romsPath}/wiiu/title_list_cache.xml"
			fi
			# Remove Windows executable
			if [ -f "${romsPath}/wiiu/Cemu.exe" ]; then
				rm -rf "${romsPath}/wiiu/Cemu.exe"
			fi
			# Remove Windows version settings.xml
			if [ -f "${romsPath}/wiiu/settings.xml" ]; then
				rm -rf "${romsPath}/wiiu/settings.xml"
			fi
			# Remove Windows version log.txt
			if [ -f "${romsPath}/wiiu/log.txt" ]; then
				rm -rf "${romsPath}/wiiu/log.txt"
			fi
			# Move ROMs out of the roms subdirectory
			if [ -d "${romsPath}/wiiu/roms" ]; then
				mv -f "${romsPath}/wiiu/roms/"* "${romsPath}/wiiu/"
				rmdir "${romsPath}/wiiu/roms" # Make sure this only gets removed if empty
			fi
			# Create the migration flag file
			touch "${HOME}/.config/EmuDeck/.${CemuNative[emuName]}MigrationCompleted"
		fi
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

			#gamepath
			gamePathEntryFound="$( xmlstarlet sel -t -m "content/GamePaths/Entry" -v . -n "${CemuNative[configFile]}" )"

			if [[ ! "${gamePathEntryFound}" == *"${romsPath}/wiiu/roms"* ]]; then
				xmlstarlet ed --inplace --subnode "content/GamePaths" --type elem -n Entry -v "${romsPath}/wiiu/roms/" "${CemuNative[configFile]}" #while we use both native and proton, i don't want to change the wiiu folder structure.
			fi

			#mlc01 folder
			mlcEntryFound="$( xmlstarlet sel -t -m "content/mlc_path" -v . -n "${CemuNative[configFile]}" )"
			local mlcPath="${romsPath}/wiiu/mlc01"

			if [[ ! "${mlcEntryFound}" == *"${mlcPath}"* ]]; then
				xmlstarlet ed --inplace -u "content/mlc_path" -v "${romsPath}/wiiu/mlc01" "${CemuNative[configFile]}" #while we use both native and proton, i don't want to change the wiiu folder structure.
			fi
		fi
	}

	# Set Saves
	setupSaves () {
		unlink "${savesPath}/Cemu/saves" # Fix for previous bad symlink
		linkToSaveFolder Cemu saves "${romsPath}/wiiu/mlc01/usr/save" #while we use both native and proton, i don't want to change the wiiu folder structure. I'm repeating myself now.
	}

	# Setup Storage
	setupStorage () {
		#install -d "${storagePath}/cemu"
		unlink "${CemuNative[shareDir]}/mlc01"
		unlink "${CemuNative[shareDir]}/graphicPacks"
		ln -sn "${romsPath}/wiiu/mlc01" "${CemuNative[shareDir]}/mlc01"
		ln -sn "${romsPath}/wiiu/graphicPacks" "${CemuNative[shareDir]}/graphicPacks"
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
		local showProgress="$1"
		if installEmuAI "${CemuNative[emuName]}" "$(getReleaseURLGH "cemu-project/Cemu" ".AppImage")" "" "$showProgress"; then # Cemu.AppImage
			:
		else
			return 1
		fi
	}

	# Apply initial settings
	init () {
		setMSG "Initialising ${CemuNative[emuName]} settings."
		configEmuAI "cemu" "config" "${CemuNative[configDir]}" "${EMUDECKGIT}/configs/cemu/config/cemu" "true"
		#configEmuAI "cemu" "data" "${storagePath}/cemu" "${EMUDECKGIT}/configs/cemu/data/cemu" "true" #seems unneeded? maybe?
		setEmulationFolder
		setupStorage
		setupSaves
		addSteamInputProfile
	}

	# Update
	update () {
		setMSG "Updating ${CemuNative[emuName]} settings."
		configEmuAI "cemu" "config" "${CemuNative[configDir]}" "${EMUDECKGIT}/configs/cemu/.config/cemu"
		#configEmuAI "cemu" "data" "${storagePath}/cemu" "${EMUDECKGIT}/configs/cemu/data/cemu" #seems unneeded? maybe?
		#migrate
		setEmulationFolder
		setupStorage
		setupSaves
		addSteamInputProfile
	}

	# Is Installed
	IsInstalled () {
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
		echo "NYI"
		#setMSG "Adding ${CemuNative[emuName]} Steam Input Profile."
		#rsync -r "${EMUDECKGIT}/configs/steam-input/cemu_controller_config.vdf" "${HOME}/.steam/steam/controller_base/templates/"
	}

	$function "$showProgress" # Call the above functions
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
	local showProgress="$1"
	CemuNative_functions "install" "$showProgress"
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
CemuNative_IsInstalled () {
	CemuNative_functions "IsInstalled"
}

# Reset Config
CemuNative_resetConfig () {
	CemuNative_functions "resetConfig"
}

# Add Steam Input Profile
CemuNative_addSteamInputProfile () {
	CemuNative_functions "addSteamInputProfile"
}

CemuNative_setResolution(){
	echo "NYI"
}