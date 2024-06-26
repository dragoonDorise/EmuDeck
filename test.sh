#!/bin/bash
. $HOME/.config/EmuDeck/backend/functions/all.sh

Lime3DS_IsInstalled(){
    if [ -e "$Lime3DS_emuPath" ]; then
        echo "true"
    else
        echo "false"
    fi
}
echo $Lime3DS_emuPath
Lime3DS_IsInstalled