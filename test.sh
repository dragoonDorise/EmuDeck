#!/usr/bin/env bash

# shellcheck disable=1091
. "${HOME}/.config/EmuDeck/backend/functions/all.sh"

Lime3DS_IsInstalled () {
    # shellcheck disable=2154
    if [ -e "${Lime3DS_emuPath}" ]; then
        echo "true"
    else
        echo "false"
    fi
}
echo "${Lime3DS_emuPath}"
Lime3DS_IsInstalled