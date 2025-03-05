#!/usr/bin/env bash

# emuDeckCitron

# Variables
Citron_emuName="citron"
# shellcheck disable=2034,2154
Citron_emuType="${emuDeckEmuTypeAppImage}"
# shellcheck disable=2154
Citron_emuPath="${emusFolder}/citron.AppImage"
Citron_configFile="${HOME}/.config/citron/qt-config.ini"

# Languages
# https://github.com/citron-emu/citron/blob/master/src/core/file_sys/control_metadata.cpp#L41-L60
declare -A Citron_languages=(
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
    ["tw"]=11
) # TODO: not all langs but we need to switch to full lang codes to support those

# Regions
# https://github.com/citron-emu/citron/blob/master/src/citron/configuration/configure_system.ui#L272-L309
declare -A Citron_regions=(
    ["ja"]=0 # Japan
    ["en"]=1 # USA
    ["fr"]=2 # Europe
    ["de"]=2 # Europe
    ["it"]=2 # Europe
    ["es"]=2 # Europe
    ["zh"]=4 # China
    ["ko"]=5 # Korea
    ["nl"]=2 # Europe
    ["pt"]=2 # Europe
    ["ru"]=2 # Europe?
    ["tw"]=6 # Taiwan
) # TODO: split lang from region?

# cleanupOlderThings
Citron_cleanup () {
    echo "Begin Citron Cleanup"
    #Fixes repeated Symlink for older installations
}

# Install
Citron_install () {
    setMSG "Begin Citron Install"
    # shellcheck disable=2034
    local showProgress=$1

    # Llamada a la API para obtener la última release
    #   local response=$(curl -s "https://git.citron-emu.org/api/v1/repos/Citron/Citron/releases")
    #
    #   if installEmuBI "$Citron_emuName" "$( echo "$response" | jq -r '.[0].assets[] | select(.name | contains("Linux")) | .browser_download_url ' | head -n 1)" "$Citron_emuName" "tar.gz" "$showProgress"; then
    #     mkdir -p "$emusFolder/citron"
    #     tar -xvf "$emusFolder/$Citron_emuName.tar.gz" --strip-components=1 -C "$emusFolder/citron" && rm -rf "$HOME/Applications/$Citron_emuName.tar.gz"
    #     chmod +x "$emusFolder/citron/citron"
    #   else
    #     return 1
    #   fi

    #     local success="false"
    #     if installEmuAI "$Citron_emuName" "$(getReleaseURLGH "citron-appimage/citron-appimage" "AppImage")" "" "$showProgress" "" ""; then
    #         success="true"
    #     fi
    #
    #     if [ "$success" != "true" ]; then
    #         return 1
    #     fi

}

# ApplyInitialSettings
Citron_init () {
    echo "Begin Citron Init"

    # shellcheck disable=2154
	cp "${emudeckBackend}/tools/launchers/citron.sh" "${toolsPath}/launchers/citron.sh"
	chmod +x "${toolsPath}/launchers/citron.sh"
    mkdir -p "${HOME}/.config/citron"
    mkdir -p "${HOME}/.local/share/citron"
	rsync -avhp "${emudeckBackend}/configs/citron/config/." "${HOME}/.config/citron"
	rsync -avhp "${emudeckBackend}/configs/citron/data/." "${HOME}/.local/share/citron"

    configEmuAI "${Citron_emuName}" "config" "${HOME}/.config/citron" "${emudeckBackend}/configs/citron/config" "true"
    configEmuAI "${Citron_emuName}" "data" "${HOME}/.local/share/citron" "${emudeckBackend}/configs/citron/data" "true"

    Citron_setEmulationFolder
    Citron_setupStorage
    Citron_setupSaves
    Citron_finalize
    Citron_addParser
    Citron_flushEmulatorLauncher
  	createDesktopShortcut   "${HOME}/.local/share/applications/citron.desktop" \
							"Citron (AppImage)" \
							"${toolsPath}/launchers/citron.sh"  \
							"False"
    # shellcheck disable=2154
	if [ -e "${ESDE_toolPath}" ] || [ -f "${toolsPath}/${ESDE_downloadedToolName}" ] || [ -f "${toolsPath}/${ESDE_oldtoolName}.AppImage" ]; then
		Citron_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi

    #Citron_setLanguage
}

