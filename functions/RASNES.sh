#!/bin/bash
RASNES() {
	if [ "$SNESAR" == 43 ]; then
		cp "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes43.cfg" "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes.cfg"
	else
		cp "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes87.cfg" "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes.cfg"
	fi
}
