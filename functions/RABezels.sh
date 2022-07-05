#!/bin/bash
RABezels() {
	if [ "$RABezels" == true ]; then
		find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.bak" | while read f; do mv -v "$f" "${f%.*}.cfg"; done
	else
		find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.cfg" | while read f; do mv -v "$f" "${f%.*}.bak"; done
	fi
}
