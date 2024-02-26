#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "rpcs3"
cloud_sync_downloadEmu rpcs3
cloud_sync_uploadEmu rpcs3
rm -rf "$savesPath/.gaming"
emuName="rpcs3" #parameterize me
emufolder="$HOME/Applications" # has to be applications for ES-DE to find it

# Works with both Flatpak and AppImage
export LD_LIBRARY_PATH=/usr/lib:/usr/local/lib


#find full path to emu executable
exe=$(find $emufolder -iname "${emuName}*.AppImage" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)

echo $exe

#if appimage doesn't exist fall back to flatpak.
if [[ $exe == '' ]]; then
    #flatpak
    flatpakApp=$(flatpak list --app --columns=application | grep $emuName)
    exe="/usr/bin/flatpak run "$flatpakApp
else
    #make sure that file is executable
    chmod +x $exe
fi

#run the executable with the params.
#Fix first '
param="${@}"
substituteWith='"'
param=${param/\'/"$substituteWith"}
#Fix last ' on command
param=$(echo "$param" | sed 's/.$/"/')
eval "${exe} ${param}"