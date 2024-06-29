#!/bin/bash

#variables
Sudachi_emuName="sudachi"
Sudachi_emuType="$emuDeckEmuTypeAppImage"
Sudachi_emuPath="$HOME/Applications/sudachi"

Sudachi_configFile="$HOME/.config/sudachi/qt-config.ini"

# https://github.com/yuzu-emu/yuzu/blob/master/src/core/file_sys/control_metadata.cpp#L41-L60
declare -A Sudachi_languages
Sudachi_languages=(
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

# https://github.com/yuzu-emu/yuzu/blob/master/src/yuzu/configuration/configure_system.ui#L272-L309
declare -A Sudachi_regions
Sudachi_regions=(
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
Sudachi_cleanup() {
    echo "Begin Sudachi Cleanup"
    #Fixes repeated Symlink for older installations

    if [ -f  "$HOME/.local/share/sudachi/keys/keys" ]; then
        unlink "$HOME/.local/share/sudachi/keys/keys"
    fi

    if [ -f  "$HOME/.local/share/sudachi/keys/keys" ]; then
        unlink "$HOME/.local/share/sudachi/nand/system/Contents/registered/registered"
    fi

}

#Install
Sudachi_install() {
    echo "Begin Sudachi Install"


}

#ApplyInitialSettings
Sudachi_init() {
    echo "Begin Sudachi Init"

	cp "$EMUDECKGIT/tools/launchers/sudachi.sh" "$toolsPath/launchers/sudachi.sh"
	chmod +x "$toolsPath/launchers/sudachi.sh"
    mkdir -p "$HOME/.config/sudachi"
    mkdir -p "$HOME/.local/share/sudachi"
	rsync -avhp "$EMUDECKGIT/configs/sudachi/config/." "$HOME/.config/sudachi"
	rsync -avhp "$EMUDECKGIT/configs/sudachi/data/." "$HOME/.local/share/yuzu"
    Sudachi_migrate
    configEmuAI "$Sudachi_emuName" "config" "$HOME/.config/sudachi" "$EMUDECKGIT/configs/sudachi/config" "true"
    configEmuAI "$Sudachi_emuName" "data" "$HOME/.local/share/yuzu" "$EMUDECKGIT/configs/sudachi/data" "true"

    Sudachi_setEmulationFolder
    Sudachi_setupStorage
    Sudachi_setupSaves
    Sudachi_finalize
    #SRM_createParsers
    Sudachi_flushEmulatorLauncher
  	createDesktopShortcut   "$HOME/.local/share/applications/sudachi.desktop" \
							"Sudachi" \
							"${toolsPath}/launchers/sudachi.sh"  \
							"False"
    Sudachi_setLanguage
}

#update
Sudachi_update() {
    echo "Begin Sudachi update"
    #Sudachi_migrate
    Sudachi_setEmulationFolder
    Sudachi_setupStorage
    Sudachi_setupSaves
    Sudachi_finalize
    Sudachi_flushEmulatorLauncher
}

#ConfigurePaths
Sudachi_setEmulationFolder() {
    echo "Begin Sudachi Path Config"

    screenshotDirOpt='Screenshots\\screenshot_path='
    gameDirOpt='Paths\\gamedirs\\4\\path='
    dumpDirOpt='dump_directory='
    loadDir='load_directory='
    nandDirOpt='nand_directory='
    sdmcDirOpt='sdmc_directory='
    tasDirOpt='tas_directory='
    newScreenshotDirOpt='Screenshots\\screenshot_path='"${storagePath}/yuzu/screenshots"
    newGameDirOpt='Paths\\gamedirs\\4\\path='"${romsPath}/switch"
    newDumpDirOpt='dump_directory='"${storagePath}/yuzu/dump"
    newLoadDir='load_directory='"${storagePath}/yuzu/load"
    newNandDirOpt='nand_directory='"${storagePath}/yuzu/nand"
    newSdmcDirOpt='sdmc_directory='"${storagePath}/yuzu/sdmc"
    newTasDirOpt='tas_directory='"${storagePath}/yuzu/tas"

    sed -i "/${screenshotDirOpt}/c\\${newScreenshotDirOpt}" "$Sudachi_configFile"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$Sudachi_configFile"
    sed -i "/${dumpDirOpt}/c\\${newDumpDirOpt}" "$Sudachi_configFile"
    sed -i "/${loadDir}/c\\${newLoadDir}" "$Sudachi_configFile"
    sed -i "/${nandDirOpt}/c\\${newNandDirOpt}" "$Sudachi_configFile"
    sed -i "/${sdmcDirOpt}/c\\${newSdmcDirOpt}" "$Sudachi_configFile"
    sed -i "/${tasDirOpt}/c\\${newTasDirOpt}" "$Sudachi_configFile"

    #Setup Bios symlinks
    unlink "${biosPath}/sudachi/keys" 2>/dev/null
    unlink "${biosPath}/sudachi/firmware" 2>/dev/null

    mkdir -p "$HOME/.local/share/sudachi/keys/"
    mkdir -p "${storagePath}/sudachi/nand/system/Contents/registered/"

    ln -sn "$HOME/.local/share/sudachi/keys/" "${biosPath}/sudachi/keys"
    ln -sn "${storagePath}/sudachi/nand/system/Contents/registered/" "${biosPath}/sudachi/firmware"

    touch "${storagePath}/sudachi/nand/system/Contents/registered/putfirmwarehere.txt"

}

#SetLanguage
Sudachi_setLanguage(){
    setMSG "Setting Sudachi Language"
    local language=$(locale | grep LANG | cut -d= -f2 | cut -d_ -f1)
    languageOpt="language_index="
    languageDefaultOpt="language_index\\\\default="
    newLanguageDefaultOpt="language_index\\\\default=false" # we need those or else itll reset
    regionOpt="region_index="
    regionDefaultOpt="region_index\\\\default="
    newRegionDefaultOpt="region_index\\\\default=false"
	#TODO: call this somewhere, and input the $language from somewhere (args?)
	if [[ -f "${Sudachi_configFile}" ]]; then
		if [ ${Sudachi_languages[$language]+_} ]; then
            newLanguageOpt='language_index='"${Sudachi_languages[$language]}"
            newRegionOpt='region_index='"${Sudachi_regions[$language]}"
            changeLine "$languageOpt" "$newLanguageOpt" "$Sudachi_configFile"
            changeLine "$languageDefaultOpt" "$newLanguageDefaultOpt" "$Sudachi_configFile"
            changeLine "$regionOpt" "$newRegionOpt" "$Sudachi_configFile"
            changeLine "$regionDefaultOpt" "$newRegionDefaultOpt" "$Sudachi_configFile"
		fi
	fi
}

#SetupSaves
Sudachi_setupSaves() {
    echo "Begin Sudachi save link"
    unlink "${savesPath}/sudachi/saves" 2>/dev/null # Fix for previous bad symlink2>/dev/null
    linkToSaveFolder sudachi saves "${storagePath}/sudachi/nand/user/save/"
    linkToSaveFolder sudachi profiles "${storagePath}/sudachi/nand/system/save/8000000000000010/su/avators/"
}

#SetupStorage
Sudachi_setupStorage() {
    echo "Begin Sudachi storage config"
    mkdir -p "${storagePath}/sudachi/dump"
    mkdir -p "${storagePath}/sudachi/load"
    mkdir -p "${storagePath}/sudachi/sdmc"
    mkdir -p "${storagePath}/sudachi/nand"
    mkdir -p "${storagePath}/sudachi/screenshots"
    mkdir -p "${storagePath}/sudachi/tas"
    #Symlink to saves for CloudSync
    ln -sn "${storagePath}/sudachi/nand/system/save/8000000000000010/su/avators/" "${savesPath}/sudachi/profiles"
}

#WipeSettings
Sudachi_wipe() {
    echo "Begin Sudachi delete config directories"
    rm -rf "$HOME/.config/sudachi"
    rm -rf "$HOME/.local/share/sudachi"
}

#Uninstall
Sudachi_uninstall() {
    echo "Begin Sudachi uninstall"
    rm -rf "$Sudachi_emuPath"
    SudachiEA_uninstall
}


#setABXYstyle
Sudachi_setABXYstyle(){
  sed -i 's|button_a="button:1|button_a="button:0|g' "$Sudachi_configFile"
  sed -i 's|button_b="button:0|button_a="button:1|g' "$Sudachi_configFile"
  sed -i 's|button_x="button:3|button_a="button:2|g' "$Sudachi_configFile"
  sed -i 's|button_y="button:2|button_a="button:3|g' "$Sudachi_configFile"
}

Sudachi_setBAYXstyle(){
  sed -i 's|button_a="button:0|button_a="button:1|g' "$Sudachi_configFile"
  sed -i 's|button_b="button:1|button_a="button:0|g' "$Sudachi_configFile"
  sed -i 's|button_x="button:2|button_a="button:3|g' "$Sudachi_configFile"
  sed -i 's|button_y="button:3|button_a="button:2|g' "$Sudachi_configFile"
}

#WideScreenOn
Sudachi_wideScreenOn() {
    echo "NYI"
}

#WideScreenOff
Sudachi_wideScreenOff() {
    echo "NYI"
}

#BezelOn
Sudachi_bezelOn() {
    echo "NYI"
}

#BezelOff
Sudachi_bezelOff() {
    echo "NYI"
}

#finalExec - Extra stuff
Sudachi_finalize() {
    echo "Begin Sudachi finalize"
    Sudachi_cleanup
}

Sudachi_IsInstalled() {
    if [ -e "$Sudachi_emuPath" ]; then
        echo "true"
    else
        echo "false"
    fi
}


Sudachi_resetConfig() {
    Sudachi_init &>/dev/null && echo "true" || echo "false"
}

Sudachi_setResolution(){

	case $yuzuResolution in
		"720P") multiplier=2; docked="false";;
		"1080P") multiplier=2; docked="true";;
		"1440P") multiplier=3; docked="false";;
		"4K") multiplier=3; docked="true";;
		*) echo "Error"; return 1;;
	esac

	RetroArch_setConfigOverride "resolution_setup" $multiplier "$Sudachi_configFile"
	RetroArch_setConfigOverride "use_docked_mode" $docked "$Sudachi_configFile"
}

Sudachi_flushEmulatorLauncher(){
	flushEmulatorLaunchers "sudachi"
}

Sudachi_addESConfig(){

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
		--subnode '$newSystem' --type elem --name 'commandV' -v "%INJECT%=%BASENAME%.esprefix %EMULATOR_YUZU% -f -g %ROM%" \
		--insert '$newSystem/commandV' --type attr --name 'label' --value "Sudachi (Standalone)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'switch' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'switch' \
		-r 'systemList/system/commandB' -v 'command' \
		-r 'systemList/system/commandV' -v 'command' \
		"$es_systemsFile"



		xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
	fi
	#Custom Systems config end

	rsync -avhp --mkpath "$EMUDECKGIT/chimeraOS/configs/emulationstation/custom_systems/es_find_rules.xml" "$(dirname "$es_rulesFile")" --backup --suffix=.bak

}