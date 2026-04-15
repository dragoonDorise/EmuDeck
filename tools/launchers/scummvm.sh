#!/bin/sh
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "scummvm"
set -- /usr/bin/flatpak run org.scummvm.ScummVM "${@}"
LSFG="$HOME/lsfg"
LSFG_CONF="$HOME/.config/EmuDeck/backend/launchers/scummvm.toml"
if [ -f "$LSFG" ]; then
	export LSFGVK_CONFIG="$LSFG_CONF"
	set -- "$LSFG" "$@"
fi
"$@"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming"