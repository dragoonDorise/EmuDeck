#!/usr/bin/bash

LINK="https://discord.com/"

source ./cloud.conf
"/usr/bin/flatpak" run ${FLATPAKOPTIONS} ${BROWSERAPP} @@u @@ ${BROWSEROPTIONS} ${LINK}
