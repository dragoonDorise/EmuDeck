#!/bin/bash

nonDeck_169Screen(){

	#Redo this using livedeth fancy functions for RA
	#RetroArch_setOverride 'wswanc.cfg' 'Beetle Cygne'  'aspect_ratio_index' '"21"'
	
	setMSG "Applying corrections for 16:9 screens..."		
	RApath=~/.var/app/org.libretro.RetroArch/config/retroarch/config/	
	
	#Mesen
	#Nestopia
	mesenPath="${RApath}Mesen/"
	nestopiaPath="${RApath}Nestopia/"	
	
	sed -i "s|input_overlay_scale_landscape = \"1.070000\"|input_overlay_scale_landscape = \"1.055000\"|" "${nestopiaPath}nes.cfg"
	sed -i "s|input_overlay_aspect_adjust_landscape = \"0.000000\"|input_overlay_aspect_adjust_landscape = \"-0.090000\"|" "${nestopiaPath}nes.cfg"
	
	sed -i "s|input_overlay_scale_landscape = \"1.070000\"|input_overlay_scale_landscape = \"1.055000\"|" "${mesenPath}nes.cfg"
	sed -i "s|input_overlay_aspect_adjust_landscape = \"0.000000\"|input_overlay_aspect_adjust_landscape = \"-0.090000\"|" "${mesenPath}nes.cfg"
	
	#Beetle PCE Fast
	#Beetle PCE	
	PCEPath="${RApath}Beetle PCE Fast/"
	PCEfastPath="${RApath}Beetle PCE/"		
	sed -i "s|aspect_ratio_index = \"21\"|aspect_ratio_index = \"0\"|" "${PCEfastPath}pcengine.cfg"
	sed -i "s|input_overlay_aspect_adjust_landscape = \"-0.130000\"|input_overlay_aspect_adjust_landscape = \"-0.000000\"|" "${PCEfastPath}pcengine.cfg"
	sed -i "s|input_overlay_scale_landscape = \"1.060000\"|input_overlay_scale_landscape = \"1.055000\"|" "${PCEfastPath}pcengine.cfg"
	sed -i "s|input_overlay_x_separation_landscape = \"0.010000\"|input_overlay_x_separation_landscape = \"0.000000\"|" "${PCEfastPath}pcengine.cfg"
	sed -i "s|aspect_ratio_index = \"21\"|aspect_ratio_index = \"0\"|" "${PCEPath}pcengine.cfg"
	sed -i "s|input_overlay_aspect_adjust_landscape = \"-0.130000\"|input_overlay_aspect_adjust_landscape = \"-0.000000\"|" "${PCEPath}pcengine.cfg"
	sed -i "s|input_overlay_scale_landscape = \"1.060000\"|input_overlay_scale_landscape = \"1.055000\"|" "${PCEPath}pcengine.cfg"
	sed -i "s|input_overlay_x_separation_landscape = \"0.010000\"|input_overlay_x_separation_landscape = \"0.000000\"|" "${PCEPath}pcengine.cfg"
	
	#Stella		
	StellaPath="${RApath}Stella/"
	sed -i "s|input_overlay_aspect_adjust_landscape = \"0.000000\"|input_overlay_aspect_adjust_landscape = \"-0.025000\"|" "${StellaPath}atari800.cfg"
	sed -i "s|input_overlay_scale_landscape = \"1.175000\"|input_overlay_scale_landscape = \"1.080000\"|" "${StellaPath}atari800.cfg"
	sed -i "s|input_overlay_aspect_adjust_landscape = \"0.000000\"|input_overlay_aspect_adjust_landscape = \"-0.025000\"|" "${StellaPath}atari2600.cfg"
	sed -i "s|input_overlay_scale_landscape = \"1.175000\"|input_overlay_scale_landscape = \"1.080000\"|" "${StellaPath}atari2600.cfg"
	sed -i "s|input_overlay_aspect_adjust_landscape = \"0.000000\"|input_overlay_aspect_adjust_landscape = \"-0.025000\"|" "${StellaPath}atari5200.cfg"
	sed -i "s|input_overlay_scale_landscape = \"1.175000\"|input_overlay_scale_landscape = \"1.080000\"|" "${StellaPath}atari5200.cfg"
	
	#Beetle NeoPop
	NeoPopPath="${RApath}Beetle NeoPop/"
	sed -i "s|input_overlay_scale_landscape = \"1.615000\"|input_overlay_scale_landscape = \"1.575000\"|" "${NeoPopPath}ngpc.cfg"
	sed -i "s|input_overlay_x_separation_portrait = \"-0.010000\"|input_overlay_x_separation_portrait = \"0.000000\"|" "${NeoPopPath}ngpc.cfg"
	sed -i "s|input_overlay_y_offset_landscape = \"-0.135000\"|input_overlay_y_offset_landscape = \"-0.130000\"|" "${NeoPopPath}ngpc.cfg"
	sed -i "s|input_overlay_aspect_adjust_landscape = \"-0.160000\"|input_overlay_aspect_adjust_landscape = \"-0.275000\"|" "${NeoPopPath}ngpc.cfg"
	sed -i "s|input_overlay_scale_landscape = \"1.615000\"|input_overlay_scale_landscape = \"1.575000\"|" "${NeoPopPath}ngp.cfg"
	sed -i "s|input_overlay_x_separation_portrait = \"-0.010000\"|input_overlay_x_separation_portrait = \"0.000000\"|" "${NeoPopPath}ngp.cfg"
	sed -i "s|input_overlay_y_offset_landscape = \"-0.135000\"|input_overlay_y_offset_landscape = \"-0.130000\"|" "${NeoPopPath}ngp.cfg"
	sed -i "s|input_overlay_aspect_adjust_landscape = \"-0.160000\"|input_overlay_aspect_adjust_landscape = \"-0.275000\"|" "${NeoPopPath}ngp.cfg"
	
	#Gambatte
	GambattePath="${RApath}Gambatte/"
	sed -i "s|input_overlay_scale_landscape = \"1.860000\"|input_overlay_scale_landscape = \"1.670000\"|" "${GambattePath}gb.cfg"
	sed -i "s|input_overlay_scale_landscape = \"1.870000\"|input_overlay_scale_landscape = \"1.680000\"|" "${GambattePath}gbc.cfg"
	
	#Genesis Plus GX	
	GenesisPath="${RApath}Genesis Plus GX/"
	sed -i "s|input_overlay_aspect_adjust_landscape = \"-0.080000\"|input_overlay_aspect_adjust_landscape = \"-0.200000\"|" "${GenesisPath}gamegear.cfg"
	sed -i "s|input_overlay_scale_landscape = \"1.170000\"|input_overlay_scale_landscape = \"1.055000\"|" "${GenesisPath}genesis.cfg"
	sed -i "s|input_overlay_aspect_adjust_landscape = \"0.095000\"|input_overlay_aspect_adjust_landscape = \"-0.010000\"|" "${GenesisPath}genesis.cfg"
	
	sed -i "s|input_overlay_scale_landscape = \"1.170000\"|input_overlay_scale_landscape = \"1.055000\"|" "${GenesisPath}mastersystem.cfg"	
	sed -i "s|input_overlay_scale_landscape = \"1.170000\"|input_overlay_scale_landscape = \"1.055000\"|" "${GenesisPath}megacd.cfg"
	sed -i "s|input_overlay_scale_landscape = \"1.170000\"|input_overlay_scale_landscape = \"1.055000\"|" "${GenesisPath}segacd.cfg"
	
	
	sed -i "s|input_overlay_aspect_adjust_landscape = \"0.000000\"|input_overlay_aspect_adjust_landscape = \"-0.110000\"|" "${GenesisPath}megacd.cfg"
	sed -i "s|input_overlay_aspect_adjust_landscape = \"0.000000\"|input_overlay_aspect_adjust_landscape = \"-0.110000\"|" "${GenesisPath}segacd.cfg"
	
	#PicoDrive
	PicoPath="${RApath}PicoDrive/"
	sed -i "s|input_overlay_scale_landscape = \"1.170000\"|input_overlay_scale_landscape = \"1.075000\"|" "${PicoPath}sega32x.cfg"
	
	#Gearsystem
	GearsystemPath="${RApath}Gearsystem/"
	sed -i "s|input_overlay_scale_landscape = \"1.545000\"|input_overlay_scale_landscape = \"1.500000\"|" "${GearsystemPath}gamegear.cfg"
				
	#SameBoy
	SameBoyPath="${RApath}SameBoy/"
	sed -i "s|input_overlay_scale_landscape = \"1.860000\"|input_overlay_scale_landscape = \"1.670000\"|" "${SameBoyPath}gb.cfg"
	sed -i "s|input_overlay_scale_landscape = \"1.870000\"|input_overlay_scale_landscape = \"1.680000\"|" "${SameBoyPath}gbc.cfg"
	
	#Snes9x
	Snes9xPath="${RApath}Snes9x/"
	sed -i "s|input_overlay_scale_landscape = \"1.170000\"|input_overlay_scale_landscape = \"1.055000\"|" "${Snes9xPath}snes.cfg"
	
	#Mupen64
	Mupen64Path="${RApath}Mupen64Plus-Next/"
	sed -i "s|input_overlay_aspect_adjust_landscape = \"0.085000\"|input_overlay_aspect_adjust_landscape = \"-0.025000\"|" "${Mupen64Path}n64.cfg"
	
	#Flycast
	FlycastPath="${RApath}Flycast/"
	sed -i "s|input_overlay_aspect_adjust_landscape = \"0.110000\"|input_overlay_aspect_adjust_landscape = \"0.000000\"|" "${FlycastPath}dreamcast.cfg"
	
	#Beetle Saturn
	BeetleSaturnPath="${RApath}Yabause/"
	sed -i "s|input_overlay_aspect_adjust_landscape = \"0.095000\"|input_overlay_aspect_adjust_landscape = \"0.000000\"|" "${BeetleSaturnPath}saturn.cfg"

}


nonDeck_win600(){
	echo "Fixes for Win600 Hardware"
}