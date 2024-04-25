#!/usr/bin/bash

LINK=https://www.dropout.tv/browse

source ./cloud.conf
"/usr/bin/flatpak" run ${FLATPAKOPTIONS} ${BROWSERAPP} @@u @@ ${BROWSEROPTIONS} ${LINK}
