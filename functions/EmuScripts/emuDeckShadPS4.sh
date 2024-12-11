#!/bin/bash

# Script to install, initialize and configure ShadPS4 on EmuDeck

# External helper functions (defined outside this script)
#- installEmuBI()
#- getReleaseURLGH()
#- configEmuAI()
#- linkToSaveFolder()
#- uninstallGeneric()
#- migrateAndLinkConfig()
#- flushEmulatorLaunchers()
#- setMSG()

#variables
ShadPS4_emuName="ShadPS4"
ShadPS4_emuType="$emuDeckEmuTypeBinary"
ShadPS4_emuPath="$HOME/Applications/publish"
ShadPS4_configFile="$HOME/.config/shadps4/Config.json"
ShadPS4_controllerFile="$HOME/.config/shadps4/profiles/controller/Deck.json"

ShadPS4_migrationFlag="$HOME/.config/EmuDeck/.${ShadPS4_emuName}MigrationCompleted"

declare -A ShadPS4_languages

# Too early for languages support
ShadPS4_languages=(["en"]="AmericanEnglish")

declare -A ShadPS4_regions
ShadPS4_regions=(["en"]="USA")

ShadPS4_cleanup(){
    echo "Begin ShadPS4 Cleanup"
}

# TODO: Install Flatpak from https://github.com/shadps4-emu/shadPS4-flatpak
ShadPS4_install(){
    echo "Begin ShadPS4 Install"
    local showProgress=$1

    if installEmuBI "$ShadPS4_emuName" "$(getReleaseURLGH "GreemDev/shadps4" "-linux_x64.tar.gz")" "" "tar.gz" "$showProgress"; then
        mkdir -p "$HOME/Applications/publish"
        tar -xvf "$HOME/Applications/shadps4.tar.gz" -C "$HOME/Applications" && rm -rf "$HOME/Applications/shadps4.tar.gz"
        chmod +x "$HOME/Applications/publish/shadps4"
    else
        return 1
    fi

    # Flatpak install
    echo "Installing ShadPS4 via Flatpak..."
    flatpak install flathub net.shadps4.shadPS4 -y --user

    # Move Flatpak installed files to the desired location
    mkdir -p "$HOME/Applications/publish"
    rsync -av "$HOME/.local/share/flatpak/app/net.shadps4.shadPS4/x86_64/stable/active/files/bin/" "$HOME/Applications/publish/" && flatpak uninstall flathub net.shadps4.shadPS4 -y --user

    # Clean up old games directory if it exists
    rm -rf "$HOME/.config/shadps4/games"

    # Set executable permission
    chmod +x "$HOME/Applications/publish/shadps4"
}

ShadPS4_init(){
	configEmuAI "$ShadPS4_emuName" "config" "$HOME/.config/shadps4" "$EMUDECKGIT/configs/shadps4" "true"
	ShadPS4_setupStorage
	ShadPS4_setEmulationFolder
	ShadPS4_setupSaves
	ShadPS4_flushEmulatorLauncher
	ShadPS4_setLanguage

	# SRM_createParsers
  #	ShadPS4_migrate

}

#update
ShadPS4_update(){
    echo "Begin ShadPS4 update"

    configEmuAI "$ShadPS4_emuName" "config" "$HOME/.config/shadps4" "$EMUDECKGIT/configs/shadps4"

    ShadPS4_setEmulationFolder
    ShadPS4_setupStorage
    ShadPS4_setupSaves
    ShadPS4_finalize
    ShadPS4_flushEmulatorLauncher
}



#ConfigurePaths
ShadPS4_setEmulationFolder(){
    echo "Begin ShadPS4 Path Config"
#     configFile="$HOME/.config/shadps4/qt-config.ini"
#     screenshotDirOpt='Screenshots\\screenshot_path='
#     gameDirOpt='Paths\\gamedirs\\4\\path='
#     dumpDirOpt='dump_directory='
#     loadDir='load_directory='
#     nandDirOpt='nand_directory='
#     sdmcDirOpt='sdmc_directory='
#     tasDirOpt='tas_directory='
#     newScreenshotDirOpt='Screenshots\\screenshot_path='"${storagePath}/shadps4/screenshots"
#     newGameDirOpt='Paths\\gamedirs\\4\\path='"${romsPath}/switch"
#     newDumpDirOpt='dump_directory='"${storagePath}/shadps4/dump"
#     newLoadDir='load_directory='"${storagePath}/shadps4/load"
#     newNandDirOpt='nand_directory='"${storagePath}/shadps4/nand"
#     newSdmcDirOpt='sdmc_directory='"${storagePath}/shadps4/sdmc"
#     newTasDirOpt='tas_directory='"${storagePath}/shadps4/tas"
#
#     sed -i "/${screenshotDirOpt}/c\\${newScreenshotDirOpt}" "$configFile"
#     sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
#     sed -i "/${dumpDirOpt}/c\\${newDumpDirOpt}" "$configFile"
#     sed -i "/${loadDir}/c\\${newLoadDir}" "$configFile"
#     sed -i "/${nandDirOpt}/c\\${newNandDirOpt}" "$configFile"
#     sed -i "/${sdmcDirOpt}/c\\${newSdmcDirOpt}" "$configFile"
#     sed -i "/${tasDirOpt}/c\\${newTasDirOpt}" "$configFile"

    #Setup Bios symlinks
    unlink "${biosPath}/shadps4/keys"
    mkdir -p "$HOME/.config/shadps4/system/"
    mkdir -p "${biosPath}/shadps4/"
    unlink "$HOME/.config/shadps4/system"
    ln -sn "$HOME/.config/shadps4/system" "${biosPath}/shadps4/keys"
    sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|g" "$ShadPS4_configFile"

}

