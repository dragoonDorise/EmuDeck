#!/usr/bin/env bash

# emuDeckSuyu

# Variables
suyu_emuName="suyu"
# shellcheck disable=2034,2154
suyu_emuType="${emuDeckEmuTypeAppImage}"
# shellcheck disable=2154
suyu_emuPath="${emusFolder}/suyu.AppImage"
suyu_configFile="${HOME}/.config/suyu/qt-config.ini"

# Languages
declare -A suyu_languages=(
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
# https://github.com/suyu-emu/suyu/blob/master/src/suyu/configuration/configure_system.ui#L272-L309
declare -A suyu_regions=(
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

# Install
suyu_install () {
    echo "Begin suyu Install"

    local showProgress=$1
    local success="false"
    if installEmuAI "${suyu_emuName}" "https://gitlab.com/suyu-emu/suyu-releases/-/raw/master/v0.0.2-master/suyu-mainline--.AppImage" "suyu" "${showProgress}"; then
        success="true"
    fi

    if [ "${success}" != "true" ]; then
        return 1
    fi
}

# ApplyInitialSettings
suyu_init () {
    echo "Begin suyu Init"

    # shellcheck disable=2154
	cp "${emudeckBackend}/tools/launchers/suyu.sh" "${toolsPath}/launchers/suyu.sh"
	chmod +x "${toolsPath}/launchers/suyu.sh"
    mkdir -p "${HOME}/.config/suyu"
    mkdir -p "${HOME}/.local/share/suyu"
	rsync -avhp "${emudeckBackend}/configs/org.suyu_emu.suyu/config/suyu/." "${HOME}/.config/suyu"
	rsync -avhp "${emudeckBackend}/configs/org.suyu_emu.suyu/data/suyu/." "${HOME}/.local/share/suyu"
    suyu_migrate
    configEmuAI "${suyu_emuName}" "config" "${HOME}/.config/suyu" "${emudeckBackend}/configs/org.suyu_emu.suyu/config/suyu" "true"
    configEmuAI "${suyu_emuName}" "data" "${HOME}/.local/share/suyu" "${emudeckBackend}/configs/org.suyu_emu.suyu/data/suyu" "true"

    suyu_setEmulationFolder
    suyu_setupStorage
    suyu_setupSaves
    suyu_finalize
    #SRM_createParsers
    suyu_flushEmulatorLauncher
  	createDesktopShortcut   "${HOME}/.local/share/applications/suyu.desktop" \
							"suyu (AppImage)" \
							"${toolsPath}/launchers/suyu.sh"  \
							"False"
    # shellcheck disable=2154
	if [ -e "${ESDE_toolPath}" ]; then
		suyu_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi
}

# update
suyu_update () {
    echo "Begin suyu update"

    suyu_migrate

    configEmuAI "${suyu_emuName}" "config" "${HOME}/.config/suyu" "${emudeckBackend}/configs/org.suyu_emu.suyu/config/suyu"
    configEmuAI "${suyu_emuName}" "data" "${HOME}/.local/share/suyu" "${emudeckBackend}/configs/org.suyu_emu.suyu/data/suyu"

    suyu_setEmulationFolder
    suyu_setupStorage
    suyu_setupSaves
    suyu_finalize
    suyu_flushEmulatorLauncher
}

# ConfigurePaths
suyu_setEmulationFolder () {
    echo "Begin suyu Path Config"

    screenshotDirOpt='Screenshots\\screenshot_path='
    gameDirOpt='Paths\\gamedirs\\4\\path='
    dumpDirOpt='dump_directory='
    loadDir='load_directory='
    nandDirOpt='nand_directory='
    sdmcDirOpt='sdmc_directory='
    tasDirOpt='tas_directory='
    # shellcheck disable=2154
    newScreenshotDirOpt='Screenshots\\screenshot_path='"${storagePath}/suyu/screenshots"
    # shellcheck disable=2154
    newGameDirOpt='Paths\\gamedirs\\4\\path='"${romsPath}/switch"
    newDumpDirOpt='dump_directory='"${storagePath}/suyu/dump"
    newLoadDir='load_directory='"${storagePath}/suyu/load"
    newNandDirOpt='nand_directory='"${storagePath}/suyu/nand"
    newSdmcDirOpt='sdmc_directory='"${storagePath}/suyu/sdmc"
    newTasDirOpt='tas_directory='"${storagePath}/suyu/tas"

    sed -i "/${screenshotDirOpt}/c\\${newScreenshotDirOpt}" "${suyu_configFile}"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "${suyu_configFile}"
    sed -i "/${dumpDirOpt}/c\\${newDumpDirOpt}" "${suyu_configFile}"
    sed -i "/${loadDir}/c\\${newLoadDir}" "${suyu_configFile}"
    sed -i "/${nandDirOpt}/c\\${newNandDirOpt}" "${suyu_configFile}"
    sed -i "/${sdmcDirOpt}/c\\${newSdmcDirOpt}" "${suyu_configFile}"
    sed -i "/${tasDirOpt}/c\\${newTasDirOpt}" "${suyu_configFile}"

    # Setup Bios symlinks
    # shellcheck disable=2154
    {
        unlink "${biosPath}/suyu/keys"
        unlink "${biosPath}/suyu/firmware"
    } 2>/dev/null
    mkdir -p "${biosPath}/suyu"
    mkdir -p "${HOME}/.local/share/suyu/keys/"
    mkdir -p "${storagePath}/suyu/nand/system/Contents/registered/"

    ln -sn "${HOME}/.local/share/suyu/keys/" "${biosPath}/suyu/keys"
    ln -sn "${storagePath}/suyu/nand/system/Contents/registered/" "${biosPath}/suyu/firmware"

    touch "${storagePath}/suyu/nand/system/Contents/registered/putfirmwarehere.txt"
}

# SetLanguage
suyu_setLanguage () {
    setMSG "Setting suyu Language"

    languageOpt="language_index="
    languageDefaultOpt="language_index\\\\default="
    newLanguageDefaultOpt="language_index\\\\default=false" # we need those or else itll reset
    regionOpt="region_index="
    regionDefaultOpt="region_index\\\\default="
    newRegionDefaultOpt="region_index\\\\default=false"
	#TODO: call this somewhere, and input the $language from somewhere (args?)
	if [[ -f "${suyu_configFile}" ]]; then
		if [ ${suyu_languages[$language]+_} ]; then
            newLanguageOpt='language_index='"${suyu_languages[$language]}"
            newRegionOpt='region_index='"${suyu_regions[$language]}"
            changeLine "${languageOpt}" "${newLanguageOpt}" "${suyu_configFile}"
            changeLine "${languageDefaultOpt}" "${newLanguageDefaultOpt}" "${suyu_configFile}"
            changeLine "${regionOpt}" "${newRegionOpt}" "${suyu_configFile}"
            changeLine "${regionDefaultOpt}" "${newRegionDefaultOpt}" "${suyu_configFile}"
		fi
	fi
}

# SetupSaves
suyu_setupSaves () {
    echo "Begin suyu save link"
    # shellcheck disable=2154
    unlink "${savesPath}/suyu/saves" 2>/dev/null # Fix for previous bad symlink2>/dev/null
    linkToSaveFolder suyu saves "${storagePath}/suyu/nand/user/save/"
    linkToSaveFolder suyu profiles "${storagePath}/suyu/nand/system/save/8000000000000010/su/avators/"
}

# SetupStorage
suyu_setupStorage () {
    echo "Begin suyu storage config"
    mkdir -p "${storagePath}/suyu/dump"
    mkdir -p "${storagePath}/suyu/load"
    mkdir -p "${storagePath}/suyu/sdmc"
    mkdir -p "${storagePath}/suyu/nand"
    mkdir -p "${storagePath}/suyu/screenshots"
    mkdir -p "${storagePath}/suyu/tas"
    #Symlink to saves for CloudSync
    ln -sn "${storagePath}/suyu/nand/system/save/8000000000000010/su/avators/" "${savesPath}/suyu/profiles"
}

# WipeSettings
suyu_wipe () {
    echo "Begin suyu delete config directories"
    rm -rf "${HOME}/.config/suyu"
    rm -rf "${HOME}/.local/share/suyu"
}

# Uninstall
suyu_uninstall () {
    echo "Begin suyu uninstall"
    rm -rf "${suyu_emuPath}"
    suyuEA_uninstall
}

# Migrate
suyu_migrate () {
    echo "Begin suyu Migration"
    # shellcheck disable=2154
    migrationFlag="${emudeckFolder}/.${suyu_emuName}MigrationCompleted"
    # check if we have a nomigrateflag for $emu
    if [ ! -f "${migrationFlag}" ]; then
        # suyu flatpak to appimage
        # From -- > to
        migrationTable=()
        migrationTable+=("${HOME}/.var/app/org.suyu_emu.suyu/data/suyu" "${HOME}/.local/share/suyu")
        migrationTable+=("${HOME}/.var/app/org.suyu_emu.suyu/config/suyu" "${HOME}/.config/suyu")

        # migrateAndLinkConfig "$emu" "$migrationTable"
        touch "${migrationFlag}"
    fi

    # move data from hidden folders out to these folders in case the user already put stuff here.
    origPath="${HOME}/.local/share/"

    suyu_setupStorage

    rsync -av "${origPath}suyu/dump" "${storagePath}/suyu/" && rm -rf "${origPath}suyu/dump"
    rsync -av "${origPath}suyu/load" "${storagePath}/suyu/" && rm -rf "${origPath}suyu/load"
    rsync -av "${origPath}suyu/sdmc" "${storagePath}/suyu/" && rm -rf "${origPath}suyu/sdmc"
    rsync -av "${origPath}suyu/nand" "${storagePath}/suyu/" && rm -rf "${origPath}suyu/nand"
    rsync -av "${origPath}suyu/screenshots" "${storagePath}/suyu/" && rm -rf "${origPath}suyu/screenshots"
    rsync -av "${origPath}suyu/tas" "${storagePath}/suyu/" && rm -rf "${origPath}suyu/tas"
}

# setABXYstyle
suyu_setABXYstyle () {
    echo "NYI"
}

# WideScreenOn
suyu_wideScreenOn () {
    echo "NYI"
}

# WideScreenOff
suyu_wideScreenOff () {
    echo "NYI"
}

# BezelOn
suyu_bezelOn () {
    echo "NYI"
}

# BezelOff
suyu_bezelOff () {
    echo "NYI"
}

# finalExec - Extra stuff
suyu_finalize () {
    echo "Begin suyu finalize"
}

# IsInstalled
suyu_IsInstalled () {
    if [ -e "${suyu_emuPath}" ]; then
        echo "true"
    else
        echo "false"
    fi
}

# resetConfig
suyu_resetConfig () {
    suyu_init &>/dev/null && echo "true" || echo "false"
}

### suyu EA
suyuEA_install () {
    local jwtHost="https://api.suyu-emu.org/jwt/installer/"
    local suyuEaHost="https://api.suyu-emu.org/downloads/earlyaccess/"
    # shellcheck disable=2155
    local suyuEaMetadata=$( curl -fSs "${suyuEaHost}" )
    # shellcheck disable=2155
    local fileToDownload=$( echo "${suyuEaMetadata}" | jq -r '.files[] | select(.name|test(".*.AppImage")).url' )
    # shellcheck disable=2034,2155
    local currentVer=$( echo "${suyuEaMetadata}" | jq -r '.files[] | select(.name|test(".*.AppImage")).name' )
    local tokenValue="${1}"
    local showProgress="${2}"
    local user
    local auth

    read -r user auth <<<"$( echo "${tokenValue}"==== | fold -w 4 | sed '$ d' | tr -d '\n' | base64 --decode| awk -F":" '{print $1" "$2}' )" || echo "invalid"

    #echo "get bearer token"
    BEARERTOKEN=$( curl -X POST "${jwtHost}" -H "X-Username: ${user}" -H "X-Token: ${auth}" -H "User-Agent: EmuDeck" )

    #echo "download ea appimage"

    # shellcheck disable=2154
    if safeDownload "suyu-ea" "${fileToDownload}" "${suyuEA_emuPath}" "${showProgress}" "Authorization: Bearer ${BEARERTOKEN}"; then
        chmod +x "${suyuEA_emuPath}"

        cp -v "${emudeckBackend}/tools/launchers/suyu.sh" "${toolsPath}/launchers/" &>/dev/null
        chmod +x "${toolsPath}/launchers/suyu.sh"
        echo "true"
        return 0
    else
        echo "fail"
        return 1
    fi
}

# EA_addToken
suyuEA_addToken () {
    local tokenValue=$1
    local user=""
    local auth=""

   read -r user auth <<<"$( echo "${tokenValue}"==== | fold -w 4 | sed '$ d' | tr -d '\n' | base64 --decode| awk -F":" '{print $1" "$2}' )" && suyuEA_install "${tokenValue}" || echo "invalid"
}

# EA_IsInstalled
suyuEA_IsInstalled () {
    if [ -e "${suyuEA_emuPath}" ]; then
        echo "true"
    else
        echo "false"
    fi
}

# EA_uninstall
suyuEA_uninstall () {
    echo "Begin suyu EA uninstall"
    rm -rf "${suyuEA_emuPath}"
}

# setResolution
suyu_setResolution () {
    # shellcheck disable=2154
	case "${suyuResolution}" in
		"720P") multiplier=2; docked="false";;
		"1080P") multiplier=2; docked="true";;
		"1440P") multiplier=3; docked="false";;
		"4K") multiplier=3; docked="true";;
		*) echo "Error"; return 1;;
	esac

	RetroArch_setConfigOverride "resolution_setup" "${multiplier}" "${suyu_configFile}"
	RetroArch_setConfigOverride "use_docked_mode" "${docked}" "${suyu_configFile}"
}

