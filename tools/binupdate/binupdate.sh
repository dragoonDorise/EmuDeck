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
                --text="Choose your Cemu (windows) version. 2.0 is now recommended" \
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
    if [[ "$binsToDL" == *"cemu (win/proton)"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating Cemu (win/proton)"
        if CemuProton_install "true" 2>&1; then
            messages+=("Cemu (win/proton) Updated Successfully")
        else
            messages+=("There was a problem updating Cemu (win/proton")
        fi
    fi
    if [[ "$binsToDL" == *"cemu (native)"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating Cemu (Native)"
        if Cemu_install "true" 2>&1; then
            messages+=("Cemu (Native) Updated Successfully")
        else
            messages+=("There was a problem updating Cemu (Native)")
        fi
    fi
    if [[ "$binsToDL" == *"es-de"* ]]; then
        echo "0"
        echo "# Updating ES-DE"
        if ESDE_install "true" 2>&1; then
            messages+=("ES-DE Updated Successfully")
        else
            messages+=("There was a problem updating ES-DE")
        fi
    fi
    if [[ "$binsToDL" == *"mgba"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating mGBA"
        if mGBA_install "true" 2>&1; then
            messages+=("mGBA Updated Successfully")
        else
            messages+=("There was a problem updating mGBA")
        fi
    fi
    if [[ "$binsToDL" == *"pcsx2-qt"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating PCSX2-QT"
        if PCSX2QT_install "true" 2>&1; then
            messages+=("PCSX2-QT Updated Successfully")
        else
            messages+=("There was a problem updating PCSX2-QT")
        fi
    fi
    if [[ "$binsToDL" == *"rpcs3"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating RPCS3"
        if RPCS3_install "true" 2>&1; then
            messages+=("RPCS3 Updated Successfully")
        else
            messages+=("There was a problem updating RPCS3")
        fi
    fi
    if [[ "$binsToDL" == *"ryujinx"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating Ryujinx"
        if Ryujinx_install "true" 2>&1; then
            messages+=("Ryujinx Updated Successfully")
        else
            messages+=("There was a problem updating Ryujinx")
        fi
    fi
    if [[ "$binsToDL" == *"srm"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating SteamRomManager"
        if SRM_install "true" 2>&1; then
            messages+=("Steam ROM Manager Updated Successfully")
        else
            messages+=("There was a problem updating Steam ROM Manager")
        fi
    fi
    if [[ "$binsToDL" == *"vita3k"* ]]; then
        ((progresspct += pct)) || true
        echo "$progresspct"
        echo "# Updating Vita3K"
        if Vita3K_install "true" 2>&1; then
            messages+=("Vita3K Updated Successfully")
        else
            messages+=("There was a problem updating Vita3K")
        fi
    fi
    if [[ "$binsToDL" == *"xenia"* ]]; then
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

binTable=()
if [ "$(BigPEmu_IsInstalled ""$emuDeckEmuTypeWindows"")" == "true" ]; then
    binTable+=(TRUE "Atari Jaguar" "BigPEmu (Proton)")
fi
if [ "$(CemuProton_IsInstalled ""$emuDeckEmuTypeWindows"")" == "true" ]; then
    binTable+=(TRUE "Nintendo Wii U (Proton)" "cemu (win/proton)")
fi
if [ "$(Cemu_IsInstalled ""$emuDeckEmuTypeAppImage"")" == "true" ]; then
    binTable+=(TRUE "Nintendo Wii U (Native)" "cemu (native)")
fi
if [ "$(ESDE_IsInstalled ""$emuDeckEmuTypeAppImage"")" == "true" ]; then
    binTable+=(TRUE "ES-DE" "es-de")
fi
if [ "$(mGBA_IsInstalled ""$emuDeckEmuTypeAppImage"")" == "true" ]; then
    binTable+=(TRUE "Nintendo GB, GB, and GBC" "mgba")
fi
if [ "$(PCSX2QT_IsInstalled ""$emuDeckEmuTypeAppImage"")" == "true" ]; then
    binTable+=(TRUE "Sony PlayStation 2" "pcsx2-qt")
fi
if [ "$(RPCS3_IsInstalled ""$emuDeckEmuTypeAppImage"")" == "true" ]; then
    binTable+=(TRUE "Sony PlayStation 3" "rpcs3")
fi
if [ "$(Ryujinx_IsInstalled ""$emuDeckEmuTypeBinary"")" == "true" ]; then
    binTable+=(TRUE "Nintendo Switch" "ryujinx")
fi
if [ "$(SRM_IsInstalled ""$emuDeckEmuTypeAppImage"")" == "true" ]; then
    binTable+=(TRUE "Steam ROM Manager" "srm")
fi
if [ "$(Vita3K_IsInstalled ""$emuDeckEmuTypeBinary"")" == "true" ]; then
    binTable+=(TRUE "Sony PlayStation Vita" "vita3k")
fi
if [ "$(Xenia_IsInstalled ""$emuDeckEmuTypeWindows"")" == "true" ]; then
    binTable+=(TRUE "Microsoft Xbox 360" "xenia")
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
            --column="System" \
            --column="Name" \
            --print-column=3 \
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
