#!/bin/bash

# Credits: https://github.com/Aeonitis
# Script to install, initialize and configure ShadPS4 on EmuDeck
# Note: No Bios/Keys symlinks necessary

# External helper functions (defined outside this script)
#- installEmuBI()
#- getReleaseURLGH()
#- configEmuAI()
#- linkToSaveFolder()
#- uninstallGeneric()
#- migrateAndLinkConfig()
#- flushEmulatorLaunchers()
#- setMSG()

# Variables
ShadPS4_emuName="ShadPS4"
ShadPS4_emuType="$emuDeckEmuTypeAppImage"
ShadPS4_emuPath="$HOME/Applications"
ShadPS4_configFile="$HOME/.config/shadps4/config.toml"
ShadPS4_userDir="$HOME/.config/shadps4/user"
ShadPS4_sysDir="$HOME/.config/shadps4/system"
ShadPS4_inputConfigDir="$HOME/.config/shadps4/inputConfig"
ShadPS4_controllerFile="${ShadPS4_inputConfigDir}/default.ini"


# Language keys using [ISO 639-1: Language codes] & [ISO 3166-1 alpha-2: Country codes]
# NOTE: Keep in sync with https://github.com/shadps4-emu/shadPS4/tree/main/src/qt_gui/translations
# even though project still just uses some two character codes e.g. 'nl' instead of 'nl_NL'
declare -A ShadPS4_languages
ShadPS4_languages=(
    ["ar"]="Arabic"
    ["da_DK"]="Danish"
    ["de"]="German Deutsch"
    ["el"]="Greek"
    ["el_GR"]="Greek"
    ["en"]="English"
    ["en_US"]="English (US)"
    ["en_IE"]="English (Irish)"
    ["es_ES"]="Spanish"
    ["fa_IR"]="Farsi (Iran)"
    ["fi"]="Finnish"
    ["fi_FI"]="Finnish"
    ["fr"]="French"
    ["fr_FR"]="French"
    ["hu_HU"]="Hungarian"
    ["id"]="Indonesian"
    ["it"]="Italian"
    ["ja_JP"]="Japanese"
    ["ko_KR"]="Korean"
    ["lt_LT"]="Lithuanian"
    ["nb"]="Norwegian Bokmål"
    ["nl"]="Dutch"
    ["nl_NL"]="Dutch (Netherlands)"
    ["pl_PL"]="Polish"
    ["pt_BR"]="Portuguese"
    ["ro_RO"]="Romanian"
    ["ru_RU"]="Russian"
    ["sq"]="Albanian"
    ["ti_ER"]="Tigrinya"
    ["tr_TR"]="Turkish"
    ["uk_UA"]="Ukrainian"
    ["vi_VN"]="Vietnamese"
    ["zh_CN"]="Chinese (Simplified)"
    ["zh_TW"]="Traditional Chinese (Taiwan)"
)

declare -A ShadPS4_regions
ShadPS4_regions=(
    ["ar"]="Arabic"
    ["da_DK"]="Denmark"
    ["de"]="Deutsch"
    ["el"]="Greece"
    ["el_GR"]="Greece"
    ["en"]="Global English"
    ["en_US"]="United States"
    ["en_IE"]="Ireland"
    ["es_ES"]="Spain"
    ["fa_IR"]="Iran"
    ["fi"]="Finland"
    ["fi_FI"]="Finland"
    ["fr"]="France"
    ["fr_FR"]="France"
    ["hu_HU"]="Hungary"
    ["id"]="Indonesia"
    ["it"]="Italian"
    ["ja_JP"]="Japan"
    ["ko_KR"]="South Korea"
    ["lt_LT"]="Lithuania"
    ["nb"]="Norway"
    ["nl"]="Netherlands"
    ["nl_NL"]="Netherlands"
    ["pl_PL"]="Poland"
    ["pt_BR"]="Brazil"
    ["ro_RO"]="Romania"
    ["ru_RU"]="Russia"
    ["sq"]="Albania"
    ["ti_ER"]="Eritrea"
    ["tr_TR"]="Turkey"
    ["uk_UA"]="Ukraine"
    ["vi_VN"]="Vietnam"
    ["zh_CN"]="China"
    ["zh_TW"]="Taiwan"
)

ShadPS4_cleanup(){
    echo "Begin ShadPS4 Cleanup"
}

