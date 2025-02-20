#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
if [ "$?" == "1" ]; then
    echo "functions could not be loaded."
    zenity --error \
        --text="EmuDeck Functions could not be loaded. Please re-run Emudeck install." 2>/dev/null
    exit
fi

declare -a emuTable

if [ "$(ares_IsInstalled "$emuDeckEmuTypeFlatpak")" == "true" ]; then
    emuTable+=(TRUE "ares" "Multi-System Emulator")
else
    emuTable+=(FALSE "ares" "Multi-System Emulator")
fi

if [ "$(Dolphin_IsInstalled "$emuDeckEmuTypeFlatpak")" == "true" ]; then
    emuTable+=(TRUE "Dolphin" "Nintendo GameCube/Wii")
else
    emuTable+=(FALSE "Dolphin" "Nintendo GameCube/Wii")
fi

if [ "$(DuckStation_IsInstalled "$emuDeckEmuTypeFlatpak")" == "true" ]; then
    emuTable+=(TRUE "DuckStation" "Sony PlayStation 1")
else
    emuTable+=(FALSE "DuckStation" "Sony PlayStation 1")
fi

if [ "$(melonDS_IsInstalled "$emuDeckEmuTypeFlatpak")" == "true" ]; then
    emuTable+=(TRUE "melonDS" "Nintendo DS")
else
    emuTable+=(FALSE "melonDS" "Nintendo DS")
fi

if [ "$(PPSSPP_IsInstalled "$emuDeckEmuTypeFlatpak")" == "true" ]; then
    emuTable+=(TRUE "PPSSPP" "Sony PlayStation Portable")
else
    emuTable+=(FALSE "PPSSPP" "Sony PlayStation Portable")
fi

if [ "$(Primehack_IsInstalled "$emuDeckEmuTypeFlatpak")" == "true" ]; then
    emuTable+=(TRUE "PrimeHack" "Nintendo Metroid Prime Trilogy")
else
    emuTable+=(FALSE "PrimeHack" "Nintendo Metroid Prime Trilogy")
fi

if [ "$(RetroArch_IsInstalled "$emuDeckEmuTypeFlatpak")" == "true" ]; then
    emuTable+=(TRUE "RetroArch" "Multi-System Emulator")
else
    emuTable+=(FALSE "RetroArch" "Multi-System Emulator")
fi

if [ "$(RMG_IsInstalled "$emuDeckEmuTypeFlatpak")" == "true" ]; then
    emuTable+=(TRUE "Rosalie's Mupen GUI" "Nintendo 64")
else
    emuTable+=(FALSE "Rosalie's Mupen GUI" "Nintendo 64")
fi

if [ "$(ScummVM_IsInstalled "$emuDeckEmuTypeFlatpak")" == "true" ]; then
    emuTable+=(TRUE "ScummVM" "Point and Click Adventures")
else
    emuTable+=(FALSE "ScummVM" "Point and Click Adventures")
fi

if [ "$(Supermodel_IsInstalled "$emuDeckEmuTypeFlatpak")" == "true" ]; then
    emuTable+=(TRUE "Supermodel" "Sega Model 3")
else
    emuTable+=(FALSE "Supermodel" "Sega Model 3")
fi

if [ "$(Xemu_IsInstalled "$emuDeckEmuTypeFlatpak")" == "true" ]; then
    emuTable+=(TRUE "Xemu" "Microsoft Xbox")
else
    emuTable+=(FALSE "Xemu" "Microsoft Xbox")
fi

