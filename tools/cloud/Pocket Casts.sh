#!/usr/bin/bash

LINK="https://play.pocketcasts.com"

# shellcheck source=./cloud.conf
source ./cloud.conf

"/usr/bin/flatpak" run "${FLATPAKOPTIONS}" "${BROWSERAPP}" @@u @@ "${BROWSEROPTIONS}" ${LINK}
