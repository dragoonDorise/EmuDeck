#!/bin/bash

#variables
Eden_emuName="eden"
Eden_emuType="$emuDeckEmuTypeAppImage"
Eden_emuPath="$emusFolder/Eden.AppImage"

Eden_configFile="$HOME/.config/eden/qt-config.ini"

# https://github.com/eden-emu/eden/blob/master/src/core/file_sys/control_metadata.cpp#L41-L60
declare -A Eden_languages
Eden_languages=(
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
["tw"]=11) # TODO: not all langs but we need to switch to full lang codes to support those

# https://github.com/eden-emu/eden/blob/master/src/eden/configuration/configure_system.ui#L272-L309
declare -A Eden_regions
Eden_regions=(
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

#cleanupOlderThings
Eden_cleanup() {
    echo "Begin Eden Cleanup"
    #Fixes repeated Symlink for older installations
}

#Install
Eden_install() {
  setMSG "Begin Eden Install"

  local showProgress=$1

  # Llamada a la API para obtener la última release
#   local response=$(curl -s "https://git.eden-emu.org/api/v1/repos/Eden/Eden/releases")
#
#   if installEmuBI "$Eden_emuName" "$( echo "$response" | jq -r '.[0].assets[] | select(.name | contains("Linux")) | .browser_download_url ' | head -n 1)" "$Eden_emuName" "tar.gz" "$showProgress"; then
#     mkdir -p "$emusFolder/eden"
#     tar -xvf "$emusFolder/$Eden_emuName.tar.gz" --strip-components=1 -C "$emusFolder/eden" && rm -rf "$HOME/Applications/$Eden_emuName.tar.gz"
#     chmod +x "$emusFolder/eden/eden"
#   else
#     return 1
#   fi

#     local success="false"
#     if installEmuAI "$Eden_emuName" "$(getReleaseURLGH "eden-appimage/eden-appimage" "AppImage")" "" "$showProgress" "" ""; then
#         success="true"
#     fi
#
#     if [ "$success" != "true" ]; then
#         return 1
#     fi

}

#ApplyInitialSettings
Eden_init() {
    echo "Begin Eden Init"

	cp "$emudeckBackend/tools/launchers/eden.sh" "$toolsPath/launchers/eden.sh"
	chmod +x "$toolsPath/launchers/eden.sh"
    mkdir -p "$HOME/.config/eden"
    mkdir -p "$HOME/.local/share/eden"
	rsync -avhp "$emudeckBackend/configs/eden/config/." "$HOME/.config/eden"
	rsync -avhp "$emudeckBackend/configs/eden/data/." "$HOME/.local/share/eden"

    configEmuAI "$Eden_emuName" "config" "$HOME/.config/eden" "$emudeckBackend/configs/eden/config" "true"
    configEmuAI "$Eden_emuName" "data" "$HOME/.local/share/eden" "$emudeckBackend/configs/eden/data" "true"

    Eden_setEmulationFolder
    Eden_setupStorage
    Eden_setupSaves
    Eden_finalize
    Eden_addParser
    Eden_flushEmulatorLauncher
  	createDesktopShortcut   "$HOME/.local/share/applications/eden.desktop" \
							"Eden (AppImage)" \
							"${toolsPath}/launchers/eden.sh"  \
							"False"

	if [ -e "$ESDE_toolPath" ] || [ -f "${toolsPath}/$ESDE_downloadedToolName" ] || [ -f "${toolsPath}/$ESDE_oldtoolName.AppImage" ]; then
		Eden_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi

    #Eden_setLanguage

}

#update
Eden_update() {
    echo "Begin Eden update"

    Eden_init
}

#ConfigurePaths
Eden_setEmulationFolder() {
    echo "Begin Eden Path Config"

    screenshotDirOpt='Screenshots\\screenshot_path='
    gameDirOpt='Paths\\gamedirs\\4\\path='
    dumpDirOpt='dump_directory='
    loadDir='load_directory='
    nandDirOpt='nand_directory='
    sdmcDirOpt='sdmc_directory='
    tasDirOpt='tas_directory='
    newScreenshotDirOpt='Screenshots\\screenshot_path='"${storagePath}/eden/screenshots"
    newGameDirOpt='Paths\\gamedirs\\4\\path='"${romsPath}/switch"
    newDumpDirOpt='dump_directory='"${storagePath}/eden/dump"
    newLoadDir='load_directory='"${storagePath}/eden/load"
    newNandDirOpt='nand_directory='"${storagePath}/eden/nand"
    newSdmcDirOpt='sdmc_directory='"${storagePath}/eden/sdmc"
    newTasDirOpt='tas_directory='"${storagePath}/eden/tas"

    sed -i "/${screenshotDirOpt}/c\\${newScreenshotDirOpt}" "$Eden_configFile"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$Eden_configFile"
    sed -i "/${dumpDirOpt}/c\\${newDumpDirOpt}" "$Eden_configFile"
    sed -i "/${loadDir}/c\\${newLoadDir}" "$Eden_configFile"
    sed -i "/${nandDirOpt}/c\\${newNandDirOpt}" "$Eden_configFile"
    sed -i "/${sdmcDirOpt}/c\\${newSdmcDirOpt}" "$Eden_configFile"
    sed -i "/${tasDirOpt}/c\\${newTasDirOpt}" "$Eden_configFile"

    #Setup Bios symlinks
    unlink "${biosPath}/eden/keys" 2>/dev/null
    unlink "${biosPath}/eden/firmware" 2>/dev/null

    mkdir -p "$HOME/.local/share/eden/keys/"
    mkdir -p "${biosPath}/eden"
    ln -sn "$HOME/.local/share/eden/keys/" "${biosPath}/eden/keys"
    ln -sn "$HOME/.local/share/eden/nand/system/Contents/registered/" "${biosPath}/eden/firmware"

}

#SetLanguage
Eden_setLanguage(){
    setMSG "Setting Eden Language"
    local language=$(locale | grep LANG | cut -d= -f2 | cut -d_ -f1)
    languageOpt="language_index="
    languageDefaultOpt="language_index\\\\default="
    newLanguageDefaultOpt="language_index\\\\default=false" # we need those or else itll reset
    regionOpt="region_index="
    regionDefaultOpt="region_index\\\\default="
    newRegionDefaultOpt="region_index\\\\default=false"
	#TODO: call this somewhere, and input the $language from somewhere (args?)
	if [[ -f "${Eden_configFile}" ]]; then
		if [ ${Eden_languages[$language]+_} ]; then
            newLanguageOpt='language_index='"${Eden_languages[$language]}"
            newRegionOpt='region_index='"${Eden_regions[$language]}"
            changeLine "$languageOpt" "$newLanguageOpt" "$Eden_configFile"
            changeLine "$languageDefaultOpt" "$newLanguageDefaultOpt" "$Eden_configFile"
            changeLine "$regionOpt" "$newRegionOpt" "$Eden_configFile"
            changeLine "$regionDefaultOpt" "$newRegionDefaultOpt" "$Eden_configFile"
		fi
	fi
}

#SetupSaves
Eden_setupSaves() {
    echo "Begin Eden save link"
    unlink "${savesPath}/eden/saves" 2>/dev/null # Fix for previous bad symlink2>/dev/null
    linkToSaveFolder eden saves "${storagePath}/eden/nand/user/save/"
    linkToSaveFolder eden profiles "${storagePath}/eden/nand/system/save/8000000000000010/su/avators/"
}

#SetupStorage
Eden_setupStorage() {
    echo "Begin Eden storage config"
    mkdir -p "${storagePath}/eden/dump"
    mkdir -p "${storagePath}/eden/load"
    mkdir -p "${storagePath}/eden/sdmc"
    mkdir -p "${storagePath}/eden/nand"
    mkdir -p "${storagePath}/eden/screenshots"
    mkdir -p "${storagePath}/eden/tas"
    #Symlink to saves for CloudSync
    ln -sn "${storagePath}/eden/nand/system/save/8000000000000010/su/avators/" "${savesPath}/eden/profiles"
}

#WipeSettings
Eden_wipe() {
    echo "Begin Eden delete config directories"
    rm -rf "$HOME/.config/eden"
    rm -rf "$HOME/.local/share/eden"
}

#Uninstall
Eden_uninstall() {
    echo "Begin Eden uninstall"
    removeParser "nintendo_switch_eden.json"
    rm -rf "$Eden_emuPath"
}

#setABXYstyle
Eden_setABXYstyle() {
    echo "NYI"
}

#WideScreenOn
Eden_wideScreenOn() {
    echo "NYI"
}

#WideScreenOff
Eden_wideScreenOff() {
    echo "NYI"
}

#BezelOn
Eden_bezelOn() {
    echo "NYI"
}

#BezelOff
Eden_bezelOff() {
    echo "NYI"
}

#finalExec - Extra stuff
Eden_finalize() {
    echo "Begin Eden finalize"
    Eden_cleanup
}

Eden_IsInstalled() {
    if [ -e "$Eden_emuPath" ]; then
        echo "true"
    else
        echo "false"
    fi
}


Eden_resetConfig() {
    Eden_init &>/dev/null && echo "true" || echo "false"
}



Eden_setResolution(){

	case $edenResolution in
		"720P") multiplier=2; docked="false";;
		"1080P") multiplier=2; docked="true";;
		"1440P") multiplier=3; docked="false";;
		"4K") multiplier=3; docked="true";;
		*) echo "Error"; return 1;;
	esac

	RetroArch_setConfigOverride "resolution_setup" $multiplier "$Eden_configFile"
	RetroArch_setConfigOverride "use_docked_mode" $docked "$Eden_configFile"
}

