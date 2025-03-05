#!/bin/bash

# emuDeckRPCS3

# Variables
RPCS3_emuName="RPCS3"
# shellcheck disable=2034,2154
RPCS3_emuType="${emuDeckEmuTypeAppImage}"
# shellcheck disable=2154
RPCS3_emuPath="${emusFolder}/rpcs3.AppImage"
RPCS3_emuPathFlatpak="net.rpcs3.RPCS3"
RPCS3_VFSConf="${HOME}/.config/rpcs3/vfs.yml"
# shellcheck disable=2154
RPCS3_migrationFlag="${emudeckFolder}/.${RPCS3_emuName}MigrationCompleted"
RPCS3_configFile="${HOME}/.config/rpcs3/config.yml"s
# RPCS3 Update API
RPCS3_download_link=""
RPCS3_download_link_checksum=""

# Languages
declare -A RPCS3_languages=(
	["ja"]=""
	["en"]="English (US)"
	["fr"]="French"
	["de"]="German"
	["it"]="Italian"
	["es"]="Spanish"
	["ko"]="Korean"
	["nl"]="Dutch"
	["pt"]="Portiguese (Portugal)"
	["ru"]="Russian"
)

# cleanupOlderThings
RPCS3_cleanup () {
	echo "NYI"
}

# ApiGetUpdateInfo
# shellcheck disable=2120
RPCS3_ApiGetUpdateInfo () {
	RPCS3_download_link=""
	RPCS3_download_link_checksum=""

	local apiUrl="https://update.rpcs3.net/"
	local localFile="${RPCS3_emuPath}"
	# shellcheck disable=2034
	local currentVersion="${1}"
	local apiVersion="v3"
	local osType="linux"
	local osArch="x64"
	# shellcheck disable=2155
	local osVersion=$( grep "VERSION_ID" /etc/os-release | cut -d'=' -f2 | tr -d '"' )
	local should_return_update=0

	echo "Checking for RPCS3 updates..."

	# shellcheck disable=2155
	local response=$(
		curl -s -G "${apiUrl}" \
		--data-urlencode "api=${apiVersion}" \
		--data-urlencode "os_type=${osType}" \
		--data-urlencode "os_arch=${osArch}" \
		--data-urlencode "os_version=${osVersion}"
	)

	# shellcheck disable=2155
	local return_code=$( echo "$response" | jq '.return_code' )

	if [ "${return_code}" -eq 1 ]; then
		echo "Newer RPCS3 build found!"
	elif [ "${return_code}" -eq 0 ]; then
		echo "Latest RPCS3 build found!" # when not using the $currentVersion (NYI), the API returns 0
	elif [ "${return_code}" -eq -3 ]; then
		echo "Illegal search"
		return 1
	elif [ "${return_code}" -eq -2 ]; then
		echo "Maintenance mode"
		return 1
	elif [ "${return_code}" -eq -1 ]; then
		echo "Current build is not a master build."
		return 1
	else
		echo "Failed to check for updates. Return Code: ${return_code}"
		return 1
	fi

	#local latest_build=$(echo "$response" | jq -r '.latest_build')
	#echo "Latest Build: $latest_build"

	# shellcheck disable=2155
	local download_link=$( echo "$response" | jq -r '.latest_build.linux.download' )
	# shellcheck disable=2155
	local remote_checksum=$( echo "$response" | jq -r '.latest_build.linux.checksum' | tr '[:upper:]' '[:lower:]' )

	# Check if the local file exists
	if [ "${return_code}" -eq 0 ]; then
		if [ -f "${localFile}" ]; then
		# shellcheck disable=2155
			local local_checksum=$( calculate_checksum_sha256 "${localFile}" | tr '[:upper:]' '[:lower:]' )

			echo "Local Checksum: ${local_checksum}"
			echo "Remote Checksum: ${remote_checksum}"

			if [ "${local_checksum}" != "${remote_checksum}" ]; then
				echo "Checksums differ, returning download link and checksum."
				should_return_update=1
			else
				echo "Checksums match, no need to update."
				return 2
			fi
		else
			echo "Local file not found, returning download link and checksum."
			should_return_update=1
		fi
	else
		should_return_update=1
	fi

	if [ "${should_return_update}" -eq 1 ]; then
		echo "Download Link: ${download_link}"
		echo "Checksum: ${remote_checksum}"
		RPCS3_download_link="${download_link}"
		RPCS3_download_link_checksum="${remote_checksum}"
		return 0
	fi

	return 1
}

