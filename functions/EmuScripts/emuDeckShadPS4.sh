#!/bin/bash

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
ShadPS4_emuType="$emuDeckEmuTypeBinary"
ShadPS4_emuPath="$HOME/Applications/publish"
ShadPS4_configFile="$HOME/.config/shadps4/config.toml"
userDir="$HOME/.config/shadps4/user"
sysDir="$HOME/.config/shadps4/system"
inputConfigDir="$HOME/.config/shadps4/inputConfig"
controllerFile="${inputConfigDir}/default.ini"

migrationFlag="$HOME/.config/EmuDeck/.${ShadPS4_emuName}MigrationCompleted"

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

    if installEmuBI "$ShadPS4_emuName" "$(getReleaseURLGH "ShadPS4/shadps4" "-linux_x64.tar.gz")" "" "tar.gz" "$showProgress"; then
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
    mkdir -p "${userDir}/screenshots/"
    mkdir -p "${userDir}/shader/"
    mkdir -p "${userDir}/savedata/"
    mkdir -p "${userDir}/data/"
    mkdir -p "${userDir}/temp/"
    mkdir -p "${userDir}/sys_modules/"
    mkdir -p "${userDir}/download/"
    mkdir -p "${userDir}/captures/"
    mkdir -p "${userDir}/cheats/"
    mkdir -p "${userDir}/patches/"
    mkdir -p "${userDir}/game_data/"

    # https://github.com/shadps4-emu/shadPS4/blob/main/documents/Debugging/Debugging.md#quick-analysis
    mkdir -p "${userDir}/log/"

    mkdir -p "${inputConfigDir}"

    echo "ShadPS4 Path Config Completed"
}

# Reusable Function to read value from the config.toml file
read_config_toml() {
    local key="$1"
    local configFile="$2"
    echo "Reading arguments - key '$key' from config file: '$configFile'..."

    local value
    value=$(jq -r "$key" "$configFile")

    echo "Extracted value: $value"
    echo "$value"
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
    linkToSaveFolder ShadPS4 saves "${userDir}/savedata"
    linkToSaveFolder ShadPS4 saveMeta "${userDir}/saveMeta"
    linkToSaveFolder ShadPS4 system "${sysDir}"
    linkToSaveFolder ShadPS4 system_saves "${sysDir}/save"

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
	if [ -f "$migrationFlag" ]; then
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