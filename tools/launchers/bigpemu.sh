#!/usr/bin/bash
# bigpemu.sh

# Set up cloud save
source "${HOME}/.config/EmuDeck/backend/functions/all.sh"
rclone_downloadEmu bigpemu

# Get SELFPATH
SELFPATH="$( realpath "${BASH_SOURCE[0]}" )"

# Get EXE
EXE="\"/usr/bin/bash\" \"${SELFPATH}\""
echo "EXE: ${EXE}"

# NAME
NAME="BigPEmu"

# AppID.py
APPIDPY="$emulationPath/tools/appID.py"

# Proton Launcher Script
PROTONLAUNCH="$emulationPath/tools/proton-launch.sh"

# BigPEmu location
BIGPEMU="$HOME/Applications/BigPEmu/BigPEmu.exe"

# APPID
APPID=$( /usr/bin/python "${APPIDPY}" "${EXE}" "${NAME}" )
echo "APPID: ${APPID}"

# Proton Version
PROTONVER="8.0"

# Call the Proton launcher script and give the arguments

if [ -z "${@}" ]; then

    echo "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${BIGPEMU}" "*" -localdata >> "${LOGFILE}"
    "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${BIGPEMU}" "*" -localdata
    echo "Launching BigPEmu directly"

else

    echo "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${BIGPEMU}" "${@}" -localdata >> "${LOGFILE}"
    "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${BIGPEMU}" "${@}" -localdata
    echo "ROM found, launching game"

fi

# Cloud Save
rclone_uploadEmu bigpemu
