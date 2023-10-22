#!/usr/bin/bash

LINK="https://play.pocketcasts.com"

source ./cloud.conf
"/usr/bin/flatpak" run ${FLATPAKOPTIONS} ${BROWSERAPP} @@u @@ ${BROWSEROPTIONS} ${LINK}
