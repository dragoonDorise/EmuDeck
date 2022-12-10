#!/bin/sh

LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8
LC_TIME=en_US.UTF-8

emuName="Vita3K" #parameterize me
emufolder="$HOME/Applications/Vita3K" # has to be applications for ES-DE to find it

#find full path to emu executable
exe=$(find "$emufolder" -iname "${emuName}" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)

#make sure that file is executable
chmod +x "$exe"

#run the executable with the params.
#Fix first '
param="${@}"
substituteWith='"'
param=${param/\'/"$substituteWith"}
#Fix last ' on command
param=$(echo "$param" | sed 's/.$/"/')
eval "${exe} ${param}"