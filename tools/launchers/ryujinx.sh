#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "ryujinx" && cloud_sync_startService
emuName="Ryujinx" #parameterize me
emufolder="$HOME/Applications/publish" # has to be applications for ES-DE to find it

#find full path to emu executable
exe=$(find $emufolder -iname "${emuName}" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)

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
param="${@}"
param=$(echo "$param" | sed "s|'|/\"|g")
eval "${exe} ${param}"
rm -rf "$savesPath/.gaming"