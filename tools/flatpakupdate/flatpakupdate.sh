#!/bin/bash
source "$HOME/emudeck/backend/functions/all.sh"
emuTable=()
emuTable+=(TRUE "Multiple" "RetroArch")
emuTable+=(TRUE "Metroid Prime" "PrimeHack")
emuTable+=(TRUE "PS3" "RPCS3")
emuTable+=(TRUE "3DS" "Citra")
emuTable+=(TRUE "GC/Wii" "Dolphin")
emuTable+=(TRUE "PSX" "Duckstation")
emuTable+=(TRUE "PSP" "PPSSPP")
emuTable+=(TRUE "XBox" "Xemu")


#Emulator selector
text="$(printf "Which emulators do you want to update?")"
emusToInstall=$(zenity --list \
        --title="EmuDeck" \
        --height=500 \
        --width=250 \
        --ok-label="OK" \
        --cancel-label="Exit" \
        --text="${text}" \
        --checklist \
        --column="Select" \
        --column="System" \
        --column="Emulator" \
        --print-column=3 \
        "${emuTable[@]}" 2>/dev/null)
ans=$?

if [ $ans -eq 0 ]; then
    echo "User selected: $emusToInstall"
    if [[ "$emusToInstall" == *"RetroArch"* ]]; then
        doUpdateRA=true
    fi
    if [[ "$emusToInstall" == *"PrimeHack"* ]]; then
        doUpdatePrimeHacks=true
    fi
    if [[ "$emusToInstall" == *"RPCS3"* ]]; then
        doUpdateRPCS3=true
    fi
    if [[ "$emusToInstall" == *"Citra"* ]]; then
        doUpdateCitra=true
    fi
    if [[ "$emusToInstall" == *"Dolphin"* ]]; then
        doUpdateDolphin=true
    fi
    if [[ "$emusToInstall" == *"Duckstation"* ]]; then
        doUpdateDuck=true
    fi
    if [[ "$emusToInstall" == *"PPSSPP"* ]]; then
        doUpdatePPSSPP=true
    fi
    if [[ "$emusToInstall" == *"Xemu"* ]]; then
        doUpdateXemu=true
    fi
    #if [[ "$emusToInstall" == *"MelonDS"* ]]; then
    #	doUpdateMelon=true
    #fi


else
    exit
fi


if [ $doUpdatePrimeHacks == "true" ]; then
    updateEmuFP "PrimeHack" "io.github.shiiion.primehack"		
fi
if [ $doUpdateRPCS3 == "true" ]; then
    updateEmuFP "RPCS3" "net.rpcs3.RPCS3"		
fi
if [ $doUpdateCitra == "true" ]; then
    updateEmuFP "Citra" "org.citra_emu.citra"		
fi
if [ $doUpdateDolphin == "true" ]; then
    updateEmuFP "dolphin-emu" "org.DolphinEmu.dolphin-emu"
fi
if [ $doUpdateDuck == "true" ]; then
    updateEmuFP "DuckStation" "org.duckstation.DuckStation"		
fi
if [ $doUpdateRA == "true" ]; then
    updateEmuFP "RetroArch" "org.libretro.RetroArch"		
fi
if [ $doUpdatePPSSPP == "true" ]; then
    updateEmuFP "PPSSPP" "org.ppsspp.PPSSPP"		
fi

if [ $doUpdateXemu == "true" ]; then
    updateEmuFP "Xemu-Emu" "app.xemu.xemu"	
fi