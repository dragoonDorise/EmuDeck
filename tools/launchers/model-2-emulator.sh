#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "model2"
# $ULWGL_toolPath is assigned in emuDeckModel2.sh
GAMELAUNCHER=$ULWGL_toolPath/ulwgl-run

EXE="$romsPath/model2/EMULATOR.EXE"

Model2Launcher="${toolsPath}/launchers/model-2-emulator.sh"

Model2ConfigFile="$romsPath/model2/EMULATOR.INI"

#In case the user deletes it, will allow loading bar to pop up again.
mkdir -p "$romsPath/model2/pfx"

while [ ! -d "$romsPath/model2/pfx/drive_c" ]; do

    echo "Launching Model 2 for the first time. Downloading Protonfixes."

    # $Model2_ProtonGEVersion is assigned in emuDeckModel2.sh
    WINEPREFIX=$romsPath/model2/pfx/ GAMEID=ulwgl-model2 PROTONPATH="$HOME/.steam/steam/compatibilitytools.d/ULWGL-Proton-$Model2_ProtonGEVersion" $GAMELAUNCHER $Model2Launcher | zenity --progress --auto-close --pulsate --text="First time launching the Model 2 Emulator. Downloading protonfixes. Please be patient, this may take a while." --title="Model 2 Emulator" --width=600 --height=250 2>/dev/null

done

# Must launch ROMs from the same directory as EMULATOR.EXE.
cd $romsPath/model2


if [[ "${*}" == "bel" ||  "${*}" == "gunblade" || "${*}" == "rchase2" ]]; then
    # Disables cursor
    sed -i 's/DrawCross=1/DrawCross=0/' "$Model2ConfigFile"
    # $Model2_ProtonGEVersion is assigned in emuDeckModel2.sh
    WINEPREFIX=$romsPath/model2/pfx/ GAMEID=ulwgl-model2 PROTONPATH="$HOME/.steam/steam/compatibilitytools.d/ULWGL-Proton-$Model2_ProtonGEVersion" $GAMELAUNCHER $EXE "${@}"

else
    # Enables cursor for lightgun games (and everything else)
    sed -i 's/DrawCross=0/DrawCross=1/' "$Model2ConfigFile"
    # $Model2_ProtonGEVersion is assigned in emuDeckModel2.sh
    WINEPREFIX=$romsPath/model2/pfx/ GAMEID=ulwgl-model2 PROTONPATH="$HOME/.steam/steam/compatibilitytools.d/ULWGL-Proton-$Model2_ProtonGEVersion" $GAMELAUNCHER $EXE "${@}"
fi

rm -rf "$savesPath/.gaming"