#!/bin/bash

# Ruta real del launcher
SELFPATH="$(realpath "$0")"
LAUNCHERS_DIR="$(dirname "$SELFPATH")"          # Emulation/tools/launchers
TOOLS_DIR="$(realpath "$LAUNCHERS_DIR/..")"     # Emulation/tools
EMULATION_DIR="$(realpath "$TOOLS_DIR/..")"     # Emulation

romsPath="$EMULATION_DIR/roms"
savesPath="$EMULATION_DIR/saves"

PROTONLAUNCH="$LAUNCHERS_DIR/proton-launch.sh"
APPIDPY="$LAUNCHERS_DIR/appID.py"

EMUEXE="$romsPath/model2/emulator_multicpu.exe"

# Validaciones básicas
[ -f "$PROTONLAUNCH" ] || { echo "Error: proton-launch.sh not found: $PROTONLAUNCH"; exit 1; }
[ -f "$EMUEXE" ] || { echo "Error: emulator not found: $EMUEXE"; exit 1; }

NAME="Model2Emu"
EXE="\"/usr/bin/bash\" \"$SELFPATH\""

# Obtener APPID
if command -v python3 >/dev/null; then
    APPID=$(python3 "$APPIDPY" "$EXE" "$NAME")
elif command -v python >/dev/null; then
    APPID=$(python "$APPIDPY" "$EXE" "$NAME")
else
    echo "Python not found"
    exit 1
fi

# Proton por defecto
PROTONVER="- Experimental"

# Model2 necesita ejecutarse desde su carpeta
cd "$romsPath/model2" || exit 1

# Lanzar con Proton
PROTON_USE_XALIA=0 "$PROTONLAUNCH" -p "$PROTONVER" -i "$APPID" -- "$EMUEXE" "$@"