#SetLanguage
ShadPS4_setLanguage(){
    setMSG "Setting ShadPS4 Language"
    local language=$(locale | grep LANG | cut -d= -f2 | cut -d_ -f1)

#	# TODO: call this somewhere, and input the $language from somewhere (args?)
#	if [[ -f "${ShadPS4_configFile}" ]]; then
#		if [ ${ShadPS4_languages[$language]+_} ]; then
#            # we cant edit inplace, so we save it into a tmp var
#            tmp=$(jq ".system_language=\"${ShadPS4_languages[$language]}\"" "$ShadPS4_configFile")
#            echo "$tmp" > "$ShadPS4_configFile"
#            tmp=$(jq ".system_region=\"${ShadPS4_regions[$language]}\"" "$ShadPS4_configFile")
#            echo "$tmp" > "$ShadPS4_configFile"
#		fi
#	fi

}

#SetupSaves
ShadPS4_setupSaves(){
    echo "Begin ShadPS4 save link"

    if [ -d "${emulationPath}/saves/shadps4/saves" ]; then
        rm -rf "${emulationPath}/saves/shadps4/saves"
        rm -rf "${emulationPath}/saves/shadps4/saveMeta"
    fi

    if [ -d "${emulationPath}/saves/shadps4/saves" ]; then
        rm -rf "${emulationPath}/saves/shadps4/"
    fi

    linkToSaveFolder ShadPS4 saves "$HOME/.config/shadps4/bis/user/save"
    linkToSaveFolder ShadPS4 saveMeta "$HOME/.config/shadps4/bis/user/saveMeta"
	linkToSaveFolder ShadPS4 system_saves "$HOME/.config/shadps4/bis/system/save"
	linkToSaveFolder ShadPS4 system "$HOME/.config/shadps4/system"

}

#SetupStorage
ShadPS4_setupStorage(){
    echo "Begin ShadPS4 storage config"

    local origPath="$HOME/.config/"
    mkdir -p "${storagePath}/shadps4/patchesAndDlc"
    rsync -av "${origPath}/shadps4/games/" "${storagePath}/shadps4/games/" && rm -rf "${origPath}ShadPS4/games"
    unlink "${origPath}/shadps4/games"
    ln -ns "${storagePath}/shadps4/games/" "${origPath}/shadps4/games"
}

#WipeSettings
ShadPS4_wipe(){
    echo "Begin ShadPS4 delete config directories"
    rm -rf "$HOME/.config/shadps4"
}

#Uninstall
ShadPS4_uninstall(){
    echo "Begin ShadPS4 uninstall"
    uninstallGeneric $ShadPS4_emuName $ShadPS4_emuPath "" "emulator"
}

# Migrate flatpak to appimage??
ShadPS4_migrate(){
	echo "Begin ShadPS4 Migration"

	# Migration
	if [ "$(ShadPS4_IsMigrated)" != "true" ]; then
		#ShadPS4 flatpak to appimage
		#From -- > to
		migrationTable=()
		migrationTable+=("$HOME/.var/app/net.shadps4.ShadPS4/config/shadps4" "$HOME/.config/shadps4")

		migrateAndLinkConfig "$ShadPS4_emuName" "$migrationTable"
	fi

	echo "true"
}

ShadPS4_IsMigrated(){
	if [ -f "$ShadPS4_migrationFlag" ]; then
		echo "true"
	else
		echo "false"
	fi
}

#setABXYstyle
ShadPS4_setABXYstyle(){
    sed -i 's/"button_x": "Y",/"button_x": "X",/' $ShadPS4_configFile
    sed -i 's/"button_b": "A",/"button_b": "B",/' $ShadPS4_configFile
    sed -i 's/"button_y": "X",/"button_y": "Y",/' $ShadPS4_configFile
    sed -i 's/"button_a": "B"/"button_a": "A"/' $ShadPS4_configFile

}
ShadPS4_setBAYXstyle(){
    sed -i 's/"button_x": "X",/"button_x": "Y",/' $ShadPS4_configFile
    sed -i 's/"button_b": "B",/"button_b": "A",/' $ShadPS4_configFile
    sed -i 's/"button_y": "Y",/"button_y": "X",/' $ShadPS4_configFile
    sed -i 's/"button_a": "A"/"button_a": "B"/' $ShadPS4_configFile
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
    if [ -e "$ShadPS4_emuPath/shadps4" ]; then
        echo "true"
    else
        echo "false"
    fi
}

ShadPS4_resetConfig(){
    ShadPS4_init &>/dev/null && echo "true" || echo "false"
}

ShadPS4_setResolution(){

	case $ShadPS4Resolution in
		"720P") multiplier=1; docked="false";;
		"1080P") multiplier=1; docked="true";;
		"1440P") multiplier=2; docked="false";;
		"4K") multiplier=2; docked="true";;
		*) echo "Error"; return 1;;
	esac

	jq --arg docked "$docked" --arg multiplier "$multiplier" \
	  '.docked_mode = $docked | .res_scale = $multiplier' "$ShadPS4_configFile" > tmp.json

	mv tmp.json "$ShadPS4_configFile"

}

ShadPS4_flushEmulatorLauncher(){
	flushEmulatorLaunchers "ShadPS4"
}