#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "ppsspp"
set -- /usr/bin/flatpak run org.ppsspp.PPSSPP "${@}"
LSFG="$HOME/lsfg"
LSFG_CONF="$HOME/.config/EmuDeck/backend/launchers/ppsspp.toml"
if [ -f "$LSFG" ]; then
	export LSFGVK_CONFIG="$LSFG_CONF"
	set -- "$LSFG" "$@"
fi
"$@"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming"