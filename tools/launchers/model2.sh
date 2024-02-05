#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh

# $ULWGL_toolPath is assigned in emuDeckModel2.sh
GAMELAUNCHER=$ULWGL_toolPath/ulwgl-run

EXE="$romsPath/model2/EMULATOR.EXE"

Model2Launcher="${toolsPath}/launchers/model2.sh"

#In case the user deletes it, the script below does re-create it though
mkdir -p "$romsPath/model2/pfx"

while [ ! -d "$romsPath/model2/pfx/drive_c" ]; do

    echo "Launching Model 2 for the first time. Downloading Protonfixes."

    # $Model2_ProtonGEVersion is assigned in emuDeckModel2.sh
    WINEPREFIX=$romsPath/model2/pfx/ GAMEID=ulwgl-model2 PROTONPATH="$HOME/.steam/steam/compatibilitytools.d/ULWGL-Proton-$Model2_ProtonGEVersion" $GAMELAUNCHER $Model2Launcher | zenity --progress --auto-close --pulsate --text="First time launching the Model 2 Emulator. Downloading protonfixes. Please be patient, this may take a while." --title="Model 2 Emulator" --width=600 --height=250 2>/dev/null

done

# Must launch ROMs from the same directory as EMULATOR.EXE
cd $romsPath/model2

# $Model2_ProtonGEVersion is assigned in emuDeckModel2.sh
WINEPREFIX=$romsPath/model2/pfx/ GAMEID=ulwgl-model2 PROTONPATH="$HOME/.steam/steam/compatibilitytools.d/ULWGL-Proton-$Model2_ProtonGEVersion" $GAMELAUNCHER $EXE "${@}"



