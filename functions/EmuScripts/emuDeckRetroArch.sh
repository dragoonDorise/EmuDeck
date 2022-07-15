#!/bin/bash
#variables
RetroArch_emuName="RetroArch"
RetroArch_emuType="FlatPak"
RetroArch_emuPath="org.libretro.RetroArch"
RetroArch_releaseURL=""
RetroArch_configFile="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg"
RetroArch_coreConfigFolders="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/config"

#cleanupOlderThings
RetroArch.cleanup(){
	echo "NYI"
}

#Install
RetroArch.install(){

	installEmuFP "${RetroArch_emuName}" "${RetroArch_emuPath}"
	flatpak override "${RetroArch_emuPath}" --filesystem=host --user

}

#ApplyInitialSettings
RetroArch.init(){

	configEmuFP "${RetroArch_emuName}" "${RetroArch_emuPath}" "true"
	RetroArch.setEmulationFolder
	RetroArch.setupSaves
	RetroArch.installCores

}

#update
RetroArch.update(){

	configEmuFP "${RetroArch_emuName}" "${RetroArch_emuPath}"
	RetroArch.setEmulationFolder
	RetroArch.setupSaves
	RetroArch.installCores

}

#ConfigurePaths
RetroArch.setEmulationFolder(){

	system_directory='system_directory = '
	system_directorySetting="${system_directory}""\"${biosPath}\""
	sed -i "/${system_directory}/c\\${system_directorySetting}" $configFile

}

#SetupSaves
RetroArch.setupSaves(){
	linkToSaveFolder retroarch states "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/states"
	linkToSaveFolder retroarch saves "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/saves"
}


#SetupStorage
RetroArch.setupStorage(){
	echo "NYI"
}


#WipeSettings
RetroArch.wipe(){
   rm -rf "$HOME/.var/app/$RetroArch_emuPath"
   # prob not cause roms are here
}


#Uninstall
RetroArch.uninstall(){
    flatpak uninstall "$RetroArch_emuPath" --user -y
}

#setABXYstyle
RetroArch.setABXYstyle(){
	echo "NYI"    
}

#Migrate
RetroArch.migrate(){
	echo "NYI"    
}

#WideScreenOn
RetroArch.wideScreenOn(){
echo "NYI"
}

#WideScreenOff
RetroArch.wideScreenOff(){
echo "NYI"
}

RetroArch.setOverride(){
	local fileName=$1
	local coreName=$2
	local option=$3
	local value=$4
	
	local fullPath="$RetroArch_coreConfigFolders/$coreName"
	local configFile="$fullPath/$fileName"

	mkdir -p "$fullPath"
	touch "$configFile"
	
	local optionFound=$(grep -rnw  "$configFile" -e "$option")
	if [[ "$optionFound" == '' ]]; then
		echo "appending: $option = $value to $configFile"
		echo "$option = $value" >> "$configFile"
	else
		echo "updating $option in $configFile to $value"
		changeLine "$option" "$option = $value" "$configFile"
	fi
}

