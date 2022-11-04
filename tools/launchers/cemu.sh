#!/usr/bin/bash
# cemu.sh

# LogFile
LOGFILE="$(dirname "${BASH_SOURCE[0]}")/cemu-launch.log"

# Report start time to log
echo "$(date +'%m/%d/%Y - %H:%M:%S') - Started" > "${LOGFILE}"

# Settings file
settingsFile="${HOME}/emudeck/settings.sh"
if [ -f "${settingsFile}" ]; then
    # Source the settings file
    # shellcheck disable=SC1091
    # shellcheck source="${HOME}/emudeck/settings.sh"
    . "${settingsFile}"
else
    reportError "Error: Unable to find ${settingsFile}." "true" "true"
fi

# launcherFunctions.sh
launcherFunctions="${toolsPath}/launcherFunctions.sh"
if [ -f "${launcherFunctions}" ]; then
    # Source the launcherFunctions.sh
    # shellcheck disable=SC1091
    # shellcheck source="${toolsPath}/launcherfunctions.sh"
    . "${launcherFunctions}"
else
    reportError "Error: Unable to find ${launcherFunctions}." "true" "true"
fi

# Get SELFPATH
SELFPATH="$( realpath "${BASH_SOURCE[0]}" )"

if [ -z "${SELFPATH}" ]; then
    reportError "Error: Unable to get own path" "true" "true"
else
    echo "SELFPATH: ${SELFPATH}" >> "${LOGFILE}"
fi

# Get EXE
EXE="\"/usr/bin/bash\" \"${SELFPATH}\""
echo "EXE: ${EXE}" >> "${LOGFILE}"

# NAME
NAME="Cemu"
echo "NAME: ${NAME}" >> "${LOGFILE}"

# AppID.py
APPIDPY="/run/media/mmcblk0p1/Emulation/tools/appID.py"
checkFile "${APPIDPY}"

# Proton Launcher Script
PROTONLAUNCH="/run/media/mmcblk0p1/Emulation/tools/proton-launch.sh"
checkFile "${PROTONLAUNCH}"

# Cemu.exe location
CEMU="/run/media/mmcblk0p1/Emulation/roms/wiiu/Cemu.exe"
checkFile "${CEMU}"

# APPID
APPID=$( /usr/bin/python "${APPIDPY}" "${EXE}" "${NAME}" )
echo "APPID: ${APPID}" >> "${LOGFILE}"
if [ -z "${APPID}" ]; then
    reportError "Unable to calculate AppID" "true" "true"
fi

# PROTONVER
PROTONVER="7.0"

# Call the Proton launcher script and give the arguments
echo "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${CEMU}" "${@}" >> "${LOGFILE}"
"${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${CEMU}" "${@}"
