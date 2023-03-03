#!/bin/bash
#while this is in testing, i'm copying in the functions. once we leave the original repo in place and don't delete it, i'd like to use the functions we already made.

# shellcheck source=functions/all.sh
source "$HOME/.config/EmuDeck/backend/functions/all.sh"
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

    releaseTable+=(false "$(getReleaseURLGH "cemu-project/Cemu" "windows-x64.zip")")

    local releaseChoice=""
    if [ ${#releaseTable[@]} != 0 ]; then
        releaseChoice=$(
            zenity --list \
            --title="EmuDeck" \
            --height=500 \
            --width=500 \
            --ok-label="OK" \
            --cancel-label="Exit" \
            --text="Choose your Cemu version." \
            --radiolist \
            --column="Select" \
            --column="Release" \
            "${releaseTable[@]}" 2>/dev/null
        )
    fi

    if [ ! -z "$releaseChoice" ]; then
        #curl -L "$releaseChoice" --output "$romsPath/wiiu/cemu.zip" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading" --width 600 --auto-close --no-cancel 2>/dev/null
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

#begin script
#paths update via sed in main script
#source the all.sh, these should be pulled correctly!
scriptPath="${toolsPath}/binupdate"

#initialize log
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
LOGFILE="${scriptPath}/binupdate-$TIMESTAMP.log"
exec > >(tee "${LOGFILE}") 2>&1

binTable=()
binTable+=(TRUE "EmulationStation-DE" "esde")
binTable+=(TRUE "Steam Rom Manager" "srm")
binTable+=(TRUE "GameBoy / Color / Advance" "mgba")
binTable+=(TRUE "Nintendo Switch Emu" "yuzu")
binTable+=(TRUE "Nintendo Switch Emu" "ryujinx")
binTable+=(TRUE "Sony PlayStation 2 Emu" "pcsx2-qt")
binTable+=(TRUE "Nintendo WiiU Emu (Proton)" "cemu (win/proton)")
binTable+=(TRUE "Nintendo WiiU Emu (Native)" "cemu (native)")
binTable+=(TRUE "Sony PlayStation Vita Emu" "vita3k")
binTable+=(FALSE "Xbox 360 Emu - TESTING ONLY" "xenia")

#Binary selector
text="$(printf "What tools do you want to get the latest version of?\n This tool will simply overwrite what you have with the newest available.")"
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
    echo $binsToDL
    awk -F'|' '{print NF}' <<<"$binsToDL"
    let pct=$(expr 100 / $(awk -F'|' '{print NF}' <<<"$binsToDL"))
    echo $pct
    let progresspct=0


        echo "User selected: $binsToDL"
        if [[ "$binsToDL" == *"esde"* ]]; then
            let progresspct+=$pct
            echo "$progresspct"
            echo "# Updating esde"
            #if ESDE_install 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading" --width 600 --auto-close --no-cancel 2>/dev/null; then
            if ESDE_install "true" 2>&1; then
                messages+=("EmulationStation-DE Updated Successfully")
            else
                messages+=("There was a problem updating EmulationStation-DE")
            fi
        fi
        if [[ "$binsToDL" == *"srm"* ]]; then
            let progresspct+=$pct
            echo "$progresspct"
            echo "# Updating srm"
            #if SRM_install 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading" --width 600 --auto-close --no-cancel 2>/dev/null; then
            if SRM_install "true" 2>&1; then
                messages+=("SteamRomManager Updated Successfully")
            else
                messages+=("There was a problem updating SteamRomManager")
            fi
        fi
        if [[ "$binsToDL" == *"mgba"* ]]; then
            let progresspct+=$pct
            echo "$progresspct"
            echo "# Updating mgba"
            #if MGBA_install 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading" --width 600 --auto-close --no-cancel 2>/dev/null; then
            if MGBA_install "true" 2>&1; then
                messages+=("mGBA Updated Successfully")
            else
                messages+=("There was a problem updating mGBA")
            fi
        fi
        if [[ "$binsToDL" == *"yuzu"* ]]; then
            let progresspct+=$pct
            echo "$progresspct"
            echo "# Updating yuzu"
            ##if Yuzu_install 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading" --width 600 --auto-close --no-cancel 2>/dev/null; then
            if Yuzu_install "true" 2>&1; then
                messages+=("Yuzu Updated Successfully")
            else
                messages+=("There was a problem updating Yuzu")
            fi
        fi
        if [[ "$binsToDL" == *"pcsx2-qt"* ]]; then
            let progresspct+=$pct
            echo "$progresspct"
            echo "# Updating pcsx2-qt"
            #if PCSX2QT_install 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading" --width 600 --auto-close --no-cancel 2>/dev/null; then
            if PCSX2QT_install "true" 2>&1; then
                messages+=("PCSX2-QT Updated Successfully")
            else
                messages+=("There was a problem updating PCSX2-QT")
            fi
        fi
        if [[ "$binsToDL" == *"ryujinx"* ]]; then
            let progresspct+=$pct
            echo "$progresspct"
            echo "# Updating ryujinx"
            #if Ryujinx_install 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading" --width 600 --auto-close --no-cancel 2>/dev/null; then
            if Ryujinx_install "true" 2>&1; then
                messages+=("Ryujinx Updated Successfully")
            else
                messages+=("There was a problem updating Ryujinx")
            fi
        fi
        if [[ "$binsToDL" == *"cemu (win/proton)"* ]]; then
            let progresspct+=$pct
            echo "$progresspct"
            echo "# Updating cemu"
            if updateCemu "true" 2>&1; then
                messages+=("Cemu (win/proton) Updated Successfully")
            else
                messages+=("There was a problem updating Cemu (win/proton")
            fi
        fi
        if [[ "$binsToDL" == *"cemu (native)"* ]]; then
            let progresspct+=$pct
            echo "$progresspct"
            echo "# Updating cemu"
            if CemuNative_install "true" 2>&1; then
                messages+=("Cemu (Native) Updated Successfully")
            else
                messages+=("There was a problem updating Cemu (Native)")
            fi
        fi
        if [[ "$binsToDL" == *"vita3k"* ]]; then
            let progresspct+=$pct
            echo "$progresspct"
            echo "# Updating vita3k"
            if Vita3K_install "true" 2>&1; then
                messages+=("Vita3K Updated Successfully")
            else
                messages+=("There was a problem updating Vita3K")
            fi
        fi
        if [[ "$binsToDL" == *"xenia"* ]]; then
            let progresspct+=$pct
            echo "$progresspct"
            echo "# Updating xenia"
            zenity --question \
            --title="Xenia Version" \
            --width=250 \
            --ok-label="Master (stable)" \
            --cancel-label="Canary (experimental)" \
            --text="Which build would you like? " 2>/dev/null
            ans=$?
            if [[ $ans == 0 ]]; then
                #if Xenia_install "master" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading" --width 600 --auto-close --no-cancel 2>/dev/null; then
                if Xenia_install "master" "true" 2>&1; then
                    messages+=("Xenia Updated Successfully")
                else
                    messages+=("There was a problem updating Xenia")
                fi
            else
                #if Xenia_install "canary" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading" --width 600 --auto-close --no-cancel 2>/dev/null; then
                if Xenia_install "canary" "true" 2>&1; then
                    messages+=("Xenia Updated Successfully")
                else
                    messages+=("There was a problem updating Xenia")
                fi
            fi

            progresspct=100
            echo "$progresspct"
            echo "# Complete!"
        fi


    if [ "$?" = -1 ]; then
        zenity --error \
        --text="Update canceled." 2>/dev/null
    fi
    if [[ ${#messages[@]} -gt 0 ]]; then
        zenity --list \
        --title="Update Status" \
        --text="" \
        --column="Messages" \
        "${messages[@]}" 2>/dev/null
    fi
fi
