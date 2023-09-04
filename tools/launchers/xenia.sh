#!/usr/bin/bash
# xenia.sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "xenia" && cloud_sync_startService
# Get SELFPATH
SELFPATH="$( realpath "${BASH_SOURCE[0]}" )"

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

# Proton Version
PROTONVER="- Experimental"

# Call the Proton launcher script and give the arguments

echo "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${XENIA}" "${@}" >> "${LOGFILE}"

"${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${XENIA}" "${@}"
rm -rf "$savesPath/.gaming"