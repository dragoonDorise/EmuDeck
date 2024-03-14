#!/bin/bash

#variables
Suyu_emuName="suyu"
Suyu_emuType="$emuDeckEmuTypeAppImage"
Suyu_emuPath="$HOME/Applications/suyu.AppImage"

Suyu_configFile="$HOME/.config/suyu/qt-config.ini"

declare -A Suyu_languages
Suyu_languages=(
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

# https://github.com/suyu-emu/suyu/blob/master/src/suyu/configuration/configure_system.ui#L272-L309
declare -A Suyu_regions
Suyu_regions=(
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


#Install
Suyu_install() {
    echo "Begin Suyu Install"

    local showProgress=$1
    local lastVerFile="$HOME/emudeck/suyu.ver"
    local latestVer=$(curl -fSs "https://api.github.com/repos/suyu-emu/suyu-mainline/releases" | jq -r '[ .[].tag_name ][0]')
    local success="false"
    if installEmuAI "$Suyu_emuName" "$(getReleaseURLGH "suyu-emu/suyu-mainline" "AppImage")" "" "$showProgress" "$lastVerFile" "$latestVer"; then # suyu.AppImage - needs to be lowercase suyu for EsDE to find it
        success="true"
    fi

    if [ "$success" != "true" ]; then
        return 1
    fi
}

#ApplyInitialSettings
Suyu_init() {
    echo "Begin Suyu Init"

	cp "$EMUDECKGIT/tools/launchers/suyu.sh" "$toolsPath/launchers/suyu.sh"
	chmod +x "$toolsPath/launchers/suyu.sh"
    mkdir -p "$HOME/.config/suyu"
    mkdir -p "$HOME/.local/share/suyu"
	rsync -avhp "$EMUDECKGIT/configs/org.suyu_emu.suyu/config/suyu/." "$HOME/.config/suyu"
	rsync -avhp "$EMUDECKGIT/configs/org.suyu_emu.suyu/data/suyu/." "$HOME/.local/share/suyu"
    Suyu_migrate
    configEmuAI "$Suyu_emuName" "config" "$HOME/.config/suyu" "$EMUDECKGIT/configs/org.suyu_emu.suyu/config/suyu" "true"
    configEmuAI "$Suyu_emuName" "data" "$HOME/.local/share/suyu" "$EMUDECKGIT/configs/org.suyu_emu.suyu/data/suyu" "true"

    Suyu_setEmulationFolder
    Suyu_setupStorage
    Suyu_setupSaves
    Suyu_finalize
    #SRM_createParsers
    Suyu_flushEmulatorLauncher
  	createDesktopShortcut   "$HOME/.local/share/applications/suyu.desktop" \
							"suyu (AppImage)" \
							"${toolsPath}/launchers/suyu.sh"  \
							"False"

	if [ -e "$ESDE_toolPath" ]; then
		Suyu_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi


}

#update
Suyu_update() {
    echo "Begin Suyu update"

    Suyu_migrate

    configEmuAI "$Suyu_emuName" "config" "$HOME/.config/suyu" "$EMUDECKGIT/configs/org.suyu_emu.suyu/config/suyu"
    configEmuAI "$Suyu_emuName" "data" "$HOME/.local/share/suyu" "$EMUDECKGIT/configs/org.suyu_emu.suyu/data/suyu"

    Suyu_setEmulationFolder
    Suyu_setupStorage
    Suyu_setupSaves
    Suyu_finalize
    Suyu_flushEmulatorLauncher
}

#ConfigurePaths
Suyu_setEmulationFolder() {
    echo "Begin Suyu Path Config"

    screenshotDirOpt='Screenshots\\screenshot_path='
    gameDirOpt='Paths\\gamedirs\\4\\path='
    dumpDirOpt='dump_directory='
    loadDir='load_directory='
    nandDirOpt='nand_directory='
    sdmcDirOpt='sdmc_directory='
    tasDirOpt='tas_directory='
    newScreenshotDirOpt='Screenshots\\screenshot_path='"${storagePath}/suyu/screenshots"
    newGameDirOpt='Paths\\gamedirs\\4\\path='"${romsPath}/switch"
    newDumpDirOpt='dump_directory='"${storagePath}/suyu/dump"
    newLoadDir='load_directory='"${storagePath}/suyu/load"
    newNandDirOpt='nand_directory='"${storagePath}/suyu/nand"
    newSdmcDirOpt='sdmc_directory='"${storagePath}/suyu/sdmc"
    newTasDirOpt='tas_directory='"${storagePath}/suyu/tas"

    sed -i "/${screenshotDirOpt}/c\\${newScreenshotDirOpt}" "$Suyu_configFile"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$Suyu_configFile"
    sed -i "/${dumpDirOpt}/c\\${newDumpDirOpt}" "$Suyu_configFile"
    sed -i "/${loadDir}/c\\${newLoadDir}" "$Suyu_configFile"
    sed -i "/${nandDirOpt}/c\\${newNandDirOpt}" "$Suyu_configFile"
    sed -i "/${sdmcDirOpt}/c\\${newSdmcDirOpt}" "$Suyu_configFile"
    sed -i "/${tasDirOpt}/c\\${newTasDirOpt}" "$Suyu_configFile"

    #Setup Bios symlinks
    unlink "${biosPath}/suyu/keys" 2>/dev/null
    unlink "${biosPath}/suyu/firmware" 2>/dev/null

    mkdir -p "$HOME/.local/share/suyu/keys/"
    mkdir -p "${storagePath}/suyu/nand/system/Contents/registered/"

    ln -sn "$HOME/.local/share/suyu/keys/" "${biosPath}/suyu/keys"
    ln -sn "${storagePath}/suyu/nand/system/Contents/registered/" "${biosPath}/suyu/firmware"

    touch "${storagePath}/suyu/nand/system/Contents/registered/putfirmwarehere.txt"

}

#SetLanguage
Suyu_setLanguage(){
    setMSG "Setting Suyu Language"

    languageOpt="language_index="
    languageDefaultOpt="language_index\\\\default="
    newLanguageDefaultOpt="language_index\\\\default=false" # we need those or else itll reset
    regionOpt="region_index="
    regionDefaultOpt="region_index\\\\default="
    newRegionDefaultOpt="region_index\\\\default=false"
	#TODO: call this somewhere, and input the $language from somewhere (args?)
	if [[ -f "${Suyu_configFile}" ]]; then
		if [ ${Suyu_languages[$language]+_} ]; then
            newLanguageOpt='language_index='"${Suyu_languages[$language]}"
            newRegionOpt='region_index='"${Suyu_regions[$language]}"
            changeLine "$languageOpt" "$newLanguageOpt" "$Suyu_configFile"
            changeLine "$languageDefaultOpt" "$newLanguageDefaultOpt" "$Suyu_configFile"
            changeLine "$regionOpt" "$newRegionOpt" "$Suyu_configFile"
            changeLine "$regionDefaultOpt" "$newRegionDefaultOpt" "$Suyu_configFile"
		fi
	fi
}

#SetupSaves
Suyu_setupSaves() {
    echo "Begin Suyu save link"
    unlink "${savesPath}/suyu/saves" 2>/dev/null # Fix for previous bad symlink2>/dev/null
    linkToSaveFolder suyu saves "${storagePath}/suyu/nand/user/save/"
    linkToSaveFolder suyu profiles "${storagePath}/suyu/nand/system/save/8000000000000010/su/avators/"
}

#SetupStorage
Suyu_setupStorage() {
    echo "Begin Suyu storage config"
    mkdir -p "${storagePath}/suyu/dump"
    mkdir -p "${storagePath}/suyu/load"
    mkdir -p "${storagePath}/suyu/sdmc"
    mkdir -p "${storagePath}/suyu/nand"
    mkdir -p "${storagePath}/suyu/screenshots"
    mkdir -p "${storagePath}/suyu/tas"
    #Symlink to saves for CloudSync
    ln -sn "${storagePath}/suyu/nand/system/save/8000000000000010/su/avators/" "${savesPath}/suyu/profiles"
}

#WipeSettings
Suyu_wipe() {
    echo "Begin Suyu delete config directories"
    rm -rf "$HOME/.config/suyu"
    rm -rf "$HOME/.local/share/suyu"
}

#Uninstall
Suyu_uninstall() {
    echo "Begin Suyu uninstall"
    rm -rf "$Suyu_emuPath"
    SuyuEA_uninstall
}


#Migrate
Suyu_migrate() {
    echo "Begin Suyu Migration"
    migrationFlag="$HOME/.config/EmuDeck/.${Suyu_emuName}MigrationCompleted"
    #check if we have a nomigrateflag for $emu
    if [ ! -f "$migrationFlag" ]; then
        #suyu flatpak to appimage
        #From -- > to
        migrationTable=()
        migrationTable+=("$HOME/.var/app/org.suyu_emu.suyu/data/suyu" "$HOME/.local/share/suyu")
        migrationTable+=("$HOME/.var/app/org.suyu_emu.suyu/config/suyu" "$HOME/.config/suyu")

        # migrateAndLinkConfig "$emu" "$migrationTable"
        touch "${migrationFlag}"
    fi

    #move data from hidden folders out to these folders in case the user already put stuff here.
    origPath="$HOME/.local/share/"

    Suyu_setupStorage

    rsync -av "${origPath}suyu/dump" "${storagePath}/suyu/" && rm -rf "${origPath}suyu/dump"
    rsync -av "${origPath}suyu/load" "${storagePath}/suyu/" && rm -rf "${origPath}suyu/load"
    rsync -av "${origPath}suyu/sdmc" "${storagePath}/suyu/" && rm -rf "${origPath}suyu/sdmc"
    rsync -av "${origPath}suyu/nand" "${storagePath}/suyu/" && rm -rf "${origPath}suyu/nand"
    rsync -av "${origPath}suyu/screenshots" "${storagePath}/suyu/" && rm -rf "${origPath}suyu/screenshots"
    rsync -av "${origPath}suyu/tas" "${storagePath}/suyu/" && rm -rf "${origPath}suyu/tas"
}

#setABXYstyle
Suyu_setABXYstyle() {
    echo "NYI"
}

#WideScreenOn
Suyu_wideScreenOn() {
    echo "NYI"
}

#WideScreenOff
Suyu_wideScreenOff() {
    echo "NYI"
}

#BezelOn
Suyu_bezelOn() {
    echo "NYI"
}

#BezelOff
Suyu_bezelOff() {
    echo "NYI"
}

#finalExec - Extra stuff
Suyu_finalize() {
    echo "Begin Suyu finalize"
}

Suyu_IsInstalled() {
    if [ -e "$Suyu_emuPath" ]; then
        echo "true"
    else
        echo "false"
    fi
}


Suyu_resetConfig() {
    Suyu_init &>/dev/null && echo "true" || echo "false"
}




### Suyu EA

SuyuEA_install() {
    local jwtHost="https://api.suyu-emu.org/jwt/installer/"
    local suyuEaHost="https://api.suyu-emu.org/downloads/earlyaccess/"
    local suyuEaMetadata=$(curl -fSs ${suyuEaHost})
    local fileToDownload=$(echo "$suyuEaMetadata" | jq -r '.files[] | select(.name|test(".*.AppImage")).url')
    local currentVer=$(echo "$suyuEaMetadata" | jq -r '.files[] | select(.name|test(".*.AppImage")).name')
    local tokenValue="$1"
    local showProgress="$2"
    local user
    local auth

    read -r user auth <<<"$(echo "$tokenValue"==== | fold -w 4 | sed '$ d' | tr -d '\n' | base64 --decode| awk -F":" '{print $1" "$2}')" || echo "invalid"

    #echo "get bearer token"
    BEARERTOKEN=$(curl -X POST ${jwtHost} -H "X-Username: ${user}" -H "X-Token: ${auth}" -H "User-Agent: EmuDeck")

    #echo "download ea appimage"

    if safeDownload "suyu-ea" "$fileToDownload" "${SuyuEA_emuPath}" "$showProgress" "Authorization: Bearer ${BEARERTOKEN}"; then
        chmod +x "$SuyuEA_emuPath"

        cp -v "${EMUDECKGIT}/tools/launchers/suyu.sh" "${toolsPath}/launchers/" &>/dev/null
        chmod +x "${toolsPath}/launchers/suyu.sh"
        echo "true"
        return 0
    else
        echo "fail"
        return 1
    fi

}

SuyuEA_addToken(){
    local tokenValue=$1
    local user=""
    local auth=""

   read -r user auth <<<"$(echo "$tokenValue"==== | fold -w 4 | sed '$ d' | tr -d '\n' | base64 --decode| awk -F":" '{print $1" "$2}')" && SuyuEA_install "$tokenValue" || echo "invalid"
}


SuyuEA_IsInstalled() {
    if [ -e "$SuyuEA_emuPath" ]; then
        echo "true"
    else
        echo "false"
    fi
}


SuyuEA_uninstall() {
    echo "Begin Suyu EA uninstall"
    rm -rf "$SuyuEA_emuPath"
}

Suyu_setResolution(){

	case $suyuResolution in
		"720P") multiplier=2; docked="false";;
		"1080P") multiplier=2; docked="true";;
		"1440P") multiplier=3; docked="false";;
		"4K") multiplier=3; docked="true";;
		*) echo "Error"; return 1;;
	esac

	RetroArch_setConfigOverride "resolution_setup" $multiplier "$Suyu_configFile"
	RetroArch_setConfigOverride "use_docked_mode" $docked "$Suyu_configFile"
}

Suyu_flushEmulatorLauncher(){


	flushEmulatorLaunchers "suyu"

}

Suyu_addESConfig(){
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
		--insert '$newSystem/commandV' --type attr --name 'label' --value "Suyu (Standalone)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'switch' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'switch' \
		-r 'systemList/system/commandB' -v 'command' \
		-r 'systemList/system/commandV' -v 'command' \
		"$es_systemsFile"



		xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
	fi
	#Custom Systems config end
}