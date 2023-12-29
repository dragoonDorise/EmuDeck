#!/bin/bash

nonDeck_169Screen(){

	setMSG "Applying RetroArch bezel corrections for 16:9 screens"

	#Mesen
	#Nestopia
	find "$RetroArch_coreConfigFolders" -type f -name "nes.cfg"| while read -r configFile
	do

		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.055000"'
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "0.000000"'

	done

		find "$RetroArch_coreConfigFolders" -type f -name "pcengine.cfg"| while read -r configFile
	do

		updateOrAppendConfigLine "$configFile" "aspect_ratio_index ="  'aspect_ratio_index = "0"'
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "0"'
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.055000"'
		updateOrAppendConfigLine "$configFile" "input_overlay_x_separation_landscape ="  'input_overlay_x_separation_landscape = "0"'

	done


	find "$RetroArch_coreConfigFolders" -type f -name "atari800.cfg" -o -type f -name "atari2600.cfg" -o -type f -name "atari5200.cfg"| while read -r configFile
	do

		updateOrAppendConfigLine "$configFile" "aspect_ratio_index ="  'aspect_ratio_index = "0"'
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "0"'
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.055000"'
		updateOrAppendConfigLine "$configFile" "input_overlay_x_separation_landscape ="  'input_overlay_x_separation_landscape = "0"'

	done

	find "$RetroArch_coreConfigFolders" -type f -name "ngpc.cfg" -o -type f -name "ngp.cfg"| while read -r configFile
	do

		updateOrAppendConfigLine "$configFile" "input_overlay_x_separation_portrait ="  'input_overlay_x_separation_portrait = "0"'
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "-0.285000"'
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.605000"'
		updateOrAppendConfigLine "$configFile" "input_overlay_y_offset_landscape ="  'input_overlay_y_offset_landscape = "-0.130000"'

	done

	find "$RetroArch_coreConfigFolders" -type f -name "gb.cfg"| while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.670000"'
	done

	find "$RetroArch_coreConfigFolders" -type f -name "gbc.cfg"| while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.680000"'
	done


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

	find "$RetroArch_coreConfigFolders" -type f -name "sega32x.cfg"| while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.070000"'
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "-0.010000"'
	done


	find "$RetroArch_coreConfigFolders" -type f -name "snes.cfg"| while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_scale_landscape ="  'input_overlay_scale_landscape = "1.055000"'
	done

	find "$RetroArch_coreConfigFolders" -type f -name "n64.cfg" | while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "-0.025000"'
	done

	find "$RetroArch_coreConfigFolders" -type f -name "dreamcast.cfg" | while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "0"'
	done

	find "$RetroArch_coreConfigFolders" -type f -name "saturn.cfg" | while read -r configFile
	do
		updateOrAppendConfigLine "$configFile" "input_overlay_aspect_adjust_landscape ="  'input_overlay_aspect_adjust_landscape = "0"'
	done

}


nonDeck_win600(){
	echo "Fixes for Win600 Hardware"
	updateOrAppendConfigLine "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini" "InternalResolution ="  'InternalResolution = 1'
}