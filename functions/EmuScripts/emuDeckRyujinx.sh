#!/bin/bash

#variables
Ryujinx_emuName="Ryujinx"
Ryujinx_emuType="$emuDeckEmuTypeBinary"
Ryujinx_emuPath="$emusFolder/publish"
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
    local url=$(curl -s -H "User-Agent: EmuDeck" "https://git.ryujinx.app/api/v1/repos/Ryubing/Canary/releases/latest" | jq -r '.assets[] | select(.browser_download_url | test("linux_x64\\.tar\\.gz$")) | .browser_download_url' | head -n 1)

    if installEmuBI "$Ryujinx_emuName" "$url" "" "tar.gz" "$showProgress"; then
        mkdir -p "$emusFolder/publish"
        tar -xvf "$emusFolder/Ryujinx.tar.gz" -C "$emusFolder" && rm -f "$emusFolder/Ryujinx.tar.gz"
        chmod +x "$emusFolder/publish/Ryujinx"
    else
        return 1
    fi
}

#ApplyInitialSettings
Ryujinx_init(){
    echo "Begin Ryujinx Init"

    configEmuAI "Ryujinx" "config" "$HOME/.config/Ryujinx" "$emudeckBackend/configs/Ryujinx" "true"

    Ryujinx_setEmulationFolder
    Ryujinx_setupStorage
    Ryujinx_setupSaves
    Ryujinx_finalize
	#SRM_createParsers
    Ryujinx_flushEmulatorLauncher

	if [ -e "$ESDE_toolPath" ] || [ -f "${toolsPath}/$ESDE_downloadedToolName" ] || [ -f "${toolsPath}/$ESDE_oldtoolName.AppImage" ]; then
		Yuzu_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi

    Ryujinx_setLanguage
    
    Ryujinx_set_gamepad_name

}

#update
Ryujinx_update(){
    echo "Begin Ryujinx update"

    configEmuAI "yuzu" "config" "$HOME/.config/Ryujinx" "$emudeckBackend/configs/Ryujinx"

    Ryujinx_setEmulationFolder
    Ryujinx_setupStorage
    Ryujinx_setupSaves
    Ryujinx_finalize
    Ryujinx_flushEmulatorLauncher

	if [ -e "$ESDE_toolPath" ] || [ -f "${toolsPath}/$ESDE_downloadedToolName" ] || [ -f "${toolsPath}/$ESDE_oldtoolName.AppImage" ]; then
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
    local language=$(locale | grep LANG | cut -d= -f2 | cut -d_ -f1)
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

    if [ -d "${emulationPath}/saves/Ryujinx/saves" ]; then
        rm -rf "${emulationPath}/saves/Ryujinx/"
    fi

    linkToSaveFolder ryujinx saves "$HOME/.config/Ryujinx/bis/user/save"
    linkToSaveFolder ryujinx saveMeta "$HOME/.config/Ryujinx/bis/user/saveMeta"
	linkToSaveFolder ryujinx system_saves "$HOME/.config/Ryujinx/bis/system/save"
	linkToSaveFolder ryujinx system "$HOME/.config/Ryujinx/system"

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
    uninstallGeneric $Ryujinx_emuName $Ryujinx_emuPath "" "emulator"
}