RetroArch.Beetle_Cygne.bezelOn(){
RetroArch.setOverride 'wswanc.cfg' 'Beetle Cygne'  'video_shader_enable' 'true'
RetroArch.setOverride 'wswanc.cfg' 'Beetle Cygne'  'aspect_ratio_index' '"21"'
RetroArch.setOverride 'wswanc.cfg' 'Beetle Cygne'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/wswanc.cfg"'
RetroArch.setOverride 'wswanc.cfg' 'Beetle Cygne'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'wswanc.cfg' 'Beetle Cygne'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'wswanc.cfg' 'Beetle Cygne'  'input_overlay_opacity' '"0.700000"'
RetroArch.setOverride 'wswanc.cfg' 'Beetle Cygne'  'input_overlay_scale_landscape' '"1.170000"'
RetroArch.setOverride 'wswanc.cfg' 'Beetle Cygne'  'video_scale_integer' '"false"'
}
RetroArch.Beetle_Cygne.bezelOn(){
RetroArch.setOverride 'wswan.cfg' 'Beetle Cygne'  'video_shader_enable' 'true'
RetroArch.setOverride 'wswan.cfg' 'Beetle Cygne'  'aspect_ratio_index' '"21"'
RetroArch.setOverride 'wswan.cfg' 'Beetle Cygne'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/wswan.cfg"'
RetroArch.setOverride 'wswan.cfg' 'Beetle Cygne'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'wswan.cfg' 'Beetle Cygne'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'wswan.cfg' 'Beetle Cygne'  'input_overlay_opacity' '"0.700000"'
RetroArch.setOverride 'wswan.cfg' 'Beetle Cygne'  'input_overlay_scale_landscape' '"1.170000"'
RetroArch.setOverride 'wswan.cfg' 'Beetle Cygne'  'video_scale_integer' '"false"'
}
RetroArch.dolphin-emu.bezelOn(){
RetroArch.setOverride 'dolphin-emu.cfg' 'dolphin-emu'  'video_driver' '"gl"'
}
RetroArch.PPSSPP.bezelOn(){
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_auto_frameskip' '"disabled"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_block_transfer_gpu' '"enabled"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_button_preference' '"Cross"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_cheats' '"disabled"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_cpu_core' '"JIT"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_disable_slow_framebuffer_effects' '"disabled"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_fast_memory' '"enabled"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_force_lag_sync' '"disabled"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_frameskip' '"Off"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_frameskiptype' '"Number'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_gpu_hardware_transform' '"enabled"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_ignore_bad_memory_access' '"enabled"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_inflight_frames' '"Up'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_internal_resolution' '"1440x816"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_io_timing_method' '"Fast"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_language' '"Automatic"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_lazy_texture_caching' '"disabled"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_locked_cpu_speed' '"off"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_lower_resolution_for_effects' '"Off"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_rendering_mode' '"Buffered"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_retain_changed_textures' '"disabled"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_software_skinning' '"enabled"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_spline_quality' '"Low"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_anisotropic_filtering' '"off"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_deposterize' '"disabled"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_filtering' '"Auto"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_replacement' '"enabled"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_scaling_level' '"Off"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_scaling_type' '"xbrz"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_shader' '"Off"'
RetroArch.setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_vertex_cache' '"disabled"'
}
RetroArch.Beetle_PCE_Fast.bezelOn(){
RetroArch.setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'aspect_ratio_index' '"21"'
RetroArch.setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'custom_viewport_height' '"1200"'
RetroArch.setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'custom_viewport_x' '"0"'
RetroArch.setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/pcengine.cfg"'
RetroArch.setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_hide_in_menu' '"false"'
RetroArch.setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_scale_landscape' '"1.025000"'
}
RetroArch.Mesen.bezelOn(){
RetroArch.setOverride 'nes.cfg' 'Mesen'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/nes.cfg"'
RetroArch.setOverride 'nes.cfg' 'Mesen'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'nes.cfg' 'Mesen'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'nes.cfg' 'Mesen'  'input_overlay_opacity' '"0.700000"'
RetroArch.setOverride 'nes.cfg' 'Mesen'  'input_overlay_scale_landscape' '"1.070000"'
RetroArch.setOverride 'nes.cfg' 'Mesen'  'video_scale_integer' '"false"'
}
RetroArch.Mupen64Plus-Next.bezelOn(){
RetroArch.setOverride 'Mupen64Plus-Next.cfg' 'Mupen64Plus-Next'  'aspect_ratio_index' '"0"'
RetroArch.setOverride 'Mupen64Plus-Next.cfg' 'Mupen64Plus-Next'  'video_crop_overscan' '"false"'
RetroArch.setOverride 'Mupen64Plus-Next.cfg' 'Mupen64Plus-Next'  'video_shader_enable' '"false"'
RetroArch.setOverride 'Mupen64Plus-Next.cfg' 'Mupen64Plus-Next'  'video_smooth' '"true"'
}
RetroArch.Beetle_Lynx.bezelOn(){
RetroArch.setOverride 'lynx.cfg' 'Beetle Lynx'  'video_shader_enable' 'true'
RetroArch.setOverride 'lynx.cfg' 'Beetle Lynx'  'aspect_ratio_index' '"21"'
RetroArch.setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/lynx.cfg"'
RetroArch.setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_opacity' '"0.700000"'
RetroArch.setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_scale_landscape' '"1.170000"'
RetroArch.setOverride 'lynx.cfg' 'Beetle Lynx'  'video_scale_integer' '"false"'
}
RetroArch.SameBoy.bezelOn(){
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_dark_filter_level' '"0"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_bootloader' '"enabled"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_colorization' '"internal"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_hwmode' '"Auto"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_internal_palette' '"GB'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_mode' '"Not'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_port' '"56400"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_1' '"0"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_10' '"0"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_11' '"0"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_12' '"0"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_2' '"0"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_3' '"0"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_4' '"0"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_5' '"0"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_6' '"0"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_7' '"0"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_8' '"0"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_9' '"0"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_palette_twb64_1' '"TWB64'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_palette_twb64_2' '"TWB64'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gbc_color_correction' '"GBC'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gbc_color_correction_mode' '"accurate"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_gbc_frontlight_position' '"central"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_mix_frames' '"disabled"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_rumble_level' '"10"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_show_gb_link_settings' '"disabled"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_turbo_period' '"4"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'gambatte_up_down_allowed' '"disabled"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'aspect_ratio_index' '"21"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/gb.cfg"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'input_overlay_scale_landscape' '"1.860000"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'input_overlay_y_offset_landscape' '"-0.150000"'
RetroArch.setOverride 'gb.cfg' 'SameBoy'  'video_shader_enable' '"true"'
}
RetroArch.SameBoy.bezelOn(){
RetroArch.setOverride 'gbc.cfg' 'SameBoy'  'aspect_ratio_index' '"21"'
RetroArch.setOverride 'gbc.cfg' 'SameBoy'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/gbc.cfg"'
RetroArch.setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_scale_landscape' '"1.870000"'
RetroArch.setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_y_offset_landscape' '"-0.220000"'
RetroArch.setOverride 'gbc.cfg' 'SameBoy'  'video_shader_enable' '"true"'
}
RetroArch.Beetle_NeoPop.bezelOn(){
RetroArch.setOverride 'ngp.cfg' 'Beetle NeoPop'  'aspect_ratio_index' '"21"'
RetroArch.setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/ngpc.cfg"'
RetroArch.setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_aspect_adjust_landscape' '"-0.310000"'
RetroArch.setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_hide_in_menu' '"false"'
RetroArch.setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_scale_landscape' '"1.625000"'
RetroArch.setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_x_separation_portrait' '"-0.010000"'
RetroArch.setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_y_offset_landscape' '"-0.135000"'
RetroArch.setOverride 'ngp.cfg' 'Beetle NeoPop'  'video_shader_enable' '"true"'
}
RetroArch.Beetle_NeoPop.bezelOn(){
RetroArch.setOverride 'ngpc.cfg' 'Beetle NeoPop'  'aspect_ratio_index' '"21"'
RetroArch.setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/ngpc.cfg"'
RetroArch.setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_aspect_adjust_landscape' '"-0.170000"'
RetroArch.setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_scale_landscape' '"1.615000"'
RetroArch.setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_x_separation_portrait' '"-0.010000"'
RetroArch.setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_y_offset_landscape' '"-0.135000"'
RetroArch.setOverride 'ngpc.cfg' 'Beetle NeoPop'  'video_shader_enable' '"true"'
}
RetroArch.Stella.bezelOn(){
RetroArch.setOverride 'atari2600.cfg' 'Stella'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/atari2600.cfg"'
RetroArch.setOverride 'atari2600.cfg' 'Stella'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'atari2600.cfg' 'Stella'  'input_overlay_scale_landscape' '"1.0"'
}
RetroArch.MAME_2003-Plus.bezelOn(){
RetroArch.setOverride 'mame.cfg' 'MAME 2003-Plus'  'video_shader_enable' 'true'
RetroArch.setOverride 'mame.cfg' 'MAME 2003-Plus'  'aspect_ratio_index' '"21"'
RetroArch.setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/MAME_Horizontal.cfg"'
RetroArch.setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_overlay_opacity' '"0.700000"'
RetroArch.setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_overlay_scale_landscape' '"1.170000"'
RetroArch.setOverride 'mame.cfg' 'MAME 2003-Plus'  'video_scale_integer' '"false"'
}
RetroArch.Genesis_Plus_GX.bezelOn(){
RetroArch.setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/SEGACD.cfg"'
RetroArch.setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_hide_in_menu' '"false"'
RetroArch.setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000'
}
RetroArch.Genesis_Plus_GX.bezelOn(){
RetroArch.setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/SEGACD.cfg"'
RetroArch.setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_hide_in_menu' '"false"'
RetroArch.setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000'
}
RetroArch.Genesis_Plus_GX.bezelOn(){
RetroArch.setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/genesis.cfg"'
RetroArch.setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000"'
RetroArch.setOverride 'genesis.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
}
RetroArch.Genesis_Plus_GX.bezelOn(){
RetroArch.setOverride 'gamegear.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
RetroArch.setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/gg.cfg"'
RetroArch.setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_aspect_adjust_landscape' '"-0.115000"'
RetroArch.setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.545000"'
RetroArch.setOverride 'gamegear.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
}
RetroArch.Genesis_Plus_GX.bezelOn(){
RetroArch.setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
RetroArch.setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/mastersystem.cfg"'
RetroArch.setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000"'
}
RetroArch.PicoDrive.bezelOn(){
RetroArch.setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/sega32x.cfg"'
RetroArch.setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_hide_in_menu' '"false"'
RetroArch.setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_scale_landscape' '"1.250000"'
}
RetroArch.mGBA.bezelOn(){
RetroArch.setOverride 'gba.cfg' 'mGBA'  'aspect_ratio_index' '"21"'
RetroArch.setOverride 'gba.cfg' 'mGBA'  'video_shader_enable' '"true"'
}
RetroArch.Gearsystem.bezelOn(){
RetroArch.setOverride 'gamegear.cfg' 'Gearsystem'  'aspect_ratio_index' '"21"'
RetroArch.setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/gg.cfg"'
RetroArch.setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_aspect_adjust_landscape' '"-0.115000"'
RetroArch.setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_scale_landscape' '"1.545000"'
RetroArch.setOverride 'gamegear.cfg' 'Gearsystem'  'video_shader_enable' '"true"'
}
RetroArch.Gambatte.bezelOn(){
RetroArch.setOverride 'gb.cfg' 'Gambatte'  'aspect_ratio_index' '"21"'
RetroArch.setOverride 'gb.cfg' 'Gambatte'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/gb.cfg"'
RetroArch.setOverride 'gb.cfg' 'Gambatte'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'gb.cfg' 'Gambatte'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'gb.cfg' 'Gambatte'  'input_overlay_scale_landscape' '"1.860000"'
RetroArch.setOverride 'gb.cfg' 'Gambatte'  'input_overlay_y_offset_landscape' '"-0.150000"'
RetroArch.setOverride 'gb.cfg' 'Gambatte'  'video_shader_enable' '"true"'
}
RetroArch.Gambatte.bezelOn(){
RetroArch.setOverride 'gbc.cfg' 'Gambatte'  'aspect_ratio_index' '"21"'
RetroArch.setOverride 'gbc.cfg' 'Gambatte'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/gbc.cfg"'
RetroArch.setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_scale_landscape' '"1.870000"'
RetroArch.setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_y_offset_landscape' '"-0.220000"'
RetroArch.setOverride 'gbc.cfg' 'Gambatte'  'video_shader_enable' '"true"'
}
RetroArch.Snes9x.bezelOn(){
RetroArch.setOverride 'snes43.cfg' 'Snes9x'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/snes.cfg"'
RetroArch.setOverride 'snes43.cfg' 'Snes9x'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'snes43.cfg' 'Snes9x'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'snes43.cfg' 'Snes9x'  'input_overlay_opacity' '"0.700000"'
RetroArch.setOverride 'snes43.cfg' 'Snes9x'  'input_overlay_scale_landscape' '"1.170000"'
RetroArch.setOverride 'snes43.cfg' 'Snes9x'  'video_scale_integer' '"false"'
}
RetroArch.Snes9x.bezelOn(){
RetroArch.setOverride 'snes87.cfg' 'Snes9x'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/snes87.cfg"'
RetroArch.setOverride 'snes87.cfg' 'Snes9x'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'snes87.cfg' 'Snes9x'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'snes87.cfg' 'Snes9x'  'input_overlay_opacity' '"0.700000"'
RetroArch.setOverride 'snes87.cfg' 'Snes9x'  'input_overlay_scale_landscape' '"1.380000"'
RetroArch.setOverride 'snes87.cfg' 'Snes9x'  'video_scale_integer' '"false"'
RetroArch.setOverride 'snes87.cfg' 'Snes9x'  'input_overlay_aspect_adjust_landscape' '"-0.170000"'
RetroArch.setOverride 'snes87.cfg' 'Snes9x'  'aspect_ratio_index' '"21"'
}
RetroArch.Snes9x.bezelOn(){
RetroArch.setOverride 'snes.cfg' 'Snes9x'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/snes.cfg"'
RetroArch.setOverride 'snes.cfg' 'Snes9x'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'snes.cfg' 'Snes9x'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'snes.cfg' 'Snes9x'  'input_overlay_opacity' '"0.700000"'
RetroArch.setOverride 'snes.cfg' 'Snes9x'  'input_overlay_scale_landscape' '"1.170000"'
RetroArch.setOverride 'snes.cfg' 'Snes9x'  'video_scale_integer' '"false"'
}
RetroArch.Nestopia.bezelOn(){
RetroArch.setOverride 'nes.cfg' 'Nestopia'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/nes.cfg"'
RetroArch.setOverride 'nes.cfg' 'Nestopia'  'input_overlay_auto_scale' '"false"'
RetroArch.setOverride 'nes.cfg' 'Nestopia'  'input_overlay_enable' '"true"'
RetroArch.setOverride 'nes.cfg' 'Nestopia'  'input_overlay_opacity' '"0.700000"'
RetroArch.setOverride 'nes.cfg' 'Nestopia'  'input_overlay_scale_landscape' '"1.070000"'
RetroArch.setOverride 'nes.cfg' 'Nestopia'  'video_scale_integer' '"false"'
}
RetroArch.bsnes-hd_beta.bezelOn(){
RetroArch.setOverride 'snes.cfg' 'bsnes-hd beta'  'video_scale_integer' '"false"'
}

