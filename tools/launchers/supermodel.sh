#!/bin/sh
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "supermodel"
set -- /usr/bin/flatpak run com.supermodel3.Supermodel "${@}"
LSFG="$HOME/lsfg"
LSFG_CONF="$HOME/.config/EmuDeck/backend/launchers/supermodel.toml"
if [ -f "$LSFG" ]; then
	export LSFGVK_CONFIG="$LSFG_CONF"
	set -- "$LSFG" "$@"
fi
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming"