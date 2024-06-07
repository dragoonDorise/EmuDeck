#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "lime3ds"
emuName="lime3ds-gui" #parameterize me
emufolder="$HOME/Applications" # has to be applications for ES-DE to find it

#find full path to emu executable
exe=$(find $emufolder -iname "${emuName}*.AppImage" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)

chmod +x $exe

#run the executable with the params.
#Fix first '
param="${@}"
param=$(echo $param | sed -e 's/^/"/' -e 's/$/"/')
eval "${exe} ${param}"
rm -rf "$savesPath/.gaming"