#!/usr/bin/bash

LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8
LC_TIME=en_US.UTF-8

EMU="Vita3K"
LAUNCH="../emu-launch.sh"

"${LAUNCH}" "${EMU}" "${@}"
