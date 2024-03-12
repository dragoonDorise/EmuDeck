#!/bin/bash
# xenia.sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "xenia"
# Get SELFPATH
SELFPATH="$( realpath "${BASH_SOURCE[0]}" )"

# Set script CONFIG_FILE
CONFIG_FILE="${SELFPATH}.config"

# Get EXE
EXE="\"/usr/bin/bash\" \"${SELFPATH}\""

# NAME
NAME="Xenia"

# AppID.py
APPIDPY="${toolsPath}/appID.py"

# Proton Launcher Script
PROTONLAUNCH="${toolsPath}/proton-launch.sh"

# Xenia.exe location
XENIA="$romsPath/xbox360/xenia_canary.exe"

# APPID
if [ -e "/usr/bin/python" ]; then
    APPID=$( /usr/bin/python "${APPIDPY}" "${EXE}" "${NAME}" )
elif [ -e "/usr/bin/python3" ]; then
    APPID=$( /usr/bin/python3 "${APPIDPY}" "${EXE}" "${NAME}" )
else 
    echo "Python not found."
fi

echo "APPID: ${APPID}"

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