# TODO: Install Flatpak from https://github.com/shadps4-emu/shadPS4-flatpak
ShadPS4_install(){
  echo "Begin ShadPS4 Install"
  local showProgress=$1

  if installEmuAI "$ShadPS4_emuName" "" "$(getReleaseURLGH "shadps4-emu/shadPS4" "zip" "linux-qt")" "" "zip" "emulator" "$showProgress"; then # Cemu.AppImage
    unzip -o "$HOME/Applications/ShadPS4.zip" -d "$ShadPS4_emuPath" && rm -rf "$HOME/Applications/ShadPS4.zip"
    chmod +x "$ShadPS4_emuPath/publish/Shadps4.AppImage"
  else
    return 1
  fi
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

ShadPS4_update(){
    echo "Begin ShadPS4 update"

    configEmuAI "$ShadPS4_emuName" "config" "$HOME/.config/shadps4" "$EMUDECKGIT/configs/shadps4"

    ShadPS4_setEmulationFolder
    ShadPS4_setupStorage
    ShadPS4_setupSaves
    ShadPS4_finalize
    ShadPS4_flushEmulatorLauncher
}

# Configuration Paths
ShadPS4_setEmulationFolder(){
    echo "Begin ShadPS4 Path Config"

    # Define paths for PS4 ROMs
    gameDirOpt='Paths\\gamedirs\\0\\path='
    newGameDirOpt='Paths\\gamedirs\\0\\path='"${romsPath}/ps4"

    # Update the configuration file
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$ShadPS4_configFile"

    # https://github.com/shadps4-emu/shadPS4/blob/3f1061de5613c0c4a74d6394a6493491280bc03f/src/common/path_util.h
    mkdir -p "${ShadPS4_userDir}/screenshots/"
    mkdir -p "${ShadPS4_userDir}/shader/"
    mkdir -p "${ShadPS4_userDir}/savedata/"
    mkdir -p "${ShadPS4_userDir}/data/"
    mkdir -p "${ShadPS4_userDir}/temp/"
    mkdir -p "${ShadPS4_userDir}/sys_modules/"
    mkdir -p "${ShadPS4_userDir}/download/"
    mkdir -p "${ShadPS4_userDir}/captures/"
    mkdir -p "${ShadPS4_userDir}/cheats/"
    mkdir -p "${ShadPS4_userDir}/patches/"
    mkdir -p "${ShadPS4_userDir}/game_data/"

    # https://github.com/shadps4-emu/shadPS4/blob/main/documents/Debugging/Debugging.md#quick-analysis
    mkdir -p "${ShadPS4_userDir}/log/"

    mkdir -p "${ShadPS4_inputConfigDir}"

    echo "ShadPS4 Path Config Completed"
}

ShadPS4_setLanguage(){
    setMSG "Setting ShadPS4 Language"
    local language=$(locale | grep LANG | cut -d= -f2 | cut -d_ -f1)

    echo "Checking if the config file at path: '$ShadPS4_configFile'"
    if [[ -f "${ShadPS4_configFile}" ]]; then
        echo "Config file found: ${ShadPS4_configFile}"

        emulatorLanguage=$(read_config_toml '.GUI.emulatorLanguage' "$ShadPS4_configFile")

        echo "Checking if language key exists in current language setting..."
        if [[ -n ${ShadPS4_languages[$emulatorLanguage]+_} ]]; then
            echo "Language key found in current language settings!"

            # Save the updated language settings back to the config file
            echo "Updating system language and system region in the config file..."
            tmp=$(jq --arg lang "${ShadPS4_languages[$emulatorLanguage]}" --arg region "${ShadPS4_regions[$emulatorLanguage]}" \
                     '.system_language = $lang | .system_region = $region' \
                     "${ShadPS4_configFile}")
            echo "$tmp" > "${ShadPS4_configFile}"
            echo "Config file updated successfully."
        else
            echo "Language key '${emulatorLanguage}' not found in current language settings. No updates made."
        fi
    else
        echo "Configuration file not found: ${ShadPS4_configFile}"
    fi

    echo "ShadPS4 language '${emulatorLanguage}' configuration completed."
}

# Setup Saves
ShadPS4_setupSaves(){
    echo "Begin ShadPS4 save link"

    # Create symbolic links
    linkToSaveFolder ShadPS4 saves "${ShadPS4_userDir}/savedata"
    linkToSaveFolder ShadPS4 saveMeta "${ShadPS4_userDir}/saveMeta"
    linkToSaveFolder ShadPS4 system "${ShadPS4_sysDir}"
    linkToSaveFolder ShadPS4 system_saves "${ShadPS4_sysDir}/save"

    echo "ShadPS4 save link completed"
}


#SetupStorage
ShadPS4_setupStorage(){
    echo "Begin ShadPS4 storage config"

    local origPath="$HOME/.config/"
#    mkdir -p "${storagePath}/shadps4/patchesAndDlc"
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