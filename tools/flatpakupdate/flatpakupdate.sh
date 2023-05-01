#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
if [ "$?" == "1" ]; then
    echo "functions could not be loaded."
    zenity --error \
        --text="EmuDeck Functions could not be loaded. Please re-run Emudeck install." 2>/dev/null
    exit
fi

emuTable=()
if [ "$(RetroArch_IsInstalled)" == "true" ]; then
    emuTable+=(TRUE "Multiple" "RetroArch")
fi
if [ "$(Primehack_IsInstalled)" == "true" ]; then
    emuTable+=(TRUE "Metroid Prime" "PrimeHack")
fi
if [ "$(RPCS3_IsInstalled)" == "true" ]; then
    emuTable+=(TRUE "PS3" "RPCS3")
fi
if [ "$(Citra_IsInstalled)" == "true" ]; then
    emuTable+=(TRUE "3DS" "Citra")
fi
if [ "$(Dolphin_IsInstalled)" == "true" ]; then
    emuTable+=(TRUE "GC/Wii" "Dolphin")
fi
if [ "$(DuckStation_IsInstalled)" == "true" ]; then
    emuTable+=(TRUE "PSX" "DuckStation")
fi
if [ "$(PPSSPP_IsInstalled)" == "true" ]; then
    emuTable+=(TRUE "PSP" "PPSSPP")
fi
if [ "$(Xemu_IsInstalled)" == "true" ]; then
    emuTable+=(TRUE "XBox" "Xemu")
fi
if [ "$(ScummVM_IsInstalled)" == "true" ]; then
    emuTable+=(TRUE "Scumm/DOS" "ScummVM")
fi

if [ "$(RMG_IsInstalled)" == "true" ]; then
    emuTable+=(TRUE "N64" "RMG")
fi

if [ "$(melonDS_IsInstalled)" == "true" ]; then
    emuTable+=(TRUE "DS" "melonDS")
fi

if [ "${#emuTable[@]}" -gt 0 ]; then
    #Emulator selector
    text="$(printf "Which Flatpak emulators do you want to update?")"
    emusToInstall=$(zenity --list \
            --title="EmuDeck" \
            --height=500 \
            --width=400 \
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
        if [ -n "$emusToInstall" ]; then
            let pct=$(expr 100 / $(awk -F'|' '{print NF}' <<<"$emusToInstall"))
            echo "pct=$pct"
            let progresspct=0
            : {progressInstalledPipe}<> <(:)

            echo "User selected: $emusToInstall"

            if [[ "$emusToInstall" == *"RetroArch"* ]]; then
                doUpdateRA=true
            fi
            if [[ "$emusToInstall" == *"PrimeHack"* ]]; then
                doUpdatePrimeHack=true
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
            if [[ "$emusToInstall" == *"DuckStation"* ]]; then
                doUpdateDuck=true
            fi
            if [[ "$emusToInstall" == *"PPSSPP"* ]]; then
                doUpdatePPSSPP=true
            fi
            if [[ "$emusToInstall" == *"Xemu"* ]]; then
                doUpdateXemu=true
            fi
            if [[ "$emusToInstall" == *"ScummVM"* ]]; then
                doUpdateScummVM=true
            fi
            if [[ "$emusToInstall" == *"MelonDS"* ]]; then
            	doUpdateMelonDS=true
            fi
            if [[ "$emusToInstall" == *"RMG"* ]]; then
            	doUpdateRMG=true
            fi

            (
                progressInstalled=""
                if [ "$doUpdateRA" == "true" ]; then
                    echo "###Updating RetroArch..."
                    (updateEmuFP "RetroArch" "org.libretro.RetroArch" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|RetroArch" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdatePrimeHack" == "true" ]; then
                    echo "###Updating PrimeHack..."
                    (updateEmuFP "PrimeHack" "io.github.shiiion.primehack" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|PrimeHack" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdateRPCS3" == "true" ]; then
                    echo "###Updating RPCS3..."
                    (updateEmuFP "RPCS3" "net.rpcs3.RPCS3" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|RPCS3" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdateCitra" == "true" ]; then
                    echo "###Updating Citra..."
                    (updateEmuFP "Citra" "org.citra_emu.citra" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|Citra" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdateDolphin" == "true" ]; then
                    echo "###Updating Dolphin..."
                    (updateEmuFP "dolphin-emu" "org.DolphinEmu.dolphin-emu" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|Dolphin" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdateDuck" == "true" ]; then
                    echo "###Updating DuckStation..."
                    (updateEmuFP "DuckStation" "org.duckstation.DuckStation" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|DuckStation" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdatePPSSPP" == "true" ]; then
                    echo "###Updating PPSSPP..."
                    (updateEmuFP "PPSSPP" "org.ppsspp.PPSSPP" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|PPSSPP" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdateXemu" == "true" ]; then
                    echo "###Updating Xemu..."
                    (updateEmuFP "Xemu-Emu" "app.xemu.xemu" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|Xemu" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdateScummVM" == "true" ]; then
                    echo "###Updating ScummVM..."
                    (updateEmuFP "ScummVM" "org.scummvm.ScummVM" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|ScummVM" && echo "&&&$progressInstalled"
                fi
                if [ "$doUpdateMelonDS" == "true" ]; then
                    echo "###Updating melonDS..."
                    (updateEmuFP "melonDS" "net.kuribo64.melonDS" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|melonDS" && echo "&&&$progressInstalled"
                fi

                if [ "$doUpdateRMG" == "true" ]; then
                    echo "###Updating RMG..."
                    (updateEmuFP "RMG" "com.github.Rosalie241.RMG" || true) && let progresspct+=$pct && echo "%%%$progresspct" && progressInstalled+="|RMG" && echo "&&&$progressInstalled"
                fi

                if [ $progresspct != 100 ]; then
                    progresspct=100
                    echo "%%%$progresspct"
                fi
                echo "###Flatpaks update complete!"
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
                echo "Flatpaks update cancelled!"
            else
                echo "Flatpaks update done!"
            fi
        fi
    fi
else
    zenity --error --width=250 --text="Nothing available to be updated." 2>/dev/null
fi
