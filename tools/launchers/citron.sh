#!/bin/bash
emuName="citron" #parameterize me

. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "$emuName"

# find full path to emulator appimage
appimage=$(find "$emusFolder" -iname "${emuName}*.AppImage" -print -quit 2>/dev/null)

# if appimage doesn't exist fall back to flatpak
if [[ -z "$appimage" ]]; then
	flatpakApp=$(/usr/bin/flatpak list --app --columns=application | grep -im1 "${emuName}")
	set -- /usr/bin/flatpak run "$flatpakApp" "$@"
else
	# make sure the appimage is executable
	chmod +x "$appimage"
	set -- "$appimage" "$@"
fi

LSFG="$HOME/lsfg"
LSFG_CONF="$HOME/.config/EmuDeck/backend/launchers/citron.toml"
if [ -f "$LSFG" ]; then
	export LSFGVK_CONFIG="$LSFG_CONF"
	set -- "$LSFG" "$@"
fi
echo "Launching ${emuName} with:" "$@"
"$@"

cloud_sync_uploadForced
rm -rf "$savesPath/.gaming"
