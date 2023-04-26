#!/bin/bash

set -eo pipefail

report_error() {
    FAILURE="$(caller): ${BASH_COMMAND}"
    echo "Something went wrong!"
    echo "Error at ${FAILURE}"
}

trap report_error ERR

EMUDECK_GITHUB_URL="https://api.github.com/repos/EmuDeck/emudeck-electron/releases/latest"
EMUDECK_URL="$(curl -s ${EMUDECK_GITHUB_URL} | grep -E 'browser_download_url.*AppImage' | cut -d '"' -f 4)"

mkdir -p ~/Applications
curl -L "${EMUDECK_URL}" -o ~/Applications/EmuDeck.AppImage 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading EmuDeck" --width 600 --auto-close --no-cancel 2>/dev/null
chmod +x ~/Applications/EmuDeck.AppImage
~/Applications/EmuDeck.AppImage
