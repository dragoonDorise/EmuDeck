#!/usr/bin/env bash

cd "$HOME/.config/EmuDeck/backend/"
git pull
. "$HOME/.config/EmuDeck/backend/functions/all.sh"

launcherInit
emulatorInit "ZSNES"

emuName="SUPERZSNES"
emufolder="$emusFolder/zsnes"

# Ejecutable instalado desde el paquete tar.gz.
exe_path="$emufolder/$emuName"

if [[ ! -f "$exe_path" ]]; then
    echo "$emuName executable not found: $exe_path"
    exit 1
fi

chmod +x "$exe_path"
exe=("$exe_path")

# Conservar la compatibilidad con los argumentos de parsers antiguos.
launch_args=()
for rom in "${@}"; do
    removedLegacySingleQuotes=$(echo "$rom" | sed "s/^'//; s/'$//")
    launch_args+=("$removedLegacySingleQuotes")
done

echo "Launching: ${exe[*]} ${launch_args[*]}"

if [[ $# -eq 0 ]]; then
    echo "ROM not found. Launching $emuName directly"
    "${exe[@]}"
else
    echo "ROM found, launching game"
    "${exe[@]}" "${launch_args[@]}"
fi

cloud_sync_uploadForced
rm -rf "$savesPath/.gaming"