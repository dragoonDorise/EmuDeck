#!/bin/bash

#variables
Yuzu_emuName="yuzu"
Yuzu_emuType="$emuDeckEmuTypeAppImage"
Yuzu_emuPath="$HOME/Applications/yuzu.AppImage"

Yuzu_configFile="$HOME/.config/yuzu/qt-config.ini"

# https://github.com/yuzu-emu/yuzu/blob/master/src/core/file_sys/control_metadata.cpp#L41-L60
declare -A Yuzu_languages
Yuzu_languages=(
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
declare -A Yuzu_regions
Yuzu_regions=(
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
Yuzu_cleanup() {
    echo "Begin Yuzu Cleanup"
    #Fixes repeated Symlink for older installations

    if [ -f  "$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu/keys/keys" ]; then
        unlink "$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu/keys/keys"
    fi

    if [ -f  "$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu/keys/keys" ]; then
        unlink "$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu/nand/system/Contents/registered/registered"
    fi

}

#Install
Yuzu_install() {
    echo "Begin Yuzu Install"

    local showProgress=$1
    local lastVerFile="$HOME/emudeck/yuzu.ver"
    local latestVer=$(curl -fSs "https://api.github.com/repos/yuzu-emu/yuzu-mainline/releases" | jq -r '[ .[].tag_name ][0]')
    local success="false"
    if installEmuAI "$Yuzu_emuName" "$(getReleaseURLGH "yuzu-emu/yuzu-mainline" "AppImage")" "" "$showProgress" "$lastVerFile" "$latestVer"; then # yuzu.AppImage - needs to be lowercase yuzu for EsDE to find it
        success="true"
    fi

    if [ "$success" != "true" ]; then
        return 1
    fi
}

#ApplyInitialSettings
Yuzu_init() {
    echo "Begin Yuzu Init"

	cp "$EMUDECKGIT/tools/launchers/yuzu.sh" "$toolsPath/launchers/yuzu.sh"
	chmod +x "$toolsPath/launchers/yuzu.sh"
    mkdir -p "$HOME/.config/yuzu"
    mkdir -p "$HOME/.local/share/yuzu"
	rsync -avhp "$EMUDECKGIT/configs/org.yuzu_emu.yuzu/config/yuzu/." "$HOME/.config/yuzu"
	rsync -avhp "$EMUDECKGIT/configs/org.yuzu_emu.yuzu/data/yuzu/." "$HOME/.local/share/yuzu"
    Yuzu_migrate
    configEmuAI "$Yuzu_emuName" "config" "$HOME/.config/yuzu" "$EMUDECKGIT/configs/org.yuzu_emu.yuzu/config/yuzu" "true"
    configEmuAI "$Yuzu_emuName" "data" "$HOME/.local/share/yuzu" "$EMUDECKGIT/configs/org.yuzu_emu.yuzu/data/yuzu" "true"

    Yuzu_setEmulationFolder
    Yuzu_setupStorage
    Yuzu_setupSaves
    Yuzu_finalize
    #SRM_createParsers
    Yuzu_flushEmulatorLauncher
  	createDesktopShortcut   "$HOME/.local/share/applications/yuzu.desktop" \
							"yuzu (AppImage)" \
							"${toolsPath}/launchers/yuzu.sh"  \
							"False"

	if [ -e "$ESDE_toolPath" ] || [ -f "${toolsPath}/$ESDE_downloadedToolName" ] || [ -f "${toolsPath}/$ESDE_oldtoolName.AppImage" ]; then
		Yuzu_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi

    Yuzu_setLanguage

}

#update
Yuzu_update() {
    echo "Begin Yuzu update"

    Yuzu_migrate

    configEmuAI "$Yuzu_emuName" "config" "$HOME/.config/yuzu" "$EMUDECKGIT/configs/org.yuzu_emu.yuzu/config/yuzu"
    configEmuAI "$Yuzu_emuName" "data" "$HOME/.local/share/yuzu" "$EMUDECKGIT/configs/org.yuzu_emu.yuzu/data/yuzu"

    Yuzu_setEmulationFolder
    Yuzu_setupStorage
    Yuzu_setupSaves
    Yuzu_finalize
    Yuzu_flushEmulatorLauncher
}

#ConfigurePaths
Yuzu_setEmulationFolder() {
    echo "Begin Yuzu Path Config"

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

    sed -i "/${screenshotDirOpt}/c\\${newScreenshotDirOpt}" "$Yuzu_configFile"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$Yuzu_configFile"
    sed -i "/${dumpDirOpt}/c\\${newDumpDirOpt}" "$Yuzu_configFile"
    sed -i "/${loadDir}/c\\${newLoadDir}" "$Yuzu_configFile"
    sed -i "/${nandDirOpt}/c\\${newNandDirOpt}" "$Yuzu_configFile"
    sed -i "/${sdmcDirOpt}/c\\${newSdmcDirOpt}" "$Yuzu_configFile"
    sed -i "/${tasDirOpt}/c\\${newTasDirOpt}" "$Yuzu_configFile"

    #Setup Bios symlinks
    unlink "${biosPath}/yuzu/keys" 2>/dev/null
    unlink "${biosPath}/yuzu/firmware" 2>/dev/null

    mkdir -p "$HOME/.local/share/yuzu/keys/"
    mkdir -p "${storagePath}/yuzu/nand/system/Contents/registered/"

    ln -sn "$HOME/.local/share/yuzu/keys/" "${biosPath}/yuzu/keys"
    ln -sn "${storagePath}/yuzu/nand/system/Contents/registered/" "${biosPath}/yuzu/firmware"

    touch "${storagePath}/yuzu/nand/system/Contents/registered/putfirmwarehere.txt"

}

#SetLanguage
Yuzu_setLanguage(){
    setMSG "Setting Yuzu Language"
    local language=$(locale | grep LANG | cut -d= -f2 | cut -d_ -f1)
    languageOpt="language_index="
    languageDefaultOpt="language_index\\\\default="
    newLanguageDefaultOpt="language_index\\\\default=false" # we need those or else itll reset
    regionOpt="region_index="
    regionDefaultOpt="region_index\\\\default="
    newRegionDefaultOpt="region_index\\\\default=false"
	#TODO: call this somewhere, and input the $language from somewhere (args?)
	if [[ -f "${Yuzu_configFile}" ]]; then
		if [ ${Yuzu_languages[$language]+_} ]; then
            newLanguageOpt='language_index='"${Yuzu_languages[$language]}"
            newRegionOpt='region_index='"${Yuzu_regions[$language]}"
            changeLine "$languageOpt" "$newLanguageOpt" "$Yuzu_configFile"
            changeLine "$languageDefaultOpt" "$newLanguageDefaultOpt" "$Yuzu_configFile"
            changeLine "$regionOpt" "$newRegionOpt" "$Yuzu_configFile"
            changeLine "$regionDefaultOpt" "$newRegionDefaultOpt" "$Yuzu_configFile"
		fi
	fi
}

#SetupSaves
Yuzu_setupSaves() {
    echo "Begin Yuzu save link"
    unlink "${savesPath}/yuzu/saves" 2>/dev/null # Fix for previous bad symlink2>/dev/null
    linkToSaveFolder yuzu saves "${storagePath}/yuzu/nand/user/save/"
    linkToSaveFolder yuzu profiles "${storagePath}/yuzu/nand/system/save/8000000000000010/su/avators/"
}

#SetupStorage
Yuzu_setupStorage() {
    echo "Begin Yuzu storage config"
    mkdir -p "${storagePath}/yuzu/dump"
    mkdir -p "${storagePath}/yuzu/load"
    mkdir -p "${storagePath}/yuzu/sdmc"
    mkdir -p "${storagePath}/yuzu/nand"
    mkdir -p "${storagePath}/yuzu/screenshots"
    mkdir -p "${storagePath}/yuzu/tas"
    #Symlink to saves for CloudSync
    ln -sn "${storagePath}/yuzu/nand/system/save/8000000000000010/su/avators/" "${savesPath}/yuzu/profiles"
}

#WipeSettings
Yuzu_wipe() {
    echo "Begin Yuzu delete config directories"
    rm -rf "$HOME/.config/yuzu"
    rm -rf "$HOME/.local/share/yuzu"
}

#Uninstall
Yuzu_uninstall() {
    echo "Begin Yuzu uninstall"
    rm -rf "$Yuzu_emuPath"
    YuzuEA_uninstall
}


#Migrate
Yuzu_migrate() {
    echo "Begin Yuzu Migration"
    migrationFlag="$HOME/.config/EmuDeck/.${Yuzu_emuName}MigrationCompleted"
    #check if we have a nomigrateflag for $emu
    if [ ! -f "$migrationFlag" ]; then
        #yuzu flatpak to appimage
        #From -- > to
        migrationTable=()
        migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu" "$HOME/.local/share/yuzu")
        migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/config/yuzu" "$HOME/.config/yuzu")

        # migrateAndLinkConfig "$emu" "$migrationTable"
        touch "${migrationFlag}"
    fi

    #move data from hidden folders out to these folders in case the user already put stuff here.
    origPath="$HOME/.local/share/"

    Yuzu_setupStorage

    rsync -av "${origPath}yuzu/dump" "${storagePath}/yuzu/" && rm -rf "${origPath}yuzu/dump"
    rsync -av "${origPath}yuzu/load" "${storagePath}/yuzu/" && rm -rf "${origPath}yuzu/load"
    rsync -av "${origPath}yuzu/sdmc" "${storagePath}/yuzu/" && rm -rf "${origPath}yuzu/sdmc"
    rsync -av "${origPath}yuzu/nand" "${storagePath}/yuzu/" && rm -rf "${origPath}yuzu/nand"
    rsync -av "${origPath}yuzu/screenshots" "${storagePath}/yuzu/" && rm -rf "${origPath}yuzu/screenshots"
    rsync -av "${origPath}yuzu/tas" "${storagePath}/yuzu/" && rm -rf "${origPath}yuzu/tas"
}

#setABXYstyle
Yuzu_setABXYstyle() {
    echo "NYI"
}

#WideScreenOn
Yuzu_wideScreenOn() {
    echo "NYI"
}

#WideScreenOff
Yuzu_wideScreenOff() {
    echo "NYI"
}

#BezelOn
Yuzu_bezelOn() {
    echo "NYI"
}

#BezelOff
Yuzu_bezelOff() {
    echo "NYI"
}

#finalExec - Extra stuff
Yuzu_finalize() {
    echo "Begin Yuzu finalize"
    Yuzu_cleanup
}

Yuzu_IsInstalled() {
    if [ -e "$Yuzu_emuPath" ]; then
        echo "true"
    else
        echo "false"
    fi
}


Yuzu_resetConfig() {
    Yuzu_init &>/dev/null && echo "true" || echo "false"
}




### Yuzu EA

YuzuEA_install() {
    local jwtHost="https://api.yuzu-emu.org/jwt/installer/"
    local yuzuEaHost="https://api.yuzu-emu.org/downloads/earlyaccess/"
    local yuzuEaMetadata=$(curl -fSs ${yuzuEaHost})
    local fileToDownload=$(echo "$yuzuEaMetadata" | jq -r '.files[] | select(.name|test(".*.AppImage")).url')
    local currentVer=$(echo "$yuzuEaMetadata" | jq -r '.files[] | select(.name|test(".*.AppImage")).name')
    local tokenValue="$1"
    local showProgress="$2"
    local user
    local auth

    read -r user auth <<<"$(echo "$tokenValue"==== | fold -w 4 | sed '$ d' | tr -d '\n' | base64 --decode| awk -F":" '{print $1" "$2}')" || echo "invalid"

    #echo "get bearer token"
    BEARERTOKEN=$(curl -X POST ${jwtHost} -H "X-Username: ${user}" -H "X-Token: ${auth}" -H "User-Agent: EmuDeck")

    #echo "download ea appimage"

    if safeDownload "yuzu-ea" "$fileToDownload" "${YuzuEA_emuPath}" "$showProgress" "Authorization: Bearer ${BEARERTOKEN}"; then
        chmod +x "$YuzuEA_emuPath"

        cp -v "${EMUDECKGIT}/tools/launchers/yuzu.sh" "${toolsPath}/launchers/" &>/dev/null
        chmod +x "${toolsPath}/launchers/yuzu.sh"
        echo "true"
        return 0
    else
        echo "fail"
        return 1
    fi

}

YuzuEA_addToken(){
    local tokenValue=$1
    local user=""
    local auth=""

   read -r user auth <<<"$(echo "$tokenValue"==== | fold -w 4 | sed '$ d' | tr -d '\n' | base64 --decode| awk -F":" '{print $1" "$2}')" && YuzuEA_install "$tokenValue" || echo "invalid"
}


YuzuEA_IsInstalled() {
    if [ -e "$YuzuEA_emuPath" ]; then
        echo "true"
    else
        echo "false"
    fi
}


YuzuEA_uninstall() {
    echo "Begin Yuzu EA uninstall"
    rm -rf "$YuzuEA_emuPath"
}

Yuzu_setResolution(){

	case $yuzuResolution in
		"720P") multiplier=2; docked="false";;
		"1080P") multiplier=2; docked="true";;
		"1440P") multiplier=3; docked="false";;
		"4K") multiplier=3; docked="true";;
		*) echo "Error"; return 1;;
	esac

	RetroArch_setConfigOverride "resolution_setup" $multiplier "$Yuzu_configFile"
	RetroArch_setConfigOverride "use_docked_mode" $docked "$Yuzu_configFile"
}

Yuzu_flushEmulatorLauncher(){


	flushEmulatorLaunchers "yuzu"

}

Yuzu_addESConfig(){

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
		--insert '$newSystem/commandV' --type attr --name 'label' --value "Yuzu (Standalone)" \
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