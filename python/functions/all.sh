#!/bin/bash
#Legacy installs
emulatorInit () {
    emu_name=$1
    args=$2
    python "$HOME/.config/EmuDeck/backend/tools/launcher.py" "$emu_name" "$args"
    exit
}