Eden_flushEmulatorLauncher(){


	flushEmulatorLaunchers "eden"

}

Eden_addESConfig(){

    ESDE_junksettingsFile
    ESDE_addCustomSystemsFile
    ESDE_setEmulationFolder

	if [[ $(grep -rnw "$es_systemsFile" -e 'switch') == "" ]]; then
		xmlstarlet ed -S --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'switch' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Nintendo Switch' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/switch' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.nca .NCA .nro .NRO .nso .NSO .nsp .NSP .xci .XCI' \
		--subnode '$newSystem' --type elem --name 'commandB' -v "%EMULATOR_RYUJINX% %ROM%" \
		--insert '$newSystem/commandB' --type attr --name 'label' --value "Ryujinx (Standalone)" \
		--subnode '$newSystem' --type elem --name 'commandV' -v "%INJECT%=%BASENAME%.esprefix %EMULATOR_CITRON% -f -g %ROM%" \
		--insert '$newSystem/commandV' --type attr --name 'label' --value "Eden (Standalone)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'switch' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'switch' \
		-r 'systemList/system/commandB' -v 'command' \
		-r 'systemList/system/commandV' -v 'command' \
		"$es_systemsFile"

		xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
	fi
	#Custom Systems config end

	ESDE_refreshCustomEmus
}


Eden_addParser(){
  addParser "nintendo_switch_eden.json"
}