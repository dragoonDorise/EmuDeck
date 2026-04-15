#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "xemu"
set -- /usr/bin/flatpak run app.xemu.xemu "${@}"
LSFG="$HOME/lsfg"
if [ -f "$LSFG" ]; then
	set -- "$LSFG" "$@"
fi
"$@"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming"