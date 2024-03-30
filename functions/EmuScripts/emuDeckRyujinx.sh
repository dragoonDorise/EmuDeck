#!/bin/bash

#variables
Ryujinx_emuName="Ryujinx"
Ryujinx_emuType="$emuDeckEmuTypeBinary"
Ryujinx_emuPath="$HOME/Applications/publish"
Ryujinx_configFile="$HOME/.config/Ryujinx/Config.json"
# https://github.com/Ryujinx/Ryujinx/blob/master/Ryujinx.Ui.Common/Configuration/System/Language.cs#L3-L23
Ryujinx_controllerFile="$HOME/.config/Ryujinx/profiles/controller/Deck.json"

declare -A Ryujinx_languages
Ryujinx_languages=(
["ja"]="Japanese"
["en"]="AmericanEnglish"
["fr"]="French"
["de"]="German"
["it"]="Italian"
["es"]="Spanish"
["zh"]="Chinese"
["ko"]="Korean"
["nl"]="Dutch"
["pt"]="Portuguese"
["ru"]="Russian"
["tw"]="Taiwanese") # TODO: not all langs but we need to switch to full lang codes to support those

# https://github.com/Ryujinx/Ryujinx/blob/master/Ryujinx.Ui.Common/Configuration/System/Region.cs#L3-L12
declare -A Ryujinx_regions
Ryujinx_regions=(
["ja"]="Japan"
["en"]="USA"
["fr"]="Europe"
["de"]="Europe"
["it"]="Europe"
["es"]="Europe"
["zh"]="China"
["ko"]="Korea"
["nl"]="Europe"
["pt"]="Europe"
["ru"]="Europe"
["tw"]="Taiwan") # TODO: split lang from region?


#cleanupOlderThings
Ryujinx_cleanup(){
    echo "Begin Ryujinx Cleanup"
}

#Install
Ryujinx_install(){
    echo "Begin Ryujinx Install"
    local showProgress=$1
    if installEmuBI "$Ryujinx_emuName" "$(getReleaseURLGH "Ryujinx/release-channel-master" "-linux_x64.tar.gz")" "" "tar.gz" "$showProgress"; then
        tar -xvf "$HOME/Applications/Ryujinx.tar.gz" -C "$HOME/Applications/" && rm -rf "$HOME/Applications/Ryujinx.tar.gz"
        chmod +x "$HOME/Applications/publish/Ryujinx"
    else
        return 1
    fi
}

#ApplyInitialSettings
Ryujinx_init(){
    echo "Begin Ryujinx Init"

    configEmuAI "Ryujinx" "config" "$HOME/.config/Ryujinx" "$EMUDECKGIT/configs/Ryujinx" "true"

    Ryujinx_setEmulationFolder
    Ryujinx_setupStorage
    Ryujinx_setupSaves
    Ryujinx_finalize
	#SRM_createParsers
    Ryujinx_flushEmulatorLauncher

	if [ -e "$ESDE_toolPath" ]; then
		Yuzu_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi

}

#update
Ryujinx_update(){
    echo "Begin Ryujinx update"

    configEmuAI "yuzu" "config" "$HOME/.config/Ryujinx" "$EMUDECKGIT/configs/Ryujinx"

    Ryujinx_setEmulationFolder
    Ryujinx_setupStorage
    Ryujinx_setupSaves
    Ryujinx_finalize
    Ryujinx_flushEmulatorLauncher

	if [ -e "$ESDE_toolPath" ]; then
		Yuzu_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi
}

