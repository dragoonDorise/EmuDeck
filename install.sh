#!/bin/bash

set -e

EMUDECK_GITHUB_URL="https://api.github.com/repos/EmuDeck/emudeck-electron/releases/latest"
EMUDECK_URL="$(curl -s ${EMUDECK_GITHUB_URL} | grep -E 'browser_download_url.*AppImage' | cut -d '"' -f 4)"

mkdir -p ~/Applications
curl -L "${EMUDECK_URL}" > ~/Applications/EmuDeck.AppImage
chmod +x ~/Applications/EmuDeck.AppImage
~/Applications/EmuDeck.AppImage
