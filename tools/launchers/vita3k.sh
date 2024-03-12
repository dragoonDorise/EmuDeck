#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "Vita3k"
export LC_ALL="C"

emuName="Vita3K" #parameterize me
emufolder="$HOME/Applications/Vita3K" # has to be applications for ES-DE to find it

#find full path to emu executable
exe=$(find "$emufolder" -iname "${emuName}" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)

#make sure that file is executable
chmod +x "$exe"

fileExtension="${@##*.}"

if [[ $fileExtension == "psvita" ]]; then
    vita3kFile=$(<"${*}")
    echo "GAME ID: $vita3kFile"
    eval "${exe}" -Fr "$vita3kFile"
else
    eval "${exe} ${param}"
fi

rm -rf "$savesPath/.gaming"