# flushEmulatorLauncher
suyu_flushEmulatorLauncher () {
	flushEmulatorLaunchers "suyu"
}

# addESConfig
suyu_addESConfig () {
    # shellcheck disable=2154
	if [[ $(grep -rnw "${es_systemsFile}" -e 'switch') == "" ]]; then
        # shellcheck disable=2016 # These variables are not intended for bash.
		xmlstarlet ed -S --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'switch' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Nintendo Switch' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/switch' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.nca .NCA .nro .NRO .nso .NSO .nsp .NSP .xci .XCI' \
		--subnode '$newSystem' --type elem --name 'commandB' -v "%EMULATOR_RYUJINX% %ROM%" \
		--insert '$newSystem/commandB' --type attr --name 'label' --value "Ryujinx (Standalone)" \
		--subnode '$newSystem' --type elem --name 'commandV' -v "%INJECT%=%BASENAME%.esprefix %EMULATOR_YUZU% -f -g %ROM%" \
		--insert '$newSystem/commandV' --type attr --name 'label' --value "suyu (Standalone)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'switch' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'switch' \
		-r 'systemList/system/commandB' -v 'command' \
		-r 'systemList/system/commandV' -v 'command' \
		"${es_systemsFile}"

		xmlstarlet fo "${es_systemsFile}" > "${es_systemsFile}.tmp" && mv "${es_systemsFile}.tmp" "${es_systemsFile}"
	fi
	#Custom Systems config end
}
