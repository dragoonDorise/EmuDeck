#!/bin/bash
setWide(){		
	if [ $duckWide == true ]; then	
		sed -i "s|WidescreenHack = false|WidescreenHack = true|g" ~/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini 
	else
		sed -i "s|WidescreenHack = true|WidescreenHack = false|g" ~/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini 
	fi
	if [ $DolphinWide == true ]; then
		sed -i "s|wideScreenHack = False|wideScreenHack = True|g" ~/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini 
	else
		sed -i "s|wideScreenHack = True|wideScreenHack = False|g" ~/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini 
	fi
	if [ $DreamcastWide == true ]; then
		sed -i "s|reicast_widescreen_hack = \"disabled\"|reicast_widescreen_hack = \"enabled\"|g" ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Flycast/Flycast.opt 
	else
		sed -i "s|reicast_widescreen_hack = \"enabled\"|reicast_widescreen_hack = \"disabled\"|g" ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Flycast/Flycast.opt 
	fi
	
	if [ $BeetleWide == true ]; then
		sed -i "s|beetle_psx_hw_widescreen_hack = \"disabled\"|beetle_psx_hw_widescreen_hack = \"enabled\"|g" "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/config/Beetle PSX HW/Beetle PSX HW.opt" 
	else
		sed -i "s|beetle_psx_hw_widescreen_hack = \"enabled\"|beetle_psx_hw_widescreen_hack = \"disabled\"|g" "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/config/Beetle PSX HW/Beetle PSX HW.opt" 
	fi
}