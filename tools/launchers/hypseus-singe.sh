#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "HypseusSinge"
emuName="Hypseus Singe" #parameterize me
emufolder="$HOME/Applications/hypseus-singe" # has to be applications for ES-DE to find it

#find full path to emu executable
exe=$(find $emufolder -iname "${emuName}*.AppImage" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)
chmod +x $exe
#run the executable with the params.
#Fix first '
param="${@}"
param=$(echo "$param" | sed "s|'|\"|g")
eval "${exe} ${param}"