#ConfigurePaths
Ryujinx_setEmulationFolder(){
    echo "Begin Ryujinx Path Config"
#     configFile="$HOME/.config/yuzu/qt-config.ini"
#     screenshotDirOpt='Screenshots\\screenshot_path='
#     gameDirOpt='Paths\\gamedirs\\4\\path='
#     dumpDirOpt='dump_directory='
#     loadDir='load_directory='
#     nandDirOpt='nand_directory='
#     sdmcDirOpt='sdmc_directory='
#     tasDirOpt='tas_directory='
#     newScreenshotDirOpt='Screenshots\\screenshot_path='"${storagePath}/yuzu/screenshots"
#     newGameDirOpt='Paths\\gamedirs\\4\\path='"${romsPath}/switch"
#     newDumpDirOpt='dump_directory='"${storagePath}/yuzu/dump"
#     newLoadDir='load_directory='"${storagePath}/yuzu/load"
#     newNandDirOpt='nand_directory='"${storagePath}/yuzu/nand"
#     newSdmcDirOpt='sdmc_directory='"${storagePath}/yuzu/sdmc"
#     newTasDirOpt='tas_directory='"${storagePath}/yuzu/tas"
#
#     sed -i "/${screenshotDirOpt}/c\\${newScreenshotDirOpt}" "$configFile"
#     sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
#     sed -i "/${dumpDirOpt}/c\\${newDumpDirOpt}" "$configFile"
#     sed -i "/${loadDir}/c\\${newLoadDir}" "$configFile"
#     sed -i "/${nandDirOpt}/c\\${newNandDirOpt}" "$configFile"
#     sed -i "/${sdmcDirOpt}/c\\${newSdmcDirOpt}" "$configFile"
#     sed -i "/${tasDirOpt}/c\\${newTasDirOpt}" "$configFile"

    #Setup Bios symlinks
    unlink "${biosPath}/ryujinx/keys"
    mkdir -p "$HOME/.config/Ryujinx/system/"
    mkdir -p "${biosPath}/ryujinx/"
    unlink "$HOME/.config/Ryujinx/system"
    ln -sn "$HOME/.config/Ryujinx/system" "${biosPath}/ryujinx/keys"
    sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|g" "$Ryujinx_configFile"

}

#SetLanguage
Ryujinx_setLanguage(){
    setMSG "Setting Ryujinx Language"

	#TODO: call this somewhere, and input the $language from somewhere (args?)
	if [[ -f "${Ryujinx_configFile}" ]]; then
		if [ ${Ryujinx_languages[$language]+_} ]; then
            # we cant edit inplace, so we save it into a tmp var
            tmp=$(jq ".system_language=\"${Ryujinx_languages[$language]}\"" "$Ryujinx_configFile")
            echo "$tmp" > "$Ryujinx_configFile"
            tmp=$(jq ".system_region=\"${Ryujinx_regions[$language]}\"" "$Ryujinx_configFile")
            echo "$tmp" > "$Ryujinx_configFile"
		fi
	fi
}

#SetupSaves
Ryujinx_setupSaves(){
    echo "Begin Ryujinx save link"

    if [ -d "${emulationPath}/saves/ryujinx/saves" ]; then
        rm -rf "${emulationPath}/saves/ryujinx/saves"
        rm -rf "${emulationPath}/saves/ryujinx/saveMeta"
    fi

    linkToSaveFolder Ryujinx saves "$HOME/.config/Ryujinx/bis/user/save"
    linkToSaveFolder Ryujinx saveMeta "$HOME/.config/Ryujinx/bis/user/saveMeta"
	linkToSaveFolder Ryujinx system_saves "$HOME/.config/Ryujinx/bis/system/save"

}

#SetupStorage
Ryujinx_setupStorage(){
    echo "Begin Ryujinx storage config"

    local origPath="$HOME/.config/"
    mkdir -p "${storagePath}/ryujinx/patchesAndDlc"
    rsync -av "${origPath}/Ryujinx/games/" "${storagePath}/ryujinx/games/" && rm -rf "${origPath}Ryujinx/games"
    unlink "${origPath}/Ryujinx/games"
    ln -ns "${storagePath}/ryujinx/games/" "${origPath}/Ryujinx/games"
}

#WipeSettings
Ryujinx_wipe(){
    echo "Begin Ryujinx delete config directories"
    rm -rf "$HOME/.config/Ryujinx"
}

