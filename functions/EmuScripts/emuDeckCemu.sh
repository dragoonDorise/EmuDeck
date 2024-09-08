#!/bin/bash

Cemu_functions () {
	local function="$1"
	local showProgress="$2"

	# Parameters
	declare -A CemuNative=(
		[emuName]="CemuNative"
		[emuType]="AppImage"
		[emuPath]="${HOME}/Applications/Cemu.AppImage"
		[configDir]="${HOME}/.config/Cemu"
		[configFile]="${HOME}/.config/Cemu/settings.xml"
		[shareDir]="${HOME}/.local/share/Cemu"
		[controllerDir]="${HOME}/.config/Cemu/controllerProfiles"
	)

	declare -A Cemu_languages
	Cemu_languages=(
	["ja"]=0
	["en"]=1
	["fr"]=2
	["de"]=3
	["it"]=4
	["es"]=5
	["zh"]=6
	["ko"]=7
	["nl"]=8
	["pt"]=9
	["ru"]=10
	["tw"]=11)


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
		sed -i '/<mapping>1<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>1<\/button>/<button>0<\/button>/}' "${CemuNative[controllerDir]}/Deck-Gamepad-Gyro.xml"
		sed -i '/<mapping>1<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>1<\/button>/<button>0<\/button>/}' "${CemuNative[controllerDir]}/controller0.xml"
		sed -i '/<mapping>2<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>0<\/button>/<button>1<\/button>/}' "${CemuNative[controllerDir]}/Deck-Gamepad-Gyro.xml"
		sed -i '/<mapping>2<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>0<\/button>/<button>1<\/button>/}' "${CemuNative[controllerDir]}/controller0.xml"
		sed -i '/<mapping>3<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>3<\/button>/<button>2<\/button>/}' "${CemuNative[controllerDir]}/Deck-Gamepad-Gyro.xml"
		sed -i '/<mapping>3<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>3<\/button>/<button>2<\/button>/}' "${CemuNative[controllerDir]}/controller0.xml"
		sed -i '/<mapping>4<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>2<\/button>/<button>3<\/button>/}' "${CemuNative[controllerDir]}/Deck-Gamepad-Gyro.xml"
		sed -i '/<mapping>4<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>2<\/button>/<button>3<\/button>/}' "${CemuNative[controllerDir]}/controller0.xml"


	}

	setBAYXstyle () {
		sed -i '/<mapping>1<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>0<\/button>/<button>1<\/button>/}' "${CemuNative[controllerDir]}/Deck-Gamepad-Gyro.xml"
		sed -i '/<mapping>1<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>0<\/button>/<button>1<\/button>/}' "${CemuNative[controllerDir]}/controller0.xml"
		sed -i '/<mapping>2<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>1<\/button>/<button>0<\/button>/}' "${CemuNative[controllerDir]}/Deck-Gamepad-Gyro.xml"
		sed -i '/<mapping>2<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>1<\/button>/<button>0<\/button>/}' "${CemuNative[controllerDir]}/controller0.xml"
		sed -i '/<mapping>3<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>2<\/button>/<button>3<\/button>/}' "${CemuNative[controllerDir]}/Deck-Gamepad-Gyro.xml"
		sed -i '/<mapping>3<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>2<\/button>/<button>3<\/button>/}' "${CemuNative[controllerDir]}/controller0.xml"
		sed -i '/<mapping>4<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>3<\/button>/<button>2<\/button>/}' "${CemuNative[controllerDir]}/Deck-Gamepad-Gyro.xml"
		sed -i '/<mapping>4<\/mapping>/{:a;N;/<\/button>/!ba;s/<button>3<\/button>/<button>2<\/button>/}' "${CemuNative[controllerDir]}/controller0.xml"
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

	setLanguage(){
		setMSG "Setting ${CemuNative[emuName]} Language"
		local language=$(locale | grep LANG | cut -d= -f2 | cut -d_ -f1)
		if [[ -f "${CemuNative[configFile]}" ]]; then
			if [ ${Cemu_languages[$language]+_} ]; then
				xmlstarlet ed --inplace  --subnode "content" --type elem -n "console_language" -v "${Cemu_languages[$language]}" "${CemuNative[configFile]}"
			fi
		fi
	}

	# Setup Storage
	setupStorage () {

		# These remove the bad symlinks/files created by the lines below.
		if [ -L "${CemuNative[shareDir]}/graphicPacks" ]; then
			rm -rf "${CemuNative[shareDir]}/graphicPacks"
		fi

  		if [ -f "${CemuNative[shareDir]}/graphicPacks" ]; then
			rm -f "${CemuNative[shareDir]}/graphicPacks"
		fi

		if [ -L "${CemuNative[shareDir]}/mlc01/mlc01" ]; then
			rm -rf "${CemuNative[shareDir]}/mlc01/mlc01"
		fi

  		# Commenting out for now. These need more testing.
		#install -d "${storagePath}/cemu"
		#unlink "${CemuNative[shareDir]}/mlc01"
		#unlink "${CemuNative[shareDir]}/graphicPacks"
		#ln -sn "${romsPath}/wiiu/mlc01" "${CemuNative[shareDir]}/mlc01"
		#ln -sn "${romsPath}/wiiu/graphicPacks" "${CemuNative[shareDir]}/graphicPacks"
	}

	# Wipe Settings
	wipeSettings () {
		setMSG "Wiping ${CemuNative[emuName]} settings."
		rm -rf "${CemuNative[configDir]}"
	}

	# Uninstall
	uninstall () {
		setMSG "Uninstalling ${CemuNative[emuName]}."
		uninstallEmuAI "Cemu" "" "" "emulator"
	}

	# Install
	install () {
		echo "Begin Cemu - Native Install"
		local showProgress="$1"
		if installEmuAI "Cemu" "" "$(getReleaseURLGH "cemu-project/Cemu" ".AppImage")" "" "" "emulator" "$showProgress"; then # Cemu.AppImage
			:
		else
			return 1
		fi
	}

	# Apply initial settings
	init () {
		setMSG "Initialising ${CemuNative[emuName]} settings."
		configEmuAI "cemu" "config" "${CemuNative[configDir]}" "${EMUDECKGIT}/configs/cemu/config/cemu" "true"
		cp "$EMUDECKGIT/$SRM_userData_directory/parsers/optional/nintendo_wiiu-cemu-native-rpx.json" "$SRM_userData_configDir/parsers/custom/"
		cp "$EMUDECKGIT/$SRM_userData_directory/parsers/optional/nintendo_wiiu-cemu-native-wud-wux-wua.json" "$SRM_userData_configDir/parsers/custom/"
		#SRM_createParsers
		#configEmuAI "cemu" "data" "${storagePath}/cemu" "${EMUDECKGIT}/configs/cemu/data/cemu" "true" #seems unneeded? maybe?
		setEmulationFolder
		setupStorage
		setupSaves
		addSteamInputProfile
		flushEmulatorLauncher

		if [ -e "$ESDE_toolPath" ]; then
			ESDE_junksettingsFile
			ESDE_addCustomSystemsFile
			CemuProton_addESConfig
			ESDE_setEmulationFolder
		else
			echo "false"
		fi
	}

	# Update
	update () {
		setMSG "Updating ${CemuNative[emuName]} settings."
		configEmuAI "cemu" "config" "${CemuNative[configDir]}" "${EMUDECKGIT}/configs/cemu/.config/cemu"
		cp "$EMUDECKGIT/$SRM_userData_directory/parsers/optional/nintendo_wiiu-cemu-native-rpx.json" "$SRM_userData_configDir/parsers/custom/"
		cp "$EMUDECKGIT/$SRM_userData_directory/parsers/optional/nintendo_wiiu-cemu-native-wud-wux-wua.json" "$SRM_userData_configDir/parsers/custom/"
		SRM_createParsers
		#configEmuAI "cemu" "data" "${storagePath}/cemu" "${EMUDECKGIT}/configs/cemu/data/cemu" #seems unneeded? maybe?
		#migrate
		setEmulationFolder
		setupStorage
		setupSaves
		addSteamInputProfile
		flushEmulatorLauncher
		if [ -e "$ESDE_toolPath" ]; then
			ESDE_junksettingsFile
			ESDE_addCustomSystemsFile
			CemuProton_addESConfig
			ESDE_setEmulationFolder
		else
			echo "ES-DE not found. Skipped adding custom system."
		fi
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
		addSteamInputCustomIcons
		setMSG "Adding ${CemuNative[emuName]} Steam Input Profile."
		#rsync -r "${EMUDECKGIT}/configs/steam-input/cemu_controller_config.vdf" "${HOME}/.steam/steam/controller_base/templates/"
		rsync -r --exclude='*/' "$EMUDECKGIT/configs/steam-input/" "$HOME/.steam/steam/controller_base/templates/"

	}

	flushEmulatorLauncher () {

		flushEmulatorLaunchers "cemu"
	}


	$function "$showProgress" # Call the above functions
}


