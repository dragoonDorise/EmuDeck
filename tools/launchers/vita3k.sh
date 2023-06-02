#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu vita3k
export LC_ALL="C"

emuName="Vita3K" #parameterize me
emufolder="$HOME/Applications/Vita3K" # has to be applications for ES-DE to find it

#find full path to emu executable
exe=$(find "$emufolder" -iname "${emuName}" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)

#make sure that file is executable
chmod +x "$exe"

eval "${exe} ${param}"
rclone_uploadEmu vita3k