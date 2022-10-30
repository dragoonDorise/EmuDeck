#!/usr/bin/bash
# cemu.sh

# Report Errors
reportError () {
    echo "${1}" >> "${LOGFILE}"
    if [ "${2}" == "true" ]; then
        zenity --error \
            --text="${1}" \
            --width=250
    fi
    if [ "${3}" == "true" ]; then
        exit 1
    fi
}

# Check for file
checkFile () {
    echo "Checking for file: ${1}" >> "${LOGFILE}"
    if [ ! -f "${1}" ]; then
        reportError "Error: Unable to find ${1##*/} in\n ${1%/*}" "true" "true"
    fi
}

# LogFile
LOGFILE="$(dirname "${BASH_SOURCE[0]}")/cemu-launch.log"

# Report start time to log
echo "$(date +'%m/%d/%Y - %H:%M:%S') - Started" > "${LOGFILE}"

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
