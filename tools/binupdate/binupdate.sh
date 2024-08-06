#!/bin/bash
#while this is in testing, i'm copying in the functions. once we leave the original repo in place and don't delete it, i'd like to use the functions we already made.

# shellcheck source=functions/all.sh
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
if [ "$?" == "1" ]; then
    echo "functions could not be loaded."
    zenity --error \
        --text="EmuDeck Functions could not be loaded. Please re-run Emudeck install." 2>/dev/null
    exit
fi

updateCemu() {
    local showProgress="$1"

    local releasesStr=$(curl -sL https://cemu.info | awk 'BEGIN{
            RS="</a>"
            IGNORECASE=1
            }
            {
            for(o=1;o<=NF;o++){
                if ( $o ~ /href/){
                gsub(/.*href=\042/,"",$o)
                gsub(/\042.*/,"",$o)
                print $(o)
                }
            }
            }' | grep releases | grep -v github)

    mapfile -t releases <<<"$releasesStr"

    local releaseTable=()
    for release in "${releases[@]}"; do
        releaseTable+=(false "$release")
        echo "release: $release"
    done
    releaseTable+=(false "https://cemu.info/releases/cemu_1.27.1.zip")
    releaseTable+=(false "$(getReleaseURLGH "cemu-project/Cemu" "windows-x64.zip")")

    local releaseChoice=""
    if [ ${#releaseTable[@]} != 0 ]; then
        releaseChoice=$(
            zenity --list \
                --title="EmuDeck" \
                --height=500 \
                --width=800 \
                --ok-label="OK" \
                --cancel-label="Exit" \
                --text="Select your Cemu (Windows) version. 2.0 is recommended" \
                --radiolist \
                --column="Select" \
                --column="Release" \
                "${releaseTable[@]}" 2>/dev/null
        )
    fi

    if [ -n "$releaseChoice" ]; then
        if safeDownload "cemu" "$releaseChoice" "$romsPath/wiiu/cemu.zip" "$showProgress"; then
            mkdir -p "$romsPath/wiiu/tmp"
            unzip -o "$romsPath/wiiu/cemu.zip" -d "$romsPath/wiiu/tmp"
            mv "$romsPath"/wiiu/tmp/[Cc]emu_*/ "$romsPath/wiiu/tmp/cemu/" #don't quote the *
            rsync -avzh "$romsPath/wiiu/tmp/cemu/" "$romsPath/wiiu/"
            rm -rf "$romsPath/wiiu/tmp"
            rm -f "$romsPath/wiiu/cemu.zip"
            return 0
        fi
    fi

    return 1
}

function runBinDownloads {
    local binsToDL=$1

    progresspct=0

    numBins=$(awk -F'|' '{print NF}' <<<"$binsToDL")
    pct=$((100 / (numBins + 1)))

    echo "User selected: $binsToDL"

    if [[ "$binsToDL" == *"BigPEmu (Proton)"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating BigPEmu (Proton)"
        if BigPEmu_install "true" 2>&1; then
            messages+=("BigPEmu (Proton) Updated Successfully")
        else
            messages+=("There was a problem updating BigPEmu (Proton)")
        fi
    fi
    if [[ "$binsToDL" == *"Cemu (Proton)"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating Cemu (win/proton)"
        if CemuProton_install "true" 2>&1; then
            messages+=("Cemu (win/proton) Updated Successfully")
        else
            messages+=("There was a problem updating Cemu (win/proton")
        fi
    fi
    if [[ "$binsToDL" == *"Cemu (Native)"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating Cemu (Native)"
        if Cemu_install "true" 2>&1; then
            messages+=("Cemu (Native) Updated Successfully")
        else
            messages+=("There was a problem updating Cemu (Native)")
        fi
    fi
    if [[ "$binsToDL" == *"Citra"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating Citra"
        if Citra_install "true" 2>&1; then
            messages+=("Citra Updated Successfully")
        else
            messages+=("There was a problem updating Citra")
        fi
    fi
    if [[ "$binsToDL" == *"ES-DE"* ]]; then
        echo "0"
        echo "# Updating ES-DE"
        if ESDE_install "true" 2>&1; then
            messages+=("ES-DE Updated Successfully")
        else
            messages+=("There was a problem updating ES-DE")
        fi
    fi
    if [[ "$binsToDL" == *"Lime3DS"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating Lime3DS"
        if Lime3DS_install "true" 2>&1; then
            messages+=("Lime3DS Updated Successfully")
        else
            messages+=("There was a problem updating Lime3DS")
        fi
    fi
    if [[ "$binsToDL" == *"mGBA"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating mGBA"
        if mGBA_install "true" 2>&1; then
            messages+=("mGBA Updated Successfully")
        else
            messages+=("There was a problem updating mGBA")
        fi
    fi
    if [[ "$binsToDL" == *"PCSX2"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating PCSX2"
        if PCSX2QT_install "true" 2>&1; then
            messages+=("PCSX2Updated Successfully")
        else
            messages+=("There was a problem updating PCSX2")
        fi
    fi
    if [[ "$binsToDL" == *"RPCS3"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating RPCS3"
        if RPCS3_install "true" 2>&1; then
            messages+=("RPCS3 Updated Successfully")
        else
            messages+=("There was a problem updating RPCS3")
        fi
    fi
    if [[ "$binsToDL" == *"Ryujinx"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating Ryujinx"
        if Ryujinx_install "true" 2>&1; then
            messages+=("Ryujinx Updated Successfully")
        else
            messages+=("There was a problem updating Ryujinx")
        fi
    fi
    if [[ "$binsToDL" == *"Steam ROM Manager"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating SteamRomManager"
        if SRM_install "true" 2>&1; then
            messages+=("Steam ROM Manager Updated Successfully")
        else
            messages+=("There was a problem updating Steam ROM Manager")
        fi
    fi
    if [[ "$binsToDL" == *"Vita3K"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating Vita3K"
        if Vita3K_install "true" 2>&1; then
            messages+=("Vita3K Updated Successfully")
        else
            messages+=("There was a problem updating Vita3K")
        fi
    fi
    if [[ "$binsToDL" == *"Xenia (Proton)"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating Xenia-Canary"
        if Xenia_install "canary" "true" 2>&1; then
            messages+=("Xenia Updated Successfully")
        else
            messages+=("There was a problem updating Xenia")
        fi
    fi
    echo "100"
    echo "# Complete!"
}

#begin script
#source the all.sh, these should be pulled correctly!
scriptPath="${toolsPath}/binupdate"

#initialize log
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
LOGFILE="${scriptPath}/binupdate-$TIMESTAMP.log"
exec > >(tee "${LOGFILE}") 2>&1

declare -a binTable

binTable=()
if [ "$(BigPEmu_IsInstalled ""$emuDeckEmuTypeWindows"")" == "true" ]; then
    binTable+=(TRUE "BigPEmu (Proton)" "Atari Jaguar and Jaguar CD")
else
    binTable+=(FALSE "BigPEmu (Proton)" "Atari Jaguar and Jaguar CD")
fi
if [ "$(CemuProton_IsInstalled ""$emuDeckEmuTypeWindows"")" == "true" ]; then
    binTable+=(TRUE "Cemu (Proton)" "Nintendo Wii U")
else
    binTable+=(FALSE "Cemu (Proton)" "Nintendo Wii U")
fi
if [ "$(Cemu_IsInstalled ""$emuDeckEmuTypeAppImage"")" == "true" ]; then
    binTable+=(TRUE "Cemu (Native)" "Nintendo Wii U")
else
    binTable+=(FALSE "Cemu (Native)" "Nintendo Wii U")
fi
if [ "$(Citra_IsInstalled ""$emuDeckEmuTypeAppImage"")" == "true" ]; then
    binTable+=(TRUE "Citra" "Nintendo 3DS")
else
    binTable+=(FALSE "Citra" "Nintendo 3DS")
fi
if [ "$(ESDE_IsInstalled ""$emuDeckEmuTypeAppImage"")" == "true" ]; then
    binTable+=(TRUE "ES-DE" "Emulator Front-End")
else
    binTable+=(FALSE "ES-DE" "Emulator Front-End")
fi
if [ "$(Lime3DS_IsInstalled ""$emuDeckEmuTypeAppImage"")" == "true" ]; then
    binTable+=(TRUE "Lime3DS" "Nintendo 3DS")
else
    binTable+=(FALSE "Lime3DS" "Nintendo 3DS")
fi
if [ "$(mGBA_IsInstalled ""$emuDeckEmuTypeAppImage"")" == "true" ]; then
    binTable+=(TRUE "mGBA" "Nintendo Game Boy Family")
else
    binTable+=(FALSE "mGBA" "Nintendo Game Boy Family")
fi
if [ "$(PCSX2QT_IsInstalled ""$emuDeckEmuTypeAppImage"")" == "true" ]; then
    binTable+=(TRUE "PCSX2" "Sony PlayStation 2")
else
    binTable+=(FALSE "PCSX2" "Sony PlayStation 2")
fi
if [ "$(RPCS3_IsInstalled ""$emuDeckEmuTypeAppImage"")" == "true" ]; then
    binTable+=(TRUE "RPCS3" "Sony PlayStation 3")
else
    binTable+=(FALSE "RPCS3" "Sony PlayStation 3")
fi
if [ "$(Ryujinx_IsInstalled ""$emuDeckEmuTypeBinary"")" == "true" ]; then
    binTable+=(TRUE "Ryujinx" "Nintendo Switch")
else
    binTable+=(FALSE "Ryujinx" "Nintendo Switch")
fi
if [ "$(SRM_IsInstalled ""$emuDeckEmuTypeAppImage"")" == "true" ]; then
    binTable+=(TRUE "Steam ROM Manager" "Emulation Tool")
else
    binTable+=(FALSE "Steam ROM Manager" "Emulation Tool")
fi
if [ "$(Vita3K_IsInstalled ""$emuDeckEmuTypeBinary"")" == "true" ]; then
    binTable+=(TRUE "Vita3K" "Sony PlayStation Vita")
else
    binTable+=(FALSE "Vita3K" "Sony PlayStation Vita")
fi
if [ "$(Xenia_IsInstalled ""$emuDeckEmuTypeWindows"")" == "true" ]; then
    binTable+=(TRUE "Xenia (Proton)" "Microsoft Xbox 360")
else
    binTable+=(FALSE "Xenia (Proton)" "Microsoft Xbox 360")
fi

if [ "${#binTable[@]}" -gt 0 ]; then
    #Binary selector
    text="$(printf "Which emulators or tools would you like to update?\n Any updated emulators or tools will be overwritten with the latest available version.")"
    binsToDL=$(
        zenity --list \
            --title="EmuDeck" \
            --height=500 \
            --width=250 \
            --ok-label="OK" \
            --cancel-label="Exit" \
            --text="${text}" \
            --checklist \
            --column="Select" \
            --column="Emulator" \
            --column="System" \
            --print-column=2 \
            "${binTable[@]}" 2>/dev/null
    )
    ans=$?
    messages=()
    if [ $ans -eq 0 ]; then
        if [ -n "$binsToDL" ]; then

            runBinDownloads "$binsToDL" | zenity --progress --pulsate --title="Updating!" --width=600 --height=250 2>/dev/null

            if [ "$?" = -1 ]; then
                zenity --error \
                    --text="Update canceled." 2>/dev/null
            fi
            if [[ ${#messages[@]} -gt 0 ]]; then
                zenity --list \
                    --title="Update Status" \
                    --text="" \
                    --width=400 \
                    --height=500 \
                    --column="Messages" \
                    "${messages[@]}" 2>/dev/null
            fi
        fi
    fi
else

    zenity --error \
        --text="Nothing available to be updated." 2>/dev/null
fi

