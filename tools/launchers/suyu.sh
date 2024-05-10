#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "suyu"
emuName="suyu" #parameterize me
emufolder="$HOME/Applications" # has to be applications for ES-DE to find it

#find full path to emu executable
exe=$(find $emufolder -iname "${emuName}*.AppImage" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)

echo $exe

#if appimage doesn't exist fall back to flatpak.
if [[ $exe == '' ]]; then
	#flatpak
	flatpakApp=$(flatpak list --app --columns=application | grep 'citra')
	exe="/usr/bin/flatpak run "$flatpakApp
else
	#make sure that file is executable
	chmod +x $exe
fi

#run the executable with the params.
#Fix first '
param="${@}"
param=$(echo $param | sed -e 's/^/"/' -e 's/$/"/')
eval "${exe} ${param}"
rm -rf "$savesPath/.gaming"