#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh

GAMELAUNCHER=${toolsPath}/ULWGL/gamelauncher.sh

EXE=$romsPath/model2/EMULATOR.EXE

cd $romsPath/model2


# $Model2_ProtonGEVersion is assigned in emuDeckModel2.sh
WINEPREFIX=$romsPath/model2/pfx/ GAMEID=ulwgl-model2 PROTONPATH="$HOME/.steam/steam/compatibilitytools.d/$Model2_ProtonGEVersion" $GAMELAUNCHER $EXE "${@}"

