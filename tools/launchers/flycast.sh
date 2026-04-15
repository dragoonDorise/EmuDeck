#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "flycast"

set -- /usr/bin/flatpak run org.flycast.Flycast "${@}"

LSFG="$HOME/lsfg"
LSFG_CONF="$HOME/.config/EmuDeck/backend/launchers/flycast.toml"
if [ -f "$LSFG" ]; then
	export LSFGVK_CONFIG="$LSFG_CONF"
	set -- "$LSFG" "$@"
fi

"$@"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming"