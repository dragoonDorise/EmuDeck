#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "RMG"
set -- /usr/bin/flatpak run com.github.Rosalie241.RMG "${@}"
LSFG="$HOME/lsfg"
LSFG_CONF="$HOME/.config/EmuDeck/backend/launchers/rmg.toml"
if [ -f "$LSFG" ]; then
	export LSFGVK_CONFIG="$LSFG_CONF"
	set -- "$LSFG" "$@"
fi
"$@"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming"