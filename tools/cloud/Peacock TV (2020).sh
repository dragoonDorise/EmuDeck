#!/usr/bin/bash

LINK="https://www.peacocktv.com/"

. ./cloud.conf
"/usr/bin/flatpak" run --branch=stable --arch=x86_64 --command=${COMMAND} --file-forwarding ${BROWSERAPP} @@u @@ --window-size=${WINDOWSIZE} --force-device-scale-factor=${DEVICESCALEFACTOR} --device-scale-factor=${DEVICESCALEFACTOR} --kiosk "${LINK}"
