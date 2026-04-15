. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "melonds"
set -- /usr/bin/flatpak run net.kuribo64.melonDS "${@}"
LSFG="$HOME/lsfg"
LSFG_CONF="$HOME/.config/EmuDeck/backend/launchers/melonds.toml"
if [ -f "$LSFG" ]; then
	export LSFGVK_CONFIG="$LSFG_CONF"
	set -- "$LSFG" "$@"
fi
"$@"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming"