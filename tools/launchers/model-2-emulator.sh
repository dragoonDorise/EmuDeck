#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "model2"
# Get SELFPATH
SELFPATH="$( realpath "${BASH_SOURCE[0]}" )"

# Set script CONFIG_FILE
CONFIG_FILE="${SELFPATH}.config"

# Get EXE
EXE="\"/usr/bin/bash\" \"${SELFPATH}\""

# NAME
NAME="Model2Emu"

# AppID.py
APPIDPY="${toolsPath}/appID.py"

# Proton Launcher Script
PROTONLAUNCH="${toolsPath}/proton-launch.sh"

# Model 2 Emulator's exe location
EMUEXE="$romsPath/model2/emulator_multicpu.exe"

if [[ "${*}" == "bel" ||  "${*}" == "gunblade" || "${*}" == "rchase2" ]]; then
    # Disables cursor
    sed -i 's/DrawCross=1/DrawCross=0/' "M2CONFIGFILE"
else
    # Enables cursor for lightgun games (and everything else)
    sed -i 's/DrawCross=0/DrawCross=1/' "M2CONFIGFILE"
fi

# we do not need to setup prefix on recent Protons :/
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

# Must launch ROMs from the same directory as EMULATOR.EXE.
cd $romsPath/model2

# Call the Proton launcher script and give the arguments
echo "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${EMUEXE}" "${@}"
# >> "${LOGFILE}" # huh, what logfile is that?!?
# disable Xalia for this, since Xalia messes with manual reconf of M2emu controller binds
PROTON_USE_XALIA=0 "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${EMUEXE}" "${@}"

cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";