# Cleanup older things
Cemu_cleanup () {
	Cemu_functions "cleanup"
}

# Finalize
Cemu_finalize () {
	Cemu_functions "finalize"
}

# Set ABXY Style
Cemu_setABXYstyle () {
	Cemu_functions "setABXYstyle"
}

# Migrate
Cemu_migrate () {
	Cemu_functions "migrate"
}

# Widescreen ON
Cemu_widescreenOn () {
	Cemu_functions "widescreenOn"
}

# Widescreen OFF
Cemu_widescreenOff () {
	Cemu_functions "widescreenOff"
}

# Bezels ON
Cemu_bezelOn () {
	Cemu_functions "bezelOn"
}

# Bezels OFF
Cemu_bezelOff () {
	Cemu_functions "bezelOff"
}

# Configure Paths
Cemu_setEmulationFolder () {
	Cemu_functions "setEmulationFolder"
}

# Set Saves
Cemu_setupSaves () {
	Cemu_functions "setupSaves"
}

# Setup Storage
Cemu_setupStorage () {
	Cemu_functions "setupStorage"
}

# Set Languages
Cemu_setLanguage () {
	Cemu_functions "setLanguage"
}

# Wipe Settings
Cemu_wipeSettings () {
	Cemu_functions "wipeSettings"
}

# Uninstall
Cemu_uninstall () {
	Cemu_functions "uninstall"
}

# Install
Cemu_install () {
	local showProgress="$1"
	Cemu_functions "install" "$showProgress"
}

# Apply initial settings
Cemu_init () {
	Cemu_functions "init"
}

# Update
Cemu_update () {
	Cemu_functions "update"
}

# Is Installed
Cemu_IsInstalled () {
	Cemu_functions "IsInstalled"
}

# Reset Config
Cemu_resetConfig () {
	Cemu_functions "resetConfig"
}

# Add Steam Input Profile
Cemu_addSteamInputProfile () {
	Cemu_functions "addSteamInputProfile"
}

Cemu_setResolution(){
	echo "NYI"
}

Cemu_setABXYstyle(){
	Cemu_functions "setABXYstyle"

}

Cemu_setBAYXstyle(){
	Cemu_functions "setBAYXstyle"

}

Cemu_flushEmulatorLauncher(){

	Cemu_functions "flushEmulatorLauncher"

}


