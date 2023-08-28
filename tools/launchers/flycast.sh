#!/usr/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
# shellcheck disable=SC1091
. "${HOME}/emudeck/settings.sh"

# shellcheck disable=SC2154
LAUNCH="${toolsPath}/emu-launch.sh"

# Set emulator name
EMU="Flycast"

# Launch emu-launch.sh
"${LAUNCH}" -e "${EMU}" -- "${@}" & cloud_sync_startService
rm -rf "$savesPath/.watching"