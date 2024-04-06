#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "rpcs3"
emuName="rpcs3" #parameterize me
emufolder="$HOME/Applications" # has to be applications for ES-DE to find it

#find full path to emu executable
exe=$(find $emufolder -iname "${emuName}*.AppImage" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)

echo $exe

#if appimage doesn't exist fall back to flatpak.
if [[ $exe == '' ]]; then
    #flatpak
    flatpakApp=$(flatpak list --app --columns=application | grep "$RPCS3_emuPathFlatpak")
    exe="/usr/bin/flatpak run "$flatpakApp
else
    #make sure that file is executable
    chmod +x $exe
fi

fileExtension="${@##*.}"

if [[ $fileExtension == "desktop" ]]; then
    rpcs3desktopFile=$(grep -E "^Exec=" "${*}" | sed 's/^Exec=//' | sed 's/%%/%/g')
    echo "Exec=$rpcs3desktopFile"
    eval $rpcs3desktopFile
else
    #run the executable with the params.
    #Fix first '
    param="${@}"
    substituteWith='"'
    param=${param/\'/"$substituteWith"}
    #Fix last ' on command
    param=$(echo "$param" | sed 's/.$/"/')
    eval "${exe} ${param}"
fi