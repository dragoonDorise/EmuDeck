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
BIGPEMU="${HOME}/Applications/BigPEmu/BigPEmu.exe"

# APPID
APPID=$( /usr/bin/python "${APPIDPY}" "${EXE}" "${NAME}" )
echo "APPID: ${APPID}"
# Set APPID in Config as I am pretty sure this isn't a static number
changeLine "BigPEmu_appID=" "BigPEmu_appID=${APPID}" "${HOME}/.config/EmuDeck/backend/functions/EmuScripts/emuDeckBigPEmu.sh"

# Proton Version
PROTONVER="7.0"

# Call the Proton launcher script and give the arguments

echo "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${BIGPEMU}" "${@}" >> "${LOGFILE}"
"${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${BIGPEMU}" "${@}"

# Cloud Save
rclone_uploadEmu bigpemu
