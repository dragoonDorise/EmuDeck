#!/usr/bin/bash
# cemu.sh

# Get SELFPATH
SELFPATH="$( realpath "${BASH_SOURCE[0]}" )"

# Get EXE
EXE="\"/usr/bin/bash\" \"${SELFPATH}\""

# NAME
NAME="Cemu"

# AppID.py
APPIDPY="/run/media/mmcblk0p1/Emulation/tools/appID.py"

# Proton Launcher Script
PROTONLAUNCH="/run/media/mmcblk0p1/Emulation/tools/proton-launch.sh"

# Cemu.exe location
CEMU="/run/media/mmcblk0p1/Emulation/roms/wiiu/Cemu.exe"

# APPID
APPID=$( /usr/bin/python "${APPIDPY}" "${EXE}" "${NAME}" )

# Call the Proton launcher script and give the arguments
"${PROTONLAUNCH}" -p '7.0' -i "${APPID}" -- "${CEMU}" "${@}"
