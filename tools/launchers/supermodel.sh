#!/bin/sh
cd "$HOME/.config/EmuDeck/backend/"
git pull
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
launcherInit
emulatorInit "supermodel"
param="${@}"
param=$(echo "$param" | sed "s|'||g")

if [ "${XDG_CURRENT_DESKTOP}" = "KDE" ]; then
    flatpak run --nosocket=wayland --nosocket=fallback-x11 --socket=x11 --env=SDL_VIDEODRIVER=x11 com.supermodel3.Supermodel "${param}"
else
    flatpak run com.supermodel3.Supermodel "${param}"
fi

cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";