# Install
RPCS3_install () {
	setMSG "Installing RPCS3"

	# Migrates configurations to RPCS3 AppImage
	RPCS3_migrate

	# Install RPCS3
	local showProgress="${1}"

	RPCS3_ApiGetUpdateInfo
	apiGetUpdateInfoResult=$?

	if [ "${apiGetUpdateInfoResult}" -eq 0 ] || [ "${apiGetUpdateInfoResult}" -eq 2 ]; then
		#if installEmuAI "${RPCS3_emuName}" "" "$(getLatestReleaseURLGH "RPCS3/rpcs3-binaries-linux" ".AppImage")" "rpcs3" "" "emulator" "${showProgress}"; then #
		if installEmuAI "${RPCS3_emuName}" "" "${RPCS3_download_link}" "rpcs3" "" "emulator" "${showProgress}" "" "" "${RPCS3_download_link_checksum}"; then #
			#echo "RPCS3 installed or updated successfully."
			:
		else
			#echo "RPCS3 installation or update failed."
			return 1
		fi
	else
		#echo "RPCS3 is already up to date or failed to retrieve update information."
		return 1
	fi

	# Preserve flatpak permissions for old RPCS3 Install
	flatpak override net.rpcs3.RPCS3 --filesystem=host --user
}

# ApplyInitialSettings
RPCS3_init () {
	RPCS3_migrate
	# shellcheck disable=2154
	configEmuAI "${RPCS3_emuName}" "config" "${HOME}/.config/rpcs3" "${emudeckBackend}/configs/rpcs3" "true"
	RPCS3_setupStorage
	RPCS3_setEmulationFolder
	RPCS3_setupSaves
	#SRM_createParsers
	RPCS3_flushEmulatorLauncher
	RPCS3_setLanguage
}

# setLanguage
RPCS3_setLanguage () {
	setMSG "Setting RPCS3 Language"
	# shellcheck disable=2155
	local language=$( locale | grep LANG | cut -d= -f2 | cut -d_ -f1 )
	local languageOpt="  Language"
	if [ ${RPCS3_languages[$language]+_} ]; then
		newLanguageOpt="${RPCS3_languages[$language]}"
		iniFieldUpdate "${RPCS3_configFile}" "" "${languageOpt}" "${newLanguageOpt}" ": "
	fi
}

# update
RPCS3_update () {
	RPCS3_migrate
	configEmuAI "${RPCS3_emuName}" "config" "${HOME}/.config/rpcs3" "${emudeckBackend}/configs/rpcs3"
	RPCS3_setupStorage
	RPCS3_setEmulationFolder
	RPCS3_setupSaves
	RPCS3_addESConfig
	RPCS3_flushEmulatorLauncher
}

# ConfigurePaths
RPCS3_setEmulationFolder () {
	# shellcheck disable=2154
	iniFieldUpdate "$RPCS3_VFSConf" "" "/dev_hdd0/" "${storagePath}/rpcs3/dev_hdd0/" ": "
	# shellcheck disable=2154
	iniFieldUpdate "$RPCS3_VFSConf" "" "/games/" "${romsPath}/ps3/" ": "
}

# SetupSaves
RPCS3_setupSaves () {
	linkToSaveFolder rpcs3 saves "${storagePath}/rpcs3/dev_hdd0/home/00000001/savedata"
	linkToSaveFolder rpcs3 trophy "${storagePath}/rpcs3/dev_hdd0/home/00000001/trophy"
}

