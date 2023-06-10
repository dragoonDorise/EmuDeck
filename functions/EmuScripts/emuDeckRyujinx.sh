#!/bin/bash

#variables
Ryujinx_emuName="Ryujinx"
Ryujinx_emuType="Binary"
Ryujinx_emuPath="$HOME/Applications/publish"

#cleanupOlderThings
Ryujinx_cleanup(){
    echo "Begin Ryujinx Cleanup"
}

#Install
Ryujinx_install(){
    echo "Begin Ryujinx Install"
    local showProgress=$1
    if installEmuBI "Ryujinx" "$(getReleaseURLGH "Ryujinx/release-channel-master" "-linux_x64.tar.gz")" "Ryujinx" "tar.gz" "$showProgress"; then
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
}

#update
Ryujinx_update(){
    echo "Begin Ryujinx update"

    configEmuAI "yuzu" "config" "$HOME/.config/Ryujinx" "$EMUDECKGIT/configs/Ryujinx"

    Ryujinx_setEmulationFolder
    Ryujinx_setupStorage
    Ryujinx_setupSaves
    Ryujinx_finalize
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

    sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|g" "$HOME/.config/Ryujinx/Config.json"
}

#SetupSaves
Ryujinx_setupSaves(){
    echo "Begin Ryujinx save link"
    
    if [ -d "${emulationPath}/saves/ryujinx/saves" ]; then
        rm -rf "${emulationPath}/saves/ryujinx/saves"
        rm -rf "${emulationPath}/saves/ryujinx/saveMeta"
    fi
    
    ln -sn "$HOME/.config/Ryujinx/bis/user/save" "${emulationPath}/saves/ryujinx/saves"
    ln -sn "$HOME/.config/Ryujinx/bis/user/saveMeta" "${emulationPath}/saves/ryujinx/saveMeta"

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
echo "NYI"
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