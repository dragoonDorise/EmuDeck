#!/usr/bin/bash

# Set Unicode options for Vita3K
LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8
LC_TIME=en_US.UTF-8

# shellcheck disable=SC1091
. "${HOME}/emudeck/settings.sh"

# shellcheck disable=SC2154
LAUNCH="${toolsPath}/emu-launch.sh"

# Set emulator name
EMU="Vita3K"

# Vita3k needs a specific path
EMUPATH="${HOME}/Applications/Vita3K/Vita3K"

# Launch emu-launch.sh
"${LAUNCH}" -e "${EMU}" -- "${@}"
