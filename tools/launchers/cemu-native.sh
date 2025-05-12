#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "cemu"
# shellcheck disable=SC1091
. "$emudeckFolder/settings.sh"

# shellcheck disable=SC2154
LAUNCH="${toolsPath}/emu-launch.sh"

# Set emulator name
EMU="Cemu"

# Launch emu-launch.sh
"${LAUNCH}" -e "${EMU}" -- "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";