RetroArch.Beetle_Cygne.shaderOn(){

	RetroArch.setOverride 'wswan.cfg' 'Beetle Cygne' 'video_shader_enable' 'true'

}

#BezelOn
RetroArch.bezelOn(){
		# case "folder" in
		# 	3do)				override_file='' && loop=true ;;
		# 	amiga)				override_file='' && loop=true ;;
		# 	amigacd32)			override_file='' && loop=true ;;
		# 	amstradcpc)			override_file='' && loop=true ;;
		# 	apple2)				override_file='' && loop=true ;;
		# 	atari800)			override_file='' && loop=true ;;
		# 	atari2600)			override_file='' && loop=true ;;
		# 	atari5200)			override_file='' && loop=true ;;
		# 	atari7800)			override_file='' && loop=true ;;
		# 	atarist)			override_file='' && loop=true ;;
		# 	atomiswave)			override_file='' && loop=true ;;
		# 	c64)				override_file='' && loop=true ;;
		# 	cavestory)			override_file='' && loop=true ;;
		# 	colecovision)		override_file='' && loop=true ;;
		# 	dreamcast)			override_file='' && loop=true ;;
		# 	fba)				override_file='' && loop=true ;;
		# 	fds)				override_file='' && loop=true ;;
		# 	gameandwatch)		override_file='' && loop=true ;;
		# 	gamegear)			override_file='' && loop=true ;;
		# 	gb)					override_file='' && loop=true ;;
		# 	gba)				override_file='' && loop=true ;;
		# 	gbc)				override_file='' && loop=true ;;
		# 	gx4000)				override_file='' && loop=true ;;
		# 	intellivision)		override_file='' && loop=true ;;
		# 	jaguar)				override_file='' && loop=true ;;
		# 	lynx)				override_file='' && loop=true ;;
		# 	mame)				override_file='' && loop=true ;;
		# 	mastersystem)		override_file='' && loop=true ;;
		# 	megadrive)			override_file='' && loop=true ;;
		# 	msx)				override_file='' && loop=true ;;
		# 	n64)				override_file='' && loop=true ;;
		# 	naomi)				override_file='' && loop=true ;;
		# 	neogeo)				override_file='' && loop=true ;;
		# 	neogeocd)			override_file='' && loop=true ;;
		# 	nes)				override_file='' && loop=true ;;
		# 	ngp)				override_file='' && loop=true ;;
		# 	ngpc)				override_file='' && loop=true ;;
		# 	o2em)				override_file='' && loop=true ;;
		# 	pcenginecd)			override_file='' && loop=true ;;
		# 	pcengine)			override_file='' && loop=true ;;
		# 	pcfx)				override_file='' && loop=true ;;
		# 	pokemini)			override_file='' && loop=true ;;
		# 	prboom)				override_file='' && loop=true ;;
		# 	psp)				override_file='' && loop=true ;;
		# 	psx)				override_file='' && loop=true ;;
		# 	satellaview)		override_file='' && loop=true ;;
		# 	saturn)				override_file='' && loop=true ;;
		# 	scummvm)			override_file='' && loop=true ;;
		# 	sega32x)			override_file='' && loop=true ;;
		# 	segacd)				override_file='' && loop=true ;;
		# 	sg1000)				override_file='' && loop=true ;;
		# 	snes)				override_file='' && loop=true ;;
		# 	sufami)				override_file='' && loop=true ;;
		# 	supergrafx)			override_file='' && loop=true ;;
		# 	thomson)			override_file='' && loop=true ;;
		# 	vectrex)			override_file='' && loop=true ;;
		# 	virtualboy)			override_file='' && loop=true ;;
		# 	wswan)				override_file='' && loop=true ;;
		# 	wswanc)				override_file='' && loop=true ;;
		# 	x68000)				override_file='' && loop=true ;;
		# 	zx81)				override_file='' && loop=true ;;
		# 	zxspectrum)			override_file='' && loop=true ;;
		# 	*)
		# esac
		echo "NYI"
}

