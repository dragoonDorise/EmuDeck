#!/bin/bash

# Script to install, initialize and configure ShadPS4 on EmuDeck
# Note: No Bios/Keys symlinks necessary
# Variables

ShadPS4_emuName="ShadPS4"
ShadPS4_emuFileName="Shadps4-qt"
ShadPS4_emuType="$emuDeckEmuTypeAppImage"
ShadPS4_emuPath="$emusFolder"
ShadPS4_dir="$HOME/.local/share/shadPS4"
ShadPS4_configFile="$ShadPS4_dir/config.toml"

ShadPS4_cleanup(){
    echo "Begin ShadPS4 Cleanup"
}

# TODO: Install Flatpak from https://github.com/shadps4-emu/shadPS4-flatpak
ShadPS4_install(){
    echo "Begin ShadPS4 Install"
    local showProgress=$1

    if safeDownload "$ShadPS4_emuName" "$(getReleaseURLGH "shadps4-emu/shadPS4" "zip" "linux-qt")" "$emusFolder/${ShadPS4_emuName}.zip" "$showProgress"; then
        unzip -o "$emusFolder/${ShadPS4_emuName}.zip" -d "$ShadPS4_emuPath" && rm -f "$emusFolder/${ShadPS4_emuName}.zip"
        if ! installEmuAI "$ShadPS4_emuName" "" "" "$ShadPS4_emuFileName" "" "emulator"; then # installEmuAI will handle everything when URL is not provided but AppImage exists...
            echo "Error installing ShadPS4"
            return 1
        fi
    else
        echo "Error installing ShadPS4"
        return 1
    fi
}

ShadPS4_init(){
    configEmuAI "$ShadPS4_emuName" "config" "$HOME/.local/share/shadPS4" "$emudeckBackend/configs/shadps4" "true"
    ShadPS4_setupStorage
    ShadPS4_setEmulationFolder
    ShadPS4_setupSaves
    ShadPS4_flushEmulatorLauncher
    ShadPS4_setLanguage
}

ShadPS4_update(){
    ShadPS4_init
}

# Configuration Paths
ShadPS4_setEmulationFolder(){
    echo "Begin ShadPS4 Path Config"
    sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" "$ShadPS4_configFile"

    # setup bios link for LLE sys_modules (optional)
    mkdir -p "${biosPath}/shadps4/"
    mkdir -p "$ShadPS4_dir/sys_modules"
    ln -sn "$ShadPS4_dir/sys_modules" "${biosPath}/shadps4/sys_modules"

    echo "ShadPS4 Path Config Completed"
}

ShadPS4_setLanguage(){
    setMSG "Setting ShadPS4 Language"
    local language=$(locale | grep LANG | cut -d= -f2 | cut -d_ -f1)
    #TODO: call this somewhere, and input the $language from somewhere (args?)
    changeLine "emulatorLanguage = " "emulatorLanguage = \"${language}\"" $ShadPS4_configFile
    echo "ShadPS4 language '${emulatorLanguage}' configuration completed."
}

# Setup Saves
ShadPS4_setupSaves(){
    echo "Begin ShadPS4 save link"
    # Create symbolic links
    linkToSaveFolder shadps4 saves "${ShadPS4_dir}/savedata"
    echo "ShadPS4 save link completed"
}

#SetupStorage
ShadPS4_setupStorage(){
    echo "Begin ShadPS4 storage config"
    mkdir -p "$storagePath/shadps4/games"
    mkdir -p "$storagePath/shadps4/dlc"
}

#WipeSettings
ShadPS4_wipe(){
    echo "Begin ShadPS4 delete config directories"
    rm -rf "$ShadPS4_dir"
}

#Uninstall
ShadPS4_uninstall(){
    echo "Begin ShadPS4 uninstall"
    uninstallEmuAI $ShadPS4_emuName "Shadps4-qt" "AppImage" "emulator"
}

#WideScreenOn
ShadPS4_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
ShadPS4_wideScreenOff(){
echo "NYI"
}

#BezelOn
ShadPS4_bezelOn(){
echo "NYI"
}

#BezelOff
ShadPS4_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
ShadPS4_finalize(){
    echo "Begin ShadPS4 finalize"
}

ShadPS4_IsInstalled(){
    if [ -e "$ShadPS4_emuPath/Shadps4-qt.AppImage" ]; then
        echo "true"
    else
        echo "false"
    fi
}

ShadPS4_resetConfig(){
    ShadPS4_init &>/dev/null && echo "true" || echo "false"
}

ShadPS4_setResolution(){
    echo "NYI"
}

ShadPS4_flushEmulatorLauncher(){
    flushEmulatorLaunchers "ShadPS4"
}
