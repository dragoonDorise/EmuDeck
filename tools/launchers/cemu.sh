#!/usr/bin/bash
# cemu.sh

# Proton Launcher Script
PROTONLAUNCH="/run/media/mmcblk0p1/Emulation/tools/proton-launch.sh"

# Cemu.exe location
CEMU="/run/media/mmcblk0p1/Emulation/roms/wiiu/Cemu.exe"

# Call the Proton launcher script and give the arguments
"${PROTONLAUNCH}" -i '10000' -p '7.0' -- "${CEMU}" "${@}"
