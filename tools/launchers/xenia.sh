#!/usr/bin/bash
# xenia.sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "xenia" && cloud_sync_startService
# Get SELFPATH
SELFPATH="$( realpath "${BASH_SOURCE[0]}" )"

# Set script CONFIG_FILE
CONFIG_FILE="${SELFPATH}.config"

# Get EXE
EXE="\"/usr/bin/bash\" \"${SELFPATH}\""

# NAME
NAME="Xenia"

# AppID.py
APPIDPY="/run/media/mmcblk0p1/Emulation/tools/appID.py"

# Proton Launcher Script
PROTONLAUNCH="/run/media/mmcblk0p1/Emulation/tools/proton-launch.sh"

# Xenia.exe location
XENIA="/run/media/mmcblk0p1/Emulation/roms/xbox360/xenia_canary.exe"

# APPID
APPID=$( /usr/bin/python "${APPIDPY}" "${EXE}" "${NAME}" )

# Proton Version:
# - use env FORCED_PROTON_VER if set (FORCED_PROTON_VER="GE-Proton8-16" ./xenia.sh)
# - if not set, try to use config file (xenia.sh.config, FORCED_PROTON_VER="GE-Proton8-16")
# - if stil not set, use default
DEFAULT_PROTON_VER="- Experimental"
if [[ -z "${FORCED_PROTON_VER}" ]]; then
    FORCED_PROTON_VER="$(scriptConfigFileGetVar "$CONFIG_FILE" "FORCED_PROTON_VER")"
fi
if [[ -z "${FORCED_PROTON_VER}" ]]; then
    PROTONVER="${DEFAULT_PROTON_VER}"
else
    PROTONVER="${FORCED_PROTON_VER}"
fi

# Call the Proton launcher script and give the arguments
echo "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${XENIA}" "${@}"
# >> "${LOGFILE}" # huh, what logfile is that?!?
"${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${XENIA}" "${@}"

rm -rf "$savesPath/.gaming"