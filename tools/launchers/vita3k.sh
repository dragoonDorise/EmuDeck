#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "Vita3k"
export LC_ALL="C"

emuName="Vita3K" #parameterize me
emufolder="$HOME/Applications" # has to be applications for ES-DE to find it
emuBinaryFolder="$HOME/Applications/Vita3K"

#find full path to emu executable
exe=$(find "$emufolder" -iname "${emuName}*.AppImage" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)

#if appimage doesn't exist fall back to binary.
if [[ $exe == '' ]]; then
	#binary
	exe=$(find "$emuBinaryFolder" -iname "${emuName}" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)
	chmod +x $exe
    echo "Binary found."
else
#make sure that file is executable
	chmod +x $exe
    echo "AppImage found."
fi

fileExtension="${@##*.}"

if [[ $fileExtension == "psvita" ]]; then
    vita3kFile=$(<"${*}")
    echo "GAME ID: $vita3kFile"
    eval "${exe}" -Fr "$vita3kFile"
else

    param="${@}"
    substituteWith='"'
    param=${param/\'/"$substituteWith"}
    #Fix last ' on command
    param=$(echo "$param" | sed 's/.$/"/')
    eval "${exe} ${param} -fullscreen"
    eval "${exe} -Fr ${param}"
fi

rm -rf "$savesPath/.gaming"