# Update
Citron_update () {
    echo "Begin Citron update"
    Citron_init
}

# ConfigurePaths
Citron_setEmulationFolder () {
    echo "Begin Citron Path Config"

    screenshotDirOpt='Screenshots\\screenshot_path='
    gameDirOpt='Paths\\gamedirs\\4\\path='
    dumpDirOpt='dump_directory='
    loadDir='load_directory='
    nandDirOpt='nand_directory='
    sdmcDirOpt='sdmc_directory='
    tasDirOpt='tas_directory='
    # shellcheck disable=2154
    newScreenshotDirOpt='Screenshots\\screenshot_path='"${storagePath}/citron/screenshots"
    # shellcheck disable=2154
    newGameDirOpt='Paths\\gamedirs\\4\\path='"${romsPath}/switch"
    newDumpDirOpt='dump_directory='"${storagePath}/citron/dump"
    newLoadDir='load_directory='"${storagePath}/citron/load"
    newNandDirOpt='nand_directory='"${storagePath}/citron/nand"
    newSdmcDirOpt='sdmc_directory='"${storagePath}/citron/sdmc"
    newTasDirOpt='tas_directory='"${storagePath}/citron/tas"

    sed -i "/${screenshotDirOpt}/c\\${newScreenshotDirOpt}" "${Citron_configFile}"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "${Citron_configFile}"
    sed -i "/${dumpDirOpt}/c\\${newDumpDirOpt}" "${Citron_configFile}"
    sed -i "/${loadDir}/c\\${newLoadDir}" "${Citron_configFile}"
    sed -i "/${nandDirOpt}/c\\${newNandDirOpt}" "${Citron_configFile}"
    sed -i "/${sdmcDirOpt}/c\\${newSdmcDirOpt}" "${Citron_configFile}"
    sed -i "/${tasDirOpt}/c\\${newTasDirOpt}" "${Citron_configFile}"

    # Setup Bios symlinks
    # shellcheck disable=2154
    unlink "${biosPath}/citron/keys" 2>/dev/null
    unlink "${biosPath}/citron/firmware" 2>/dev/null

    mkdir -p "${HOME}/.local/share/citron/keys/"
    mkdir -p "${biosPath}/citron"
    ln -sn "${HOME}/.local/share/citron/keys/" "${biosPath}/citron/keys"
    ln -sn "${HOME}/.local/share/citron/nand/system/Contents/registered/" "${biosPath}/citron/firmware"

}

# SetLanguage
Citron_setLanguage () {
    setMSG "Setting Citron Language"
    # shellcheck disable=2155
    local language=$( locale | grep LANG | cut -d= -f2 | cut -d_ -f1 )
    languageOpt="language_index="
    languageDefaultOpt="language_index\\\\default="
    newLanguageDefaultOpt="language_index\\\\default=false" # we need those or else itll reset
    regionOpt="region_index="
    regionDefaultOpt="region_index\\\\default="
    newRegionDefaultOpt="region_index\\\\default=false"
	#TODO: call this somewhere, and input the $language from somewhere (args?)
	if [[ -f "${Citron_configFile}" ]]; then
		if [ ${Citron_languages[$language]+_} ]; then
            newLanguageOpt='language_index='"${Citron_languages[$language]}"
            newRegionOpt='region_index='"${Citron_regions[$language]}"
            changeLine "${languageOpt}" "${newLanguageOpt}" "${Citron_configFile}"
            changeLine "${languageDefaultOpt}" "${newLanguageDefaultOpt}" "${Citron_configFile}"
            changeLine "${regionOpt}" "${newRegionOpt}" "${Citron_configFile}"
            changeLine "${regionDefaultOpt}" "${newRegionDefaultOpt}" "${Citron_configFile}"
		fi
	fi
}

# SetupSaves
Citron_setupSaves () {
    echo "Begin Citron save link"
    # shellcheck disable=2154
    unlink "${savesPath}/citron/saves" 2>/dev/null # Fix for previous bad symlink2>/dev/null
    linkToSaveFolder citron saves "${storagePath}/citron/nand/user/save/"
    linkToSaveFolder citron profiles "${storagePath}/citron/nand/system/save/8000000000000010/su/avators/"
}