# SetupStorage
RPCS3_setupStorage () {
	mkdir -p "${storagePath}/rpcs3/"

	if [ ! -d "${storagePath}"/rpcs3/dev_hdd0 ] && { [ -d "${HOME}/.var/app/net.rpcs3.RPCS3/config/rpcs3/" ] || [ -d "${HOME}/.config/rpcs3/" ]; }; then
		echo "RPCS3 HDD does not exist in storage path"

		echo -e ""
		setMSG "Moving RPCS3 HDD to the Emulation/storage folder"
		echo -e ""

		mkdir -p "${storagePath}/rpcs3"

		# shellcheck disable=2154
		if [ -d "${savesPath}/rpcs3/dev_hdd0" ]; then
			mv -f "${savesPath}"/rpcs3/dev_hdd0 "${storagePath}"/rpcs3/

		elif [ -d "${HOME}/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0" ]; then
			rsync -av "${HOME}/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0" "${storagePath}"/rpcs3/ && rm -rf "${HOME}/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0"

		elif [ -d "${HOME}/.config/rpcs3/dev_hdd0" ]; then
			rsync -av "${HOME}/.config/rpcs3/dev_hdd0" "${storagePath}"/rpcs3/ && rm -rf "${HOME}/.config/rpcs3/dev_hdd0"
		fi
	fi
}

# WipeSettings
RPCS3_wipe () {
	setMSG "Wiping ${RPCS3_emuName} settings."
	rm -rf "${HOME}/.config/rpcs3"
	rm -rf "${HOME}/.cache/rpcs3"
}

# Uninstall
RPCS3_uninstall () {
	setMSG "Uninstalling ${RPCS3_emuName}."
	uninstallEmuAI "${RPCS3_emuName}" "rpcs3" "" "emulator"
	#RPCS3_wipe
}

# setABXYstyle
RPCS3_setABXYstyle () {
	 echo "NYI"
}

# Migrate
RPCS3_migrate () {
	echo "Begin RPCS3 Migration"

	# Migration
	if [ "$( RPCS3_IsMigrated )" != "true" ]; then
		#RPCS3 flatpak to appimage
		#From -- > to
		migrationTable=()
		migrationTable+=( "${HOME}/.var/app/net.rpcs3.RPCS3/config/rpcs3" "${HOME}/.config/rpcs3" )

		# shellcheck disable=2128 # Is only taking the first item in the array intentional?
		migrateAndLinkConfig "${RPCS3_emuName}" "${migrationTable}"
	fi

	echo "true"
}

# WideScreenOn
RPCS3_wideScreenOn () {
	echo "NYI"
}

# WideScreenOff
RPCS3_wideScreenOff () {
	echo "NYI"
}

# BezelOn
RPCS3_bezelOn () {
	echo "NYI"
}

# BezelOff
RPCS3_bezelOff () {
	echo "NYI"
}

# finalExec - Extra stuff
RPCS3_finalize () {
	echo "NYI"
}

# IsInstalled
RPCS3_IsInstalled () {
	local emuType=$1 # if empty we assume the caller doesn't care what type is installed, so we can check both
	# if flatpak type or no type is requested and we haven't yet migrated, check flatpak installation status
	# shellcheck disable=2154
	if { [ "${emuType}" == "${emuDeckEmuTypeFlatpak}" ] || [ -z "${emuType}" ]; } && [ "$(RPCS3_IsMigrated)" != "true" ] && [ "$( isFpInstalled "${RPCS3_emuPathFlatpak}" )" == "true" ]; then
		echo "true"
	# we can stop here if flatpak type was requested - we already migrated and no longer want to care about flatpak and launcher / desktop shortcut updates
	elif [ "${emuType}" == "${emuDeckEmuTypeFlatpak}" ]; then
		echo "false"
	# appimage check
	elif [ -e "${RPCS3_emuPath}" ]; then
		echo "true"
	else
		echo "false"
	fi
}

# IsMigrated
RPCS3_IsMigrated () {
	if [ -f "${RPCS3_migrationFlag}" ]; then
		echo "true"
	else
		echo "false"
	fi
}

# resetConfig
RPCS3_resetConfig () {
	RPCS3_init &>/dev/null && echo "true" || echo "false"
}

# setResolution
RPCS3_setResolution () {
	# shellcheck disable=2154
	case "${rpcs3Resolution}" in
		"720P") res=100;;
		"1080P") res=150;;
		"1440P") res=200;;
		"4K") res=300;;
		*) echo "Error"; return 1;;
	esac

	RetroArch_setConfigOverride "Resolution Scale:" "${res}" "${RPCS3_configFile}"

	sed -i "s|Resolution Scale:=|Resolution Scale:|g" "${RPCS3_configFile}"
}

# flushEmulatorLauncher
RPCS3_flushEmulatorLauncher () {
	flushEmulatorLaunchers "rpcs3.sh"
}
