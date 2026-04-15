#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "shadps4"
emuName="Shadps4-qt" #parameterize me
emufolder="$emusFolder" # has to be applications for ES-DE to find it

#initialize execute array
exe=()

#find full path to emu executable
exe_path=$(find "$ShadPS4_emuPath" -iname "${ShadPS4_emuFileName}*.AppImage" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)

#if appimage doesn't exist fall back to flatpak.
if [[ -z "$exe_path" ]]; then
    #flatpak
    flatpakApp=$(flatpak list --app --columns=application | grep "$ShadPS4_emuName")
    #check if flatpakApp is empty
    if [[ -z "$flatpakApp" ]]; then
        echo "Flatpak for '$ShadPS4_emuName' not found."
        exit 1
    fi
    #fill execute array
    exe=("flatpak" "run" "$flatpakApp")
else
    #make sure that file is executable
    chmod +x "$exe_path"
    #fill execute array
    exe=("$exe_path")
fi

fileExtension="${@##*.}"

if [[ $fileExtension == "desktop" ]]; then
    # trying to figure this out... :)
    # In desktop file the Exec line is like this:
    # Exec=/tmp/.mount_ShadpsT3Dso0/usr/bin/shadps4 "/run/media/mmcblk0p1/Emulation/storage/shadps4/games/CUSA01369/eboot.bin"

    # takes desktop file and extracts Exec= line
    shadps4DesktopExec=$(grep -E "^Exec=" "${*}" | sed 's/^Exec=//' | sed 's/%%/%/g')

    # commented, doing it bit different...
    #launchParam="Exec=$shadps4DesktopExec" # construct new Exec= line
    #launchParam=$(echo "$launchParam" | sed "s|^\(Exec=\)[^\"']*\"|\1$emusFolder/Shadps4-qt.AppImage -g \"|" | sed 's/^Exec=//')

    # this removes everything in Exec= line before first " or ' (quotes), keeps everything after that (including the quotes)
    # given example above, result will be: "/run/media/mmcblk0p1/Emulation/storage/shadps4/games/CUSA01369/eboot.bin"
    launchParam=$(echo "$shadps4DesktopExec" | grep -oP '"\K[^"]+(?=")')

    # fallback : si pas trouvé avec guillemets, prend dernier mot
    if [[ -z "$launchParam" ]]; then
        launchParam=$(echo "$shadps4DesktopExec" | awk '{print $NF}')
    fi

    # construct launch args and run
    launch_args=("-g" "$launchParam")
    echo "Launching: ${exe[*]} ${launch_args[*]}"
    "${exe[@]}" "${launch_args[@]}"
else
    #run the executable with the params.
    launch_args=()
    for rom in "${@}"; do
        # Parsers previously had single quotes ("'/path/to/rom'" ), this allows those shortcuts to continue working.
        removedLegacySingleQuotes=$(echo "$rom" | sed "s/^'//; s/'$//")
        launch_args+=("$removedLegacySingleQuotes")
    done

    echo "Launching: ${exe[*]} ${launch_args[*]}"

    if [[ -z "${*}" ]]; then
        echo "ROM not found. Launching $ShadPS4_emuName directly"
        "${exe[@]}"
    else
        echo "ROM found, launching game"
        "${exe[@]}" "${launch_args[@]}"
    fi
fi

cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";
