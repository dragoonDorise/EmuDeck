#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh

GAMELAUNCHER=${toolsPath}/ULWGL/gamelauncher.sh

EXE=$romsPath/model2/EMULATOR.EXE

cd $romsPath/model2

WINEPREFIX=$romsPath/model2/pfx/ GAMEID=ulwgl-model2 PROTONPATH="$HOME/.steam/steam/compatibilitytools.d/GE-Proton8-27" $GAMELAUNCHER $EXE "${@}"

