#!/usr/bin/bash

LINK="https://www.crave.ca/"

source ./cloud.conf
"/usr/bin/flatpak" run ${FLATPAKOPTIONS} ${BROWSERAPP} @@u @@ ${BROWSEROPTIONS} ${LINK}