if [ ${#emuTable[@]} -gt 0 ]; then
    # Emulator selector
    text="Which Flatpak emulators would you like to update?"
    emusToInstall=$(zenity --list \
        --title="EmuDeck" \
        --height=600 \
        --width=500 \
        --ok-label="OK" \
        --cancel-label="Exit" \
        --text="${text}" \
        --checklist \
        --column="Select" \
        --column="Emulator" \
        --column="System" \
        --print-column=2 \
        "${emuTable[@]}" 2>/dev/null)
    ans=$?

    if [ $ans -eq 0 ]; then
        if [ -n "$emusToInstall" ]; then
            let pct=100/$(awk -F'|' '{print NF}' <<<"$emusToInstall")
            echo "pct=$pct"
            let progresspct=0
            : {progressInstalledPipe}<> <(:)

            echo "User selected: $emusToInstall"

            if [[ "$emusToInstall" == *"ares"* ]]; then
            	doUpdateares=true
            fi
            if [[ "$emusToInstall" == *"Dolphin"* ]]; then
                doUpdateDolphin=true
            fi
            if [[ "$emusToInstall" == *"DuckStation"* ]]; then
                doUpdateDuck=true
            fi
            if [[ "$emusToInstall" == *"melonDS"* ]]; then
            	doUpdateMelonDS=true
            fi
            if [[ "$emusToInstall" == *"PPSSPP"* ]]; then
                doUpdatePPSSPP=true
            fi
            if [[ "$emusToInstall" == *"PrimeHack"* ]]; then
                doUpdatePrimeHack=true
            fi
            if [[ "$emusToInstall" == *"RetroArch"* ]]; then
                doUpdateRA=true
            fi
            if [[ "$emusToInstall" == *"Rosalie's Mupen GUI"* ]]; then
            	doUpdateRMG=true
            fi
            if [[ "$emusToInstall" == *"ScummVM"* ]]; then
                doUpdateScummVM=true
            fi
            if [[ "$emusToInstall" == *"Supermodel"* ]]; then
                doUpdateSupermodel=true
            fi
            if [[ "$emusToInstall" == *"Xemu"* ]]; then
                doUpdateXemu=true
            fi

            (
                progressInstalled=""
                if [ "$doUpdateares" == "true" ]; then
                    echo "###Updating ares..."
                    (updateEmuFP "ares" "dev.ares.ares" "emulator" "" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|ares" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdateDolphin" == "true" ]; then
                    echo "###Updating Dolphin..."
                    (updateEmuFP "dolphin-emu" "org.DolphinEmu.dolphin-emu" "emulator" "" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|Dolphin" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdateDuck" == "true" ]; then
                    echo "###Updating DuckStation..."
                    (updateEmuFP "DuckStation" "org.duckstation.DuckStation" "emulator" "" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|DuckStation" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdateMelonDS" == "true" ]; then
                    echo "###Updating melonDS..."
                    (updateEmuFP "melonDS" "net.kuribo64.melonDS" "emulator" "" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|melonDS" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdatePPSSPP" == "true" ]; then
                    echo "###Updating PPSSPP..."
                    (updateEmuFP "PPSSPP" "org.ppsspp.PPSSPP" "emulator" "" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|PPSSPP" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdatePrimeHack" == "true" ]; then
                    echo "###Updating PrimeHack..."
                    (updateEmuFP "PrimeHack" "io.github.shiiion.primehack" "emulator" "" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|PrimeHack" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdateRA" == "true" ]; then
                    echo "###Updating RetroArch..."
                    (updateEmuFP "RetroArch" "org.libretro.RetroArch" "emulator" "" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|RetroArch" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdateRMG" == "true" ]; then
                    echo "###Updating Rosalie's Mupen GUI..."
                    (updateEmuFP "RMG" "com.github.Rosalie241.RMG" "emulator" "" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|RMG" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdateScummVM" == "true" ]; then
                    echo "###Updating ScummVM..."
                    (updateEmuFP "ScummVM" "org.scummvm.ScummVM" "emulator" "" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|ScummVM" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdateSupermodel" == "true" ]; then
                    echo "###Updating Supermodel..."
                    (updateEmuFP "Supermodel" "com.supermodel.Supermodel" "emulator" "" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|ScummVM" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdateXemu" == "true" ]; then
                    echo "###Updating Xemu..."
                    (updateEmuFP "Xemu-Emu" "app.xemu.xemu" "emulator" "" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|Xemu" && echo "&&&$progressInstalled"
                fi
                if [ $progresspct != 100 ]; then
                    progresspct=100
                    echo "%%%$progresspct"
                fi
                echo "###All selected Flatpaks updated!"
            ) |
            tee >( sed -u -n '/^%%%\|^###/p' | sed -u -r 's/^(#)##|^()%%%/\1/' | zenity --progress --title="Updating Flatpak Emulators" --text="..." --percentage=0 --width 600 2>/dev/null) | tee >({ sed -n '/^&&&/p' | sed 's/^&&&//' ; echo '-EOF-' ; } >&${progressInstalledPipe} ) | sed -u '/^&&&\|^###/d' | sed -u -r 's/^%%%(.*)$/\1%/'
            # first, we tee the output for zenity, leaving only lines starting with %%% (progress) and ### (dialog text update)
            # next is the tee for progressInstalled variable output, we filter only lines staring with &&& - the sed is buffered (important)
            # all other output is filtered and modified through sed for script stdout - we don't need progressInstalled (&&&) or zenity (###) lines and also make progress (%%%) lines nicer

            installResult=${PIPESTATUS[0]} # result

            # read progressInstalled from pipe, leave only last line, remove first | characters and close the pipe
            progressInstalled=$(sed -ne '/^-EOF-$/q;p' <&${progressInstalledPipe})
            exec {progressInstalledPipe}<&- 
            progressInstalled=$(echo "$progressInstalled" | tail -n1 | sed -u 's/^[|]*//')
            echo "User installed: $progressInstalled"

            if [ $installResult != 0 ] ; then
                echo "Update cancelled!"
            else
                echo "Update complete!"
            fi
        fi
    fi
else
    zenity --error --width=250 --text="Nothing available to be updated." 2>/dev/null
fi