# SetupStorage
Citron_setupStorage () {
    echo "Begin Citron storage config"
    mkdir -p "${storagePath}/citron/dump"
    mkdir -p "${storagePath}/citron/load"
    mkdir -p "${storagePath}/citron/sdmc"
    mkdir -p "${storagePath}/citron/nand"
    mkdir -p "${storagePath}/citron/screenshots"
    mkdir -p "${storagePath}/citron/tas"
    #Symlink to saves for CloudSync
    ln -sn "${storagePath}/citron/nand/system/save/8000000000000010/su/avators/" "${savesPath}/citron/profiles"
}

# WipeSettings
Citron_wipe () {
    echo "Begin Citron delete config directories"
    rm -rf "${HOME}/.config/citron"
    rm -rf "${HOME}/.local/share/citron"
}

# Uninstall
Citron_uninstall () {
    echo "Begin Citron uninstall"
    removeParser "nintendo_switch_citron.json"
    rm -rf "${Citron_emuPath}"
}

# setABXYstyle
Citron_setABXYstyle () {
    echo "NYI"
}

# WideScreenOn
Citron_wideScreenOn () {
    echo "NYI"
}

# WideScreenOff
Citron_wideScreenOff () {
    echo "NYI"
}

# BezelOn
Citron_bezelOn () {
    echo "NYI"
}

# BezelOff
Citron_bezelOff () {
    echo "NYI"
}

# finalExec - Extra stuff
Citron_finalize () {
    echo "Begin Citron finalize"
    Citron_cleanup
}

# isInstalled
Citron_IsInstalled () {
    if [ -e "$Citron_emuPath" ]; then
        echo "true"
    else
        echo "false"
    fi
}

# resetConfig
Citron_resetConfig () {
    Citron_init &>/dev/null && echo "true" || echo "false"
}

# setResolution
Citron_setResolution () {
    # shellcheck disable=2154
	case "${citronResolution}" in
		"720P") multiplier=2; docked="false";;
		"1080P") multiplier=2; docked="true";;
		"1440P") multiplier=3; docked="false";;
		"4K") multiplier=3; docked="true";;
		*) echo "Error"; return 1;;
	esac

	RetroArch_setConfigOverride "resolution_setup" "${multiplier}" "$Citron_configFile"
	RetroArch_setConfigOverride "use_docked_mode" "${docked}" "$Citron_configFile"
}

# flushEmulatorLauncher
Citron_flushEmulatorLauncher () {
	flushEmulatorLaunchers "citron"
}

# addESConfig
Citron_addESConfig () {
    ESDE_junksettingsFile
    ESDE_addCustomSystemsFile
    ESDE_setEmulationFolder

    # shellcheck disable=2154
	if [[ $(grep -rnw "${es_systemsFile}" -e 'switch') == "" ]]; then
        # shellcheck disable=2016 # These variables are not for bash.
		xmlstarlet ed -S --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'switch' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Nintendo Switch' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/switch' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.nca .NCA .nro .NRO .nso .NSO .nsp .NSP .xci .XCI' \
		--subnode '$newSystem' --type elem --name 'commandB' -v "%EMULATOR_RYUJINX% %ROM%" \
		--insert '$newSystem/commandB' --type attr --name 'label' --value "Ryujinx (Standalone)" \
		--subnode '$newSystem' --type elem --name 'commandV' -v "%INJECT%=%BASENAME%.esprefix %EMULATOR_CITRON% -f -g %ROM%" \
		--insert '$newSystem/commandV' --type attr --name 'label' --value "Citron (Standalone)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'switch' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'switch' \
		-r 'systemList/system/commandB' -v 'command' \
		-r 'systemList/system/commandV' -v 'command' \
		"${es_systemsFile}"

		xmlstarlet fo "${es_systemsFile}" > "${es_systemsFile}.tmp" && mv "${es_systemsFile}.tmp" "${es_systemsFile}"
	fi
	# Custom Systems config end

    # shellcheck disable=2154
	rsync -avhp --mkpath "${emudeckBackend}/chimeraOS/configs/emulationstation/custom_systems/es_find_rules.xml" "$(dirname "${es_rulesFile}")" --backup --suffix=.bak
    # shellcheck disable=2154
    sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" "${es_rulesFile}"
}

# addParser
Citron_addParser () {
  addParser "nintendo_switch_citron.json"
}