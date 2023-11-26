#!/bin/bash

nonDeck_169Screen(){

	#Redo this using livedeth fancy functions for RA
	#RetroArch_setOverride 'wswanc.cfg' 'Beetle Cygne'  'aspect_ratio_index' '"21"'
	
	setMSG "Applying RetroArch bezel corrections for 16:9 screens"		
	#RApath=~/.var/app/org.libretro.RetroArch/config/retroarch/config/	
	
	#Mesen
	#Nestopia
	# mesenPath="${RApath}Mesen/"
	# nestopiaPath="${RApath}Nestopia/"	
	
	# sed -i "s|input_overlay_scale_landscape = \"1.070000\"|input_overlay_scale_landscape = \"1.055000\"|" "${nestopiaPath}nes.cfg"
	# sed -i "s|input_overlay_aspect_adjust_landscape = \"0.000000\"|input_overlay_aspect_adjust_landscape = \"-0.090000\"|" "${nestopiaPath}nes.cfg"
	
	# sed -i "s|input_overlay_scale_landscape = \"1.070000\"|input_overlay_scale_landscape = \"1.055000\"|" "${mesenPath}nes.cfg"
	# sed -i "s|input_overlay_aspect_adjust_landscape = \"0.000000\"|input_overlay_aspect_adjust_landscape = \"-0.090000\"|" "${mesenPath}nes.cfg"

	find "$RetroArch_coreConfigFolders" -type f -name "nes.cfg"| while read -r configFile
	do

		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.055000"'
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "0.000000"'	

	done
	
	#Beetle PCE Fast
	#Beetle PCE	
	# PCEPath="${RApath}Beetle PCE Fast/"
	# PCEfastPath="${RApath}Beetle PCE/"		
	# sed -i "s|aspect_ratio_index = \"21\"|aspect_ratio_index = \"0\"|" "${PCEfastPath}pcengine.cfg"
	# sed -i "s|input_overlay_aspect_adjust_landscape = \"-0.130000\"|input_overlay_aspect_adjust_landscape = \"-0.000000\"|" "${PCEfastPath}pcengine.cfg"
	# sed -i "s|input_overlay_scale_landscape = \"1.060000\"|input_overlay_scale_landscape = \"1.055000\"|" "${PCEfastPath}pcengine.cfg"
	# sed -i "s|input_overlay_x_separation_landscape = \"0.010000\"|input_overlay_x_separation_landscape = \"0.000000\"|" "${PCEfastPath}pcengine.cfg"
	
	# sed -i "s|aspect_ratio_index = \"21\"|aspect_ratio_index = \"0\"|" "${PCEPath}pcengine.cfg"
	# sed -i "s|input_overlay_aspect_adjust_landscape = \"-0.130000\"|input_overlay_aspect_adjust_landscape = \"-0.000000\"|" "${PCEPath}pcengine.cfg"
	# sed -i "s|input_overlay_scale_landscape = \"1.060000\"|input_overlay_scale_landscape = \"1.055000\"|" "${PCEPath}pcengine.cfg"
	# sed -i "s|input_overlay_x_separation_landscape = \"0.010000\"|input_overlay_x_separation_landscape = \"0.000000\"|" "${PCEPath}pcengine.cfg"
	

	find "$RetroArch_coreConfigFolders" -type f -name "pcengine.cfg"| while read -r configFile
	do

		updateOrAppendConfigLine "$configFile" "aspect_ratio_index ="  'aspect_ratio_index = "0"'
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "0"'
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.055000"'
		updateOrAppendConfigLine "$configFile" "input_overlay_x_separation_landscape ="  'input_overlay_x_separation_landscape = "0"'

	done

	#Stella		
	# StellaPath="${RApath}Stella/"
	# sed -i "s|input_overlay_aspect_adjust_landscape = \"0.000000\"|input_overlay_aspect_adjust_landscape = \"-0.025000\"|" "${StellaPath}atari800.cfg"
	# sed -i "s|input_overlay_scale_landscape = \"1.175000\"|input_overlay_scale_landscape = \"1.080000\"|" "${StellaPath}atari800.cfg"
	# sed -i "s|input_overlay_aspect_adjust_landscape = \"0.000000\"|input_overlay_aspect_adjust_landscape = \"-0.025000\"|" "${StellaPath}atari2600.cfg"
	# sed -i "s|input_overlay_scale_landscape = \"1.175000\"|input_overlay_scale_landscape = \"1.080000\"|" "${StellaPath}atari2600.cfg"
	# sed -i "s|input_overlay_aspect_adjust_landscape = \"0.000000\"|input_overlay_aspect_adjust_landscape = \"-0.025000\"|" "${StellaPath}atari5200.cfg"
	# sed -i "s|input_overlay_scale_landscape = \"1.175000\"|input_overlay_scale_landscape = \"1.080000\"|" "${StellaPath}atari5200.cfg"
	

	find "$RetroArch_coreConfigFolders" -type f -name "atari800.cfg" -o -type f -name "atari2600.cfg" -o -type f -name "atari5200.cfg"| while read -r configFile
	do

		updateOrAppendConfigLine "$configFile" "aspect_ratio_index ="  'aspect_ratio_index = "0"'
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "0"'
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.055000"'
		updateOrAppendConfigLine "$configFile" "input_overlay_x_separation_landscape ="  'input_overlay_x_separation_landscape = "0"'

	done

	#Beetle NeoPop
	# NeoPopPath="${RApath}Beetle NeoPop/"
	# sed -i "s|input_overlay_scale_landscape = \"1.615000\"|input_overlay_scale_landscape = \"1.575000\"|" "${NeoPopPath}ngpc.cfg"
	# sed -i "s|input_overlay_x_separation_portrait = \"-0.010000\"|input_overlay_x_separation_portrait = \"0.000000\"|" "${NeoPopPath}ngpc.cfg"
	# sed -i "s|input_overlay_y_offset_landscape = \"-0.135000\"|input_overlay_y_offset_landscape = \"-0.130000\"|" "${NeoPopPath}ngpc.cfg"
	# sed -i "s|input_overlay_aspect_adjust_landscape = \"-0.160000\"|input_overlay_aspect_adjust_landscape = \"-0.275000\"|" "${NeoPopPath}ngpc.cfg"

	# sed -i "s|input_overlay_scale_landscape = \"1.615000\"|input_overlay_scale_landscape = \"1.575000\"|" "${NeoPopPath}ngp.cfg"
	# sed -i "s|input_overlay_x_separation_portrait = \"-0.010000\"|input_overlay_x_separation_portrait = \"0.000000\"|" "${NeoPopPath}ngp.cfg"
	# sed -i "s|input_overlay_y_offset_landscape = \"-0.135000\"|input_overlay_y_offset_landscape = \"-0.130000\"|" "${NeoPopPath}ngp.cfg"
	# sed -i "s|input_overlay_aspect_adjust_landscape = \"-0.160000\"|input_overlay_aspect_adjust_landscape = \"-0.275000\"|" "${NeoPopPath}ngp.cfg"
	

	find "$RetroArch_coreConfigFolders" -type f -name "ngpc.cfg" -o -type f -name "ngp.cfg"| while read -r configFile
	do

		updateOrAppendConfigLine "$configFile" "input_overlay_x_separation_portrait ="  'input_overlay_x_separation_portrait = "0"'
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "-0.285000"'
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.605000"'
		updateOrAppendConfigLine "$configFile" "input_overlay_y_offset_landscape ="  'input_overlay_y_offset_landscape = "-0.130000"'

	done

	#Gambatte
	# GambattePath="${RApath}Gambatte/"
	# sed -i "s|input_overlay_scale_landscape = \"1.860000\"|input_overlay_scale_landscape = \"1.670000\"|" "${GambattePath}gb.cfg"
	# sed -i "s|input_overlay_scale_landscape = \"1.870000\"|input_overlay_scale_landscape = \"1.680000\"|" "${GambattePath}gbc.cfg"
	#SameBoy
	# SameBoyPath="${RApath}SameBoy/"
	# sed -i "s|input_overlay_scale_landscape = \"1.860000\"|input_overlay_scale_landscape = \"1.670000\"|" "${SameBoyPath}gb.cfg"
	# sed -i "s|input_overlay_scale_landscape = \"1.870000\"|input_overlay_scale_landscape = \"1.680000\"|" "${SameBoyPath}gbc.cfg"
	find "$RetroArch_coreConfigFolders" -type f -name "gb.cfg"| while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.670000"'
	done

	find "$RetroArch_coreConfigFolders" -type f -name "gbc.cfg"| while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.680000"'
	done
	
	#Genesis Plus GX	
	#GenesisPath="${RApath}Genesis Plus GX/"
	#sed -i "s|input_overlay_aspect_adjust_landscape = \"-0.080000\"|input_overlay_aspect_adjust_landscape = \"-0.200000\"|" "${GenesisPath}gamegear.cfg"
	#sed -i "s|input_overlay_scale_landscape = \"1.170000\"|input_overlay_scale_landscape = \"1.055000\"|" "${GenesisPath}genesis.cfg"
	#sed -i "s|input_overlay_aspect_adjust_landscape = \"0.095000\"|input_overlay_aspect_adjust_landscape = \"-0.010000\"|" "${GenesisPath}genesis.cfg"
	
	#sed -i "s|input_overlay_scale_landscape = \"1.170000\"|input_overlay_scale_landscape = \"1.055000\"|" "${GenesisPath}mastersystem.cfg"	
	#sed -i "s|input_overlay_scale_landscape = \"1.170000\"|input_overlay_scale_landscape = \"1.055000\"|" "${GenesisPath}megacd.cfg"
	#sed -i "s|input_overlay_scale_landscape = \"1.170000\"|input_overlay_scale_landscape = \"1.055000\"|" "${GenesisPath}segacd.cfg"
	
	
	#sed -i "s|input_overlay_aspect_adjust_landscape = \"0.000000\"|input_overlay_aspect_adjust_landscape = \"-0.110000\"|" "${GenesisPath}megacd.cfg"
	#sed -i "s|input_overlay_aspect_adjust_landscape = \"0.000000\"|input_overlay_aspect_adjust_landscape = \"-0.110000\"|" "${GenesisPath}segacd.cfg"
	#Gearsystem
	#GearsystemPath="${RApath}Gearsystem/"
	#sed -i "s|input_overlay_scale_landscape = \"1.545000\"|input_overlay_scale_landscape = \"1.500000\"|" "${GearsystemPath}gamegear.cfg"		### Why is this so different from the other gamegear one? Shouldn't they be using the same overlay? Doesn't make sense? Not implmemented yet.

	find "$RetroArch_coreConfigFolders" -type f -name "gamegear.cfg"| while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "-0.010000"'
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "-0.020000"'
	done

	find "$RetroArch_coreConfigFolders" -type f -name "mastersystem.cfg"| while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.055000"'
	done

	find "$RetroArch_coreConfigFolders" -type f -name "genesis.cfg"  -o -type f -name "megadrive.cfg"| while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.055000"'
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "-0.010000"'
	done

	find "$RetroArch_coreConfigFolders" -type f -name "megacd.cfg" -o -type f -name "segacd.cfg"| while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.055000"'
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "0.000000"'
	done

	#PicoDrive
	#PicoPath="${RApath}PicoDrive/"
	#sed -i "s|input_overlay_scale_landscape = \"1.170000\"|input_overlay_scale_landscape = \"1.075000\"|" "${PicoPath}sega32x.cfg"
	
	find "$RetroArch_coreConfigFolders" -type f -name "sega32x.cfg"| while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.070000"'
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "-0.010000"'
	done

	
	
	#Snes9x
	#Snes9xPath="${RApath}Snes9x/"
	#sed -i "s|input_overlay_scale_landscape = \"1.170000\"|input_overlay_scale_landscape = \"1.055000\"|" "${Snes9xPath}snes.cfg"

	find "$RetroArch_coreConfigFolders" -type f -name "snes.cfg"| while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.055000"'
	done
	
	#Mupen64
	#Mupen64Path="${RApath}Mupen64Plus-Next/"
	#sed -i "s|input_overlay_aspect_adjust_landscape = \"0.085000\"|input_overlay_aspect_adjust_landscape = \"-0.025000\"|" "${Mupen64Path}n64.cfg"
	find "$RetroArch_coreConfigFolders" -type f -name "n64.cfg" | while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "-0.025000"'
	done
	
	#Flycast
	#FlycastPath="${RApath}Flycast/"
	#sed -i "s|input_overlay_aspect_adjust_landscape = \"0.110000\"|input_overlay_aspect_adjust_landscape = \"0.000000\"|" "${FlycastPath}dreamcast.cfg"
	find "$RetroArch_coreConfigFolders" -type f -name "dreamcast.cfg" | while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "0"'
	done
	
	#Beetle Saturn
	#BeetleSaturnPath="${RApath}Yabause/"
	#sed -i "s|input_overlay_aspect_adjust_landscape = \"0.095000\"|input_overlay_aspect_adjust_landscape = \"0.000000\"|" "${BeetleSaturnPath}saturn.cfg"
	find "$RetroArch_coreConfigFolders" -type f -name "saturn.cfg" | while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "0"'
	done

}


nonDeck_win600(){
	echo "Fixes for Win600 Hardware"
	updateOrAppendConfigLine "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini" "InternalResolution ="  'InternalResolution = 1'
}