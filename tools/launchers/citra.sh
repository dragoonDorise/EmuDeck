#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "citra"
emuName="citra-qt" #parameterize me
emufolder="$HOME/Applications" # has to be applications for ES-DE to find it

#find full path to emu executable
exe=$(find $emufolder -iname "${emuName}*.AppImage" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)

echo $exe

#if appimage doesn't exist fall back to flatpak.
if [[ $exe == '' ]]; then
	#flatpak
	flatpakApp=$(flatpak list --app --columns=application | grep "$Citra_flatpakName")
	exe="/usr/bin/flatpak run "$flatpakApp
else
	#make sure that file is executable
	chmod +x $exe
fi

#run the executable with the params.
launch_args=()
for rom in "${@}"; do
	# Parsers previously had single quotes ("'/path/to/rom'" ), this allows those shortcuts to continue working.
	removedLegacySingleQuotes=$(echo "$rom" | sed "s/^'//; s/'$//")
	launch_args+=("$removedLegacySingleQuotes")
done

echo "Launching: "${exe}" "${launch_args[*]}""

if [[ -z "${*}" ]]; then
    echo "ROM not found. Launching $emuName directly"
    "${exe}"
else
    echo "ROM found, launching game"
    "${exe}" "${launch_args[@]}"
fi

rm -rf "$savesPath/.gaming"