#Uninstall
Ryujinx_uninstall(){
    echo "Begin Ryujinx uninstall"
    rm -rf "$Ryujinx_emuPath"
}

#Migrate
Ryujinx_migrate(){
    echo "Begin Ryujinx Migration"
    emu="Ryujinx"
#     migrationFlag="$HOME/.config/EmuDeck/.${emu}MigrationCompleted"
#     #check if we have a nomigrateflag for $emu
#     if [ ! -f "$migrationFlag" ]; then
#         #yuzu flatpak to appimage
#         #From -- > to
#         migrationTable=()
#         migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu" "$HOME/.local/share/yuzu")
#         migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/config/yuzu" "$HOME/.config/yuzu")
#
#         migrateAndLinkConfig "$emu" "$migrationTable"
#     fi

    #move data from hidden folders out to these folders in case the user already put stuff here.
    local origPath="$HOME/.config"

    Ryujinx_setupStorage
    rsync -av "${origPath}/Ryujinx/games" "${storagePath}/ryujinx/games" && rm -rf "${origPath}/Ryujinx/games"
    ln -s "${storagePath}/ryujinx/games" "${origPath}/ryujinx/games"  #may want to unlink this before hand?
}

Ryujinx_convertFromYuzu(){
    echo "Begin converting firmware from Yuzu"
    for entry in "$biosPath"/yuzu/firmware/*.nca
    do
        folder=${entry##*/}
        mkdir -p "$HOME/.config/Ryujinx/bis/system/Contents/registered/$folder/"
        cp "$entry" "$HOME/.config/Ryujinx/bis/system/Contents/registered/$folder/00"
    done
}

#setABXYstyle
Ryujinx_setABXYstyle(){
    sed -i 's/"button_x": "Y",/"button_x": "X",/' $Ryujinx_configFile
    sed -i 's/"button_b": "A",/"button_b": "B",/' $Ryujinx_configFile
    sed -i 's/"button_y": "X",/"button_y": "Y",/' $Ryujinx_configFile
    sed -i 's/"button_a": "B"/"button_a": "A"/' $Ryujinx_configFile

}
Ryujinx_setBAYXstyle(){
    sed -i 's/"button_x": "X",/"button_x": "Y",/' $Ryujinx_configFile
    sed -i 's/"button_b": "B",/"button_b": "A",/' $Ryujinx_configFile
    sed -i 's/"button_y": "Y",/"button_y": "X",/' $Ryujinx_configFile
    sed -i 's/"button_a": "A"/"button_a": "B"/' $Ryujinx_configFile
}


#WideScreenOn
Ryujinx_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
Ryujinx_wideScreenOff(){
echo "NYI"
}

#BezelOn
Ryujinx_bezelOn(){
echo "NYI"
}

#BezelOff
Ryujinx_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Ryujinx_finalize(){
    echo "Begin Ryujinx finalize"
}

Ryujinx_IsInstalled(){
    if [ -e "$Ryujinx_emuPath/Ryujinx" ]; then
        echo "true"
    else
        echo "false"
    fi
}

Ryujinx_resetConfig(){
    Ryujinx_init &>/dev/null && echo "true" || echo "false"
}

Ryujinx_setResolution(){

	case $ryujinxResolution in
		"720P") multiplier=1; docked="false";;
		"1080P") multiplier=1; docked="true";;
		"1440P") multiplier=2; docked="false";;
		"4K") multiplier=2; docked="true";;
		*) echo "Error"; return 1;;
	esac

	jq --arg docked "$docked" --arg multiplier "$multiplier" \
	  '.docked_mode = $docked | .res_scale = $multiplier' "$Ryujinx_configFile" > tmp.json

	mv tmp.json "$Ryujinx_configFile"

}

Ryujinx_flushEmulatorLauncher(){


	flushEmulatorLaunchers "ryujinx"

}