#Migrate
Ryujinx_migrate(){
    echo "Begin Ryujinx Migration"
    emu="Ryujinx"
#     migrationFlag="$emudeckFolder/.${emu}MigrationCompleted"
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


Ryujinx_getFirstGamepad(){
    local sdlLib
    for sdlLib in "$Ryujinx_emuPath/libSDL3.so" /usr/lib/libSDL3.so /usr/lib/libSDL3.so.0 /usr/lib64/libSDL3.so; do
        [ -f "$sdlLib" ] && break
        sdlLib=""
    done
    [ -n "$sdlLib" ] || { echo "libSDL3 not found" >&2; return 1; }
    command -v python3 >/dev/null 2>&1 || { echo "python3 not found" >&2; return 1; }

    SDL_LIB="$sdlLib" python3 -c '
import ctypes, os, sys

sdl = ctypes.CDLL(os.environ["SDL_LIB"])

class GUID(ctypes.Structure):
    _fields_ = [("data", ctypes.c_uint8 * 16)]

sdl.SDL_Init.argtypes = [ctypes.c_uint32]
sdl.SDL_Init.restype = ctypes.c_bool
sdl.SDL_GetGamepads.argtypes = [ctypes.POINTER(ctypes.c_int)]
sdl.SDL_GetGamepads.restype = ctypes.POINTER(ctypes.c_uint32)
#GetJoystickNameForID, not GetGamepadNameForID: for Steam Input virtual pads the
#latter returns "Steam Virtual Gamepad" while the former (like Ryujinx) resolves
#to the physical controller name Steam publishes in virtualgamepadinfo.txt.
sdl.SDL_GetJoystickNameForID.argtypes = [ctypes.c_uint32]
sdl.SDL_GetJoystickNameForID.restype = ctypes.c_char_p
sdl.SDL_GetJoystickGUIDForID.argtypes = [ctypes.c_uint32]
sdl.SDL_GetJoystickGUIDForID.restype = GUID
sdl.SDL_GetError.restype = ctypes.c_char_p

SDL_INIT_GAMEPAD = 0x00002000
if not sdl.SDL_Init(SDL_INIT_GAMEPAD):
    sys.stderr.write("SDL_Init failed: %s\n" % sdl.SDL_GetError().decode())
    sys.exit(1)

count = ctypes.c_int(0)
ids = sdl.SDL_GetGamepads(ctypes.byref(count))
if count.value < 1:
    sdl.SDL_Quit()
    sys.exit(1)

jid = ids[0]
b = bytes(sdl.SDL_GetJoystickGUIDForID(jid).data)
name = sdl.SDL_GetJoystickNameForID(jid)
name = name.decode() if name else "Unknown Controller"
sdl.SDL_Quit()

# Mirrors Ryujinx SDL3GamepadDriver.SDLGuidToString + GenerateGamepadId:
#   guid   = b2 b3 b1 b0 - b5 b4 - b6 b7 - b8 b9 - b10..b15
#   guid   = "0000" + guid[4:]   <- it zeroes the CRC field to keep the id stable
#   id     = "<n>-<guid>", n starting at 0 and only bumped on duplicates
h = lambda i: "%02x" % b[i]
guid = "0000" + h(1) + h(0) + "-" + h(5) + h(4) + "-" + h(6) + h(7) + "-" + \
       h(8) + h(9) + "-" + "".join("%02x" % x for x in b[10:16])

print("0-%s|%s" % (guid, name))
'
}

Ryujinx_set_gamepad_name() {
  local gamepad id name tmp

  gamepad="$(Ryujinx_getFirstGamepad)" || { echo "No controller detected, keeping default input config" >&2; return 1; }

  id="${gamepad%%|*}"
  name="${gamepad#*|}"
  { [ -n "$id" ] && [ -n "$name" ]; } || { echo "Could not read gamepad id/name" >&2; return 1; }

  echo "Detected gamepad: ${name} -> ${id}"

  tmp="$(mktemp)"
  if jq --arg id "$id" --arg name "${name} (0)" '
      (.input_config | map((.backend // "") | startswith("Gamepad")) | index(true)) as $i
      | if $i == null then
          error("no gamepad entry in input_config")
        else
          .input_config[$i].id = $id | .input_config[$i].name = $name
        end' "$Ryujinx_configFile" > "$tmp" && [ -s "$tmp" ]; then
    mv "$tmp" "$Ryujinx_configFile"
  else
    rm -f "$tmp"
    echo "No gamepad entry to update in $Ryujinx_configFile" >&2
    return 1
  fi
}

Ryujinx_migrateToSDL3() {
  local logFile="$emudeckLogs/ryujinx_sdl3_migration.log"
  local rcFile
  rcFile="$(mktemp)"
  mkdir -p "$emudeckLogs"


  migrate() {
    echo "5" ; echo "#Downloading the latest Ryujinx..."
    if Ryujinx_install >"$logFile" 2>&1; then
      echo "70" ; echo "#Applying Ryujinx configuration..."
      if Ryujinx_init >>"$logFile" 2>&1; then
        echo "0" > "$rcFile"
      else
        echo "1" > "$rcFile"
      fi
    else
      echo "1" > "$rcFile"
    fi
    echo "100"
  }

  
  migrate | zenity --progress \
    --title="EmuDeck" \
    --text="Updating Ryujinx to the SDL3 input backend..." \
    --width=450 \
    --percentage=0 \
    --auto-close \
    --no-cancel 2>/dev/null

  local rc
  rc="$(cat "$rcFile" 2>/dev/null)"
  rm -f "$rcFile"

  if [ "$rc" != "0" ]; then
    echo "Ryujinx: SDL3 migration failed, see $logFile" >&2
    return 1
  fi
  return 0
}

ryujinx_launch_fixes(){  
    if jq -e '[.input_config[]? | .backend? // ""] | any(startswith("GamepadSDL2"))' "$Ryujinx_configFile" >/dev/null 2>&1; then
      Ryujinx_migrateToSDL3
    fi
}