#BezelOff
RetroArch.bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
RetroArch.finalize(){
	echo "NYI"
}

RetroArch.installCores(){

	#Requests for:
	#GP32
	#N-gage
	#Game.com

	mkdir -p "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores"
	raUrl="https://buildbot.libretro.com/nightly/linux/x86_64/latest/"
	RAcores=(bsnes_hd_beta_libretro.so flycast_libretro.so gambatte_libretro.so genesis_plus_gx_libretro.so genesis_plus_gx_wide_libretro.so mednafen_lynx_libretro.so mednafen_ngp_libretro.so mednafen_wswan_libretro.so melonds_libretro.so mesen_libretro.so mgba_libretro.so mupen64plus_next_libretro.so nestopia_libretro.so picodrive_libretro.so ppsspp_libretro.so snes9x_libretro.so stella_libretro.so yabasanshiro_libretro.so yabause_libretro.so yabause_libretro.so mame2003_plus_libretro.so mame2010_libretro.so mame_libretro.so melonds_libretro.so fbneo_libretro.so bluemsx_libretro.so desmume_libretro.so sameboy_libretro.so gearsystem_libretro.so mednafen_saturn_libretro.so opera_libretro.so dosbox_core_libretro.so dosbox_pure_libretro.so dosbox_svn_libretro.so puae_libretro.so)
	setMSG "Downloading RetroArch Cores for EmuDeck"
	for i in "${RAcores[@]}"
	do
		FILE=~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}
		if [ -f "$FILE" ]; then
			echo "${i}...Already Downloaded"
		else
			curl $raUrl$i.zip --output ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip 
			#rm ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip
			echo "${i}...Downloaded!"
		fi
	done	
	

	RAcores=(a5200_libretro.so 81_libretro.so atari800_libretro.so bluemsx_libretro.so chailove_libretro.so fbneo_libretro.so freechaf_libretro.so freeintv_libretro.so fuse_libretro.so gearsystem_libretro.so gw_libretro.so hatari_libretro.so lutro_libretro.so mednafen_pcfx_libretro.so mednafen_vb_libretro.so mednafen_wswan_libretro.so mu_libretro.so neocd_libretro.so nestopia_libretro.so nxengine_libretro.so o2em_libretro.so picodrive_libretro.so pokemini_libretro.so prboom_libretro.so prosystem_libretro.so px68k_libretro.so quasi88_libretro.so scummvm_libretro.so squirreljme_libretro.so theodore_libretro.so uzem_libretro.so vecx_libretro.so vice_xvic_libretro.so virtualjaguar_libretro.so x1_libretro.so mednafen_lynx_libretro.so mednafen_ngp_libretro.so mednafen_pce_libretro.so mednafen_pce_fast_libretro.so mednafen_psx_libretro.so mednafen_psx_hw_libretro.so mednafen_saturn_libretro.so mednafen_supafaust_libretro.so mednafen_supergrafx_libretro.so blastem_libretro.so bluemsx_libretro.so bsnes_libretro.so bsnes_mercury_accuracy_libretro.so cap32_libretro.so citra2018_libretro.so citra_libretro.so crocods_libretro.so desmume2015_libretro.so desmume_libretro.so dolphin_libretro.so dosbox_core_libretro.so dosbox_pure_libretro.so dosbox_svn_libretro.so fbalpha2012_cps1_libretro.so fbalpha2012_cps2_libretro.so fbalpha2012_cps3_libretro.so fbalpha2012_libretro.so fbalpha2012_neogeo_libretro.so fceumm_libretro.so fbneo_libretro.so flycast_libretro.so fmsx_libretro.so frodo_libretro.so gambatte_libretro.so gearboy_libretro.so gearsystem_libretro.so genesis_plus_gx_libretro.so genesis_plus_gx_wide_libretro.so gpsp_libretro.so handy_libretro.so kronos_libretro.so mame2000_libretro.so mame2003_plus_libretro.so mame2010_libretro.so mame_libretro.so melonds_libretro.so mesen_libretro.so mesen-s_libretro.so mgba_libretro.so mupen64plus_next_libretro.so nekop2_libretro.so np2kai_libretro.so nestopia_libretro.so parallel_n64_libretro.so pcsx2_libretro.so pcsx_rearmed_libretro.so picodrive_libretro.so ppsspp_libretro.so puae_libretro.so quicknes_libretro.so race_libretro.so sameboy_libretro.so smsplus_libretro.so snes9x2010_libretro.so snes9x_libretro.so stella2014_libretro.so stella_libretro.so tgbdual_libretro.so vbam_libretro.so vba_next_libretro.so vice_x128_libretro.so vice_x64_libretro.so vice_x64sc_libretro.so vice_xscpu64_libretro.so yabasanshiro_libretro.so yabause_libretro.so bsnes_hd_beta_libretro.so swanstation_libretro.so)
	setMSG "Downloading RetroArch Cores for EmulationStation DE"
	for i in "${RAcores[@]}"
	do
		FILE=~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}
		if [ -f "$FILE" ]; then
			echo "${i}...Already Downloaded"
		else
			curl $raUrl$i.zip --output ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip 
			#rm ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip
			echo "${i}...Downloaded!"
		fi
	done

	
	for entry in ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/*.zip
	do
		 unzip -o "$entry" -d ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/ 
	done
	
	for entry in ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/*.zip
	do
		 rm -f "$entry" 
	done


}

RetroArch.autoSaveOn(){
	changeLine 'savestate_auto_load = ' 'savestate_auto_load = "true"' "$RetroArch_configFile"
	changeLine 'savestate_auto_save = ' 'savestate_auto_save = "true"' "$RetroArch_configFile"
}
RetroArch.autoSaveOn(){
	changeLine 'savestate_auto_load = ' 'savestate_auto_load = "false"' "$RetroArch_configFile"
	changeLine 'savestate_auto_save = ' 'savestate_auto_save = "false"' "$RetroArch_configFile"
}
RetroArch.retroAchievementsOn(){
	changeLine 'cheevos_enable = ' 'cheevos_enable = "true"' "$RetroArch_configFile"
}
RetroArch.retroAchievementsOff(){
	changeLine 'cheevos_enable = ' 'cheevos_enable = "false"' "$RetroArch_configFile"
}
RetroArch.retroAchievementsPromptLogin(){
	text=$(printf "Do you want to use RetroAchievments on Retroarch?\n\n<b>You need to have an account on https://retroachievements.org</b>\n\nActivating RetroAchievments will disable save states unless you disable hardcore mode\n\n\n\nPress STEAM + X to get the onscreen Keyboard\n\n<b>Make sure your RetroAchievments account is validated on the website or RetroArch will crash</b>")	
	RAInput=$(zenity --forms \
			--title="Retroachievements Sign in" \
			--text="$text" \
			--add-entry="Username: " \
			--add-password="Password: " \
			--separator="," 2>/dev/null)
			ans=$?
	if [ $ans -eq 0 ]; then
		echo "RetroAchievment Login"
		echo $RAInput | awk -F "," '{print $1}' > "$HOME/emudeck/.rau"
		echo $RAInput | awk -F "," '{print $2}' > "$HOME/emudeck/.rap"
	else
		echo "Cancel RetroAchievment Login" 
	fi
}
RetroArch.retroAchievementsSetLogin(){
	rap=$(cat ~/emudeck/.rap)
	rau=$(cat ~/emudeck/.rau)
	echo "Evaluate RetroAchievements Login."
	if [ ${#rap} -lt 1 ]; then
		echo "--No password."
	elif [ ${#rau} -lt 1 ]; then
		echo "--No username."
	else
		echo "Valid Retroachievements Username and Password length"
		changeLine 'cheevos_username = ' 'cheevos_username = "'${rau}'"' "$RetroArch_configFile"
		changeLine 'cheevos_password = ' 'cheevos_password = "'${rap}'"' "$RetroArch_configFile"
	fi
}
RetroArch.setSNESAR(){
	AR=$1
	if [ $SNESAR == 43 ]; then	
		cp ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes43.cfg ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes.cfg	
	else
		cp ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes87.cfg ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes.cfg	
	fi	
}
RetroArch.bezelOn(){
	if [ $RABezels == true ]; then	
		find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.bak" | while read f; do mv -v "$f" "${f%.*}.cfg"; done 
	else
		find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.cfg" | while read f; do mv -v "$f" "${f%.*}.bak"; done 
	fi	
}
