#!/usr/bin/bash

LINK="https://emby.media/"

"/usr/bin/flatpak" run --branch=stable --arch=x86_64 --command=/app/bin/chrome --file-forwarding com.google.Chrome @@u @@ --window-size=1024,640 --force-device-scale-factor=1.25 --device-scale-factor=1.25 --kiosk "${LINK}"
