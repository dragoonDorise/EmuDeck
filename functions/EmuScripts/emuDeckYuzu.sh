#!/bin/bash

#variables
Yuzu_emuName="Yuzu"
Yuzu_emuType="AppImage"
Yuzu_emuPath="$HOME/Applications/yuzu.AppImage"
Yuzu_configFile="$HOME/.config/yuzu/qt-config.ini"

# https://github.com/yuzu-emu/yuzu/blob/master/src/core/file_sys/control_metadata.cpp#L41-L60
declare -A Yuzu_languages=(
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
declare -A Yuzu_regions=(
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
["tw"]=6 # Taiwan) # TODO: split lang from region?

#cleanupOlderThings
Yuzu_cleanup(){
    echo "Begin Yuzu Cleanup"
    #Fixes repeated Symlink for older installations
    unlink "$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu/keys/keys"
    unlink "$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu/nand/system/Contents/registered/registered"
    
}

#Install
Yuzu_install(){
    echo "Begin Yuzu Install"
    installEmuAI "yuzu"  "$(getReleaseURLGH "yuzu-emu/yuzu-mainline" "AppImage")" #needs to be lowercase yuzu for EsDE to find it.
    flatpak override org.yuzu_emu.yuzu --filesystem=host --user # still doing this, as we do link the appimage / flatpak config. if the user ever decides to install the flatpak, we do want it to work.
}

#ApplyInitialSettings
Yuzu_init(){
    echo "Begin Yuzu Init"
    
    Yuzu_migrate
    
    configEmuAI "yuzu" "config" "$HOME/.config/yuzu" "$EMUDECKGIT/configs/org.yuzu_emu.yuzu/config/yuzu" "true"
    configEmuAI "yuzu" "data" "$HOME/.local/share/yuzu" "$EMUDECKGIT/configs/org.yuzu_emu.yuzu/data/yuzu" "true"
    
    Yuzu_setEmulationFolder
    Yuzu_setupStorage
    Yuzu_setupSaves
    Yuzu_finalize

}

#update
Yuzu_update(){
    echo "Begin Yuzu update"

    Yuzu_migrate
    
    configEmuAI "yuzu" "config" "$HOME/.config/yuzu" "$EMUDECKGIT/configs/org.yuzu_emu.yuzu/config/yuzu"
    configEmuAI "yuzu" "data" "$HOME/.local/share/yuzu" "$EMUDECKGIT/configs/org.yuzu_emu.yuzu/data/yuzu"
    
    Yuzu_setEmulationFolder
    Yuzu_setupStorage
    Yuzu_setupSaves
    Yuzu_finalize
}



#ConfigurePaths
Yuzu_setEmulationFolder(){
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
            sed -i "/${languageOpt}/c\\${newLanguageOpt}" "$Yuzu_configFile"
            sed -i "/${languageDefaultOpt}/c\\${newLanguageDefaultOpt}" "$Yuzu_configFile"
            sed -i "/${regionOpt}/c\\${newRegionOpt}" "$Yuzu_configFile"
            sed -i "/${regionDefaultOpt}/c\\${newRegionDefaultOpt}" "$Yuzu_configFile"
		fi
	fi
}

#SetupSaves
Yuzu_setupSaves(){
    echo "Begin Yuzu save link"
    unlink "${savesPath}/yuzu/saves" 2>/dev/null # Fix for previous bad symlink2>/dev/null
    linkToSaveFolder yuzu saves "${storagePath}/yuzu/nand/user/save/"
}


#SetupStorage
Yuzu_setupStorage(){
    echo "Begin Yuzu storage config"
    mkdir -p "${storagePath}/yuzu/dump"
    mkdir -p "${storagePath}/yuzu/load"
    mkdir -p "${storagePath}/yuzu/sdmc"
    mkdir -p "${storagePath}/yuzu/nand"
    mkdir -p "${storagePath}/yuzu/screenshots"
    mkdir -p "${storagePath}/yuzu/tas"
}


#WipeSettings
Yuzu_wipe(){
    echo "Begin Yuzu delete config directories"
    rm -rf "$HOME/.config/yuzu"
    rm -rf "$HOME/.local/share/yuzu"
}


#Uninstall
Yuzu_uninstall(){
    echo "Begin Yuzu uninstall"
    rm -rf "$Yuzu_emuPath"
}


#Migrate
Yuzu_migrate(){
    echo "Begin Yuzu Migration"
    emu="Yuzu"
    migrationFlag="$HOME/.config/EmuDeck/.${emu}MigrationCompleted"
    #check if we have a nomigrateflag for $emu
    if [ ! -f "$migrationFlag" ]; then	
        #yuzu flatpak to appimage
        #From -- > to
        migrationTable=()
        migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu" "$HOME/.local/share/yuzu")
        migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/config/yuzu" "$HOME/.config/yuzu")

      # migrateAndLinkConfig "$emu" "$migrationTable"
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
Yuzu_setABXYstyle(){
echo "NYI"
}

#WideScreenOn
Yuzu_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
Yuzu_wideScreenOff(){
echo "NYI"
}

#BezelOn
Yuzu_bezelOn(){
echo "NYI"
}

#BezelOff
Yuzu_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Yuzu_finalize(){
    echo "Begin Yuzu finalize"
    Yuzu_cleanup
}

Yuzu_IsInstalled(){
	if [ -e "$Yuzu_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

Yuzu_resetConfig(){
	Yuzu_init &>/dev/null && echo "true" || echo "false"
}