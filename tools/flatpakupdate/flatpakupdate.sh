#!/bin/bash
source "~/emudeck/backend/functions/all.sh"
emuTable=()
emuTable+=(TRUE "Multiple" "RetroArch")
emuTable+=(TRUE "Metroid Prime" "PrimeHack")
emuTable+=(TRUE "PS3" "RPCS3")
emuTable+=(TRUE "3DS" "Citra")
emuTable+=(TRUE "GC/Wii" "Dolphin")
emuTable+=(TRUE "PSX" "Duckstation")
emuTable+=(TRUE "PSP" "PPSSPP")
emuTable+=(TRUE "WiiU" "Cemu")
emuTable+=(TRUE "XBox" "Xemu")
#if we are in beta / dev install, allow Xenia. Still false by default though. Will only work on expert mode, and explicitly turned on.
if [[ $branch=="beta" || $branch=="dev" ]]; then
    emuTable+=(FALSE "Xbox360" "Xenia")
fi

#Emulator selector
text="`printf "What emulators do you want to update?"`"
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
    if [[ "$emusToInstall" == *"Cemu"* ]]; then
        doUpdateCemu=true
    fi
    if [[ "$emusToInstall" == *"Xemu"* ]]; then
        doUpdateXemu=true
    fi
    if [[ "$emusToInstall" == *"Xenia"* ]]; then
        doUpdateXenia=true
    fi
    #if [[ "$emusToInstall" == *"MelonDS"* ]]; then
    #	doUpdateMelon=true
    #fi


else
    exit
fi


if [ $doInstallPrimeHacks == "true" ]; then
    updateEmuFP "PrimeHack" "io.github.shiiion.primehack"		
fi
if [ $doInstallRPCS3 == "true" ]; then
    updateEmuFP "RPCS3" "net.rpcs3.RPCS3"		
fi
if [ $doInstallCitra == "true" ]; then
    updateEmuFP "Citra" "org.citra_emu.citra"		
fi
if [ $doInstallDolphin == "true" ]; then
    updateEmuFP "dolphin-emu" "org.DolphinEmu.dolphin-emu"
fi
if [ $doInstallDuck == "true" ]; then
    updateEmuFP "DuckStation" "org.duckstation.DuckStation"		
fi
if [ $doInstallRA == "true" ]; then
    updateEmuFP "RetroArch" "org.libretro.RetroArch"		
fi
if [ $doInstallPPSSPP == "true" ]; then
    updateEmuFP "PPSSPP" "org.ppsspp.PPSSPP"		
fi

if [ $doInstallXemu == "true" ]; then
    updateEmuFP "Xemu-Emu" "app.xemu.xemu"	
fi