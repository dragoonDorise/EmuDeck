#!/usr/bin/bash

# shellcheck disable=SC1091
. "${HOME}/emudeck/settings.sh"

# shellcheck disable=SC2154
LAUNCH="${toolsPath}/emu-launch.sh"

# Set emulator name
EMU="Cemu"

# Launch emu-launch.sh
"${LAUNCH}" -e "${EMU}" -- "${@}"
