#!/usr/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu cemu-native
# shellcheck disable=SC1091
. "${HOME}/emudeck/settings.sh"

# shellcheck disable=SC2154
LAUNCH="${toolsPath}/emu-launch.sh"

# Set emulator name
EMU="Cemu"

# Launch emu-launch.sh
"${LAUNCH}" -e "${EMU}" -- "${@}"
rclone_uploadEmu cemu-native