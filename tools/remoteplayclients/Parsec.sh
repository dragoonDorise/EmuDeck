#!/bin/bash
cd ~/.local/share/flatpak/app/com.parsecgaming.parsec/current/active/files/bin
/usr/bin/flatpak run --branch=stable --arch=x86_64 --file-forwarding com.parsecgaming.parsec @@u @@
