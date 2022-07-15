#!/bin/bash
#variables
RetroArch_emuName="RetroArch"
RetroArch_emuType="FlatPak"
RetroArch_emuPath="org.libretro.RetroArch"
RetroArch_releaseURL=""
RetroArch_configFile="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg"
RetroArch_coreConfigFolders="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/config"

#cleanupOlderThings
RetroArch_cleanup(){
	echo "NYI"
}

#Install
RetroArch_install(){

	installEmuFP "${RetroArch_emuName}" "${RetroArch_emuPath}"
	flatpak override "${RetroArch_emuPath}" --filesystem=host --user

}

#ApplyInitialSettings
RetroArch_init(){

	configEmuFP "${RetroArch_emuName}" "${RetroArch_emuPath}" "true"
	RetroArch_setEmulationFolder
	RetroArch_setupSaves
	RetroArch_installCores

}

#update
RetroArch_update(){

	configEmuFP "${RetroArch_emuName}" "${RetroArch_emuPath}"
	RetroArch_setEmulationFolder
	RetroArch_setupSaves
	RetroArch_installCores

}

#ConfigurePaths
RetroArch_setEmulationFolder(){

	system_directory='system_directory = '
	system_directorySetting="${system_directory}""\"${biosPath}\""
	changeLine "$system_directory" "$system_directorySetting" "$configFile"

}

#SetupSaves
RetroArch_setupSaves(){
	linkToSaveFolder retroarch states "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/states"
	linkToSaveFolder retroarch saves "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/saves"
}


#SetupStorage
RetroArch_setupStorage(){
	echo "NYI"
}


#WipeSettings
RetroArch_wipe(){
   rm -rf "$HOME/.var/app/$RetroArch_emuPath"
   # prob not cause roms are here
}


#Uninstall
RetroArch_uninstall(){
    flatpak uninstall "$RetroArch_emuPath" --user -y
}

#setABXYstyle
RetroArch_setABXYstyle(){
	echo "NYI"    
}

#Migrate
RetroArch_migrate(){
	echo "NYI"    
}

#WideScreenOn
RetroArch_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
RetroArch_wideScreenOff(){
echo "NYI"
}

RetroArch_setOverride(){
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

RetroArch_Beetle_Cygne_wswanc_bezelOn(){

	RetroArch_setOverride 'wswanc.cfg' 'Beetle Cygne'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'wswanc.cfg' 'Beetle Cygne'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/wswanc.cfg"'
	RetroArch_setOverride 'wswanc.cfg' 'Beetle Cygne'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'wswanc.cfg' 'Beetle Cygne'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'wswanc.cfg' 'Beetle Cygne'  'input_overlay_opacity' '"0.700000"'
	RetroArch_setOverride 'wswanc.cfg' 'Beetle Cygne'  'input_overlay_scale_landscape' '"1.170000"'
	RetroArch_setOverride 'wswanc.cfg' 'Beetle Cygne'  'video_scale_integer' '"false"'
}

RetroArch_Beetle_Cygne_wswanc_shaderOn(){
	RetroArch_setOverride 'wswanc.cfg' 'Beetle Cygne'  'video_shader_enable' 'true'
}

RetroArch_Beetle_Cygne_wswanc_shaderOff(){
	RetroArch_setOverride 'wswanc.cfg' 'Beetle Cygne'  'video_shader_enable' 'false'
}
RetroArch_Beetle_Cygne_shaderOn(){

	RetroArch_setOverride 'wswan.cfg' 'Beetle Cygne' 'video_shader_enable' 'true'

}
RetroArch_Beetle_Cygne_wswan_bezelOn(){

	RetroArch_setOverride 'wswan.cfg' 'Beetle Cygne'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'wswan.cfg' 'Beetle Cygne'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/wswan.cfg"'
	RetroArch_setOverride 'wswan.cfg' 'Beetle Cygne'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'wswan.cfg' 'Beetle Cygne'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'wswan.cfg' 'Beetle Cygne'  'input_overlay_opacity' '"0.700000"'
	RetroArch_setOverride 'wswan.cfg' 'Beetle Cygne'  'input_overlay_scale_landscape' '"1.170000"'
	RetroArch_setOverride 'wswan.cfg' 'Beetle Cygne'  'video_scale_integer' '"false"'
}

RetroArch_Beetle_Cygne_wswan_shaderOn(){
	RetroArch_setOverride 'wswan.cfg' 'Beetle Cygne'  'video_shader_enable' 'true'
}

RetroArch_Beetle_Cygne_wswanc_shaderOff(){
	RetroArch_setOverride 'wswan.cfg' 'Beetle Cygne'  'video_shader_enable' 'false'
}

RetroArch_dolphin_emu_setConfig(){
	RetroArch_setOverride 'dolphin_emu.cfg' 'dolphin_emu'  'video_driver' '"gl"'
}

RetroArch_PPSSPP_setConfig(){
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_auto_frameskip' '"disabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_block_transfer_gpu' '"enabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_button_preference' '"Cross"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_cheats' '"disabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_cpu_core' '"JIT"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_disable_slow_framebuffer_effects' '"disabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_fast_memory' '"enabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_force_lag_sync' '"disabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_frameskip' '"Off"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_frameskiptype' '"Number'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_gpu_hardware_transform' '"enabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_ignore_bad_memory_access' '"enabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_inflight_frames' '"Up'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_internal_resolution' '"1440x816"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_io_timing_method' '"Fast"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_language' '"Automatic"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_lazy_texture_caching' '"disabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_locked_cpu_speed' '"off"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_lower_resolution_for_effects' '"Off"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_rendering_mode' '"Buffered"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_retain_changed_textures' '"disabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_software_skinning' '"enabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_spline_quality' '"Low"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_anisotropic_filtering' '"off"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_deposterize' '"disabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_filtering' '"Auto"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_replacement' '"enabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_scaling_level' '"Off"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_scaling_type' '"xbrz"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_shader' '"Off"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_vertex_cache' '"disabled"'
}

RetroArch_Beetle_PCE_Fast_bezelOn(){
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'custom_viewport_height' '"1200"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'custom_viewport_x' '"0"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/pcengine.cfg"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_hide_in_menu' '"false"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_scale_landscape' '"1.025000"'
}

RetroArch_Mesen_bezelOn(){
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/nes.cfg"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_opacity' '"0.700000"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_scale_landscape' '"1.070000"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'video_scale_integer' '"false"'
}

RetroArch_Mupen64Plus_Next_setConfig(){
	RetroArch_setOverride 'Mupen64Plus_Next.cfg' 'Mupen64Plus_Next'  'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'Mupen64Plus_Next.cfg' 'Mupen64Plus_Next'  'video_crop_overscan' '"false"'
	RetroArch_setOverride 'Mupen64Plus_Next.cfg' 'Mupen64Plus_Next'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'Mupen64Plus_Next.cfg' 'Mupen64Plus_Next'  'video_smooth' '"true"'
}

RetroArch_Beetle_Lynx_bezelOn(){
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/lynx.cfg"'
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_opacity' '"0.700000"'
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_scale_landscape' '"1.170000"'
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'video_scale_integer' '"false"'
}

RetroArch_Beetle_Lynx_lynx_shaderOn(){
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'video_shader_enable' 'true'
}

RetroArch_Beetle_Lynx_lynx_shaderOff(){
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'video_shader_enable' 'false'
}

RetroArch_SameBoy_gb_setConfig(){
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_dark_filter_level' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_bootloader' '"enabled"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_colorization' '"internal"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_hwmode' '"Auto"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_internal_palette' '"GB'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_mode' '"Not'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_port' '"56400"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_1' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_10' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_11' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_12' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_2' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_3' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_4' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_5' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_6' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_7' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_8' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_9' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_palette_twb64_1' '"TWB64'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_palette_twb64_2' '"TWB64'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_mix_frames' '"disabled"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_rumble_level' '"10"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_show_gb_link_settings' '"disabled"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_turbo_period' '"4"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_up_down_allowed' '"disabled"'
}

RetroArch_SameBoy_bezelOn(){
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/gb.cfg"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay_scale_landscape' '"1.860000"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay_y_offset_landscape' '"-0.150000"'
}

RetroArch_SameBoy_gb_shaderOn(){
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'video_shader_enable' 'true'
}

RetroArch_SameBoy_gb_shaderOff(){
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'video_shader_enable' 'false'
}

RetroArch_SameBoy_gbc_setConfig(){
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gbc_color_correction' '"GBC'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gbc_color_correction_mode' '"accurate"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gbc_frontlight_position' '"central"'
}

RetroArch_SameBoy_gbc_bezelOn(){
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/gbc.cfg"'
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_scale_landscape' '"1.870000"'
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_y_offset_landscape' '"-0.220000"'
}

RetroArch_SameBoy_gbc_shaderOn(){
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'video_shader_enable' 'true'
}

RetroArch_SameBoy_gbc_shaderOff(){
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'video_shader_enable' 'false'
}

RetroArch_Beetle_NeoPop_ngp_bezelOn(){
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/ngpc.cfg"'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_aspect_adjust_landscape' '"-0.310000"'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_hide_in_menu' '"false"'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_scale_landscape' '"1.625000"'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_x_separation_portrait' '"-0.010000"'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_y_offset_landscape' '"-0.135000"'
}

RetroArch_Beetle_NeoPop_ngp_shaderOn(){
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'video_shader_enable' 'true'
}

RetroArch_Beetle_NeoPop_ngp_shaderOff(){
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'video_shader_enable' 'false'
}

RetroArch_Beetle_NeoPop_ngpc_bezelOn(){
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/ngpc.cfg"'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_aspect_adjust_landscape' '"-0.170000"'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_scale_landscape' '"1.615000"'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_x_separation_portrait' '"-0.010000"'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_y_offset_landscape' '"-0.135000"'
}

RetroArch_Beetle_NeoPop_ngpc_shaderOn(){
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'video_shader_enable' 'true'
}

RetroArch_Beetle_NeoPop_ngpc_shaderOff(){
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'video_shader_enable' 'false'
}
RetroArch_Stella_bezelOn(){
	RetroArch_setOverride 'atari2600.cfg' 'Stella'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/atari2600.cfg"'
	RetroArch_setOverride 'atari2600.cfg' 'Stella'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'atari2600.cfg' 'Stella'  'input_overlay_scale_landscape' '"1.0"'
}
RetroArch_MAME_2003_Plus_bezelOn(){

	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/MAME_Horizontal.cfg"'
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_overlay_opacity' '"0.700000"'
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_overlay_scale_landscape' '"1.170000"'
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'video_scale_integer' '"false"'
}
RetroArch_MAME_2003_Plus_shaderOn(){
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'video_shader_enable' 'true'
}

RetroArch_MAME_2003_Plus_shaderOff(){
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'video_shader_enable' 'false'
}

RetroArch_Genesis_Plus_GX_segacd_bezelOn(){
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/SEGACD.cfg"'
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_hide_in_menu' '"false"'
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000'

	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/SEGACD.cfg"'
	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_hide_in_menu' '"false"'
	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000'
}

RetroArch_Genesis_Plus_GX_bezelOn(){
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/genesis.cfg"'
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000"'
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'

}

RetroArch_Genesis_Plus_GX_genesis_shaderOn(){
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
}

RetroArch_Genesis_Plus_GX_genesis_shaderOff(){
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'video_shader_enable' '"false"'
}


RetroArch_Multiple_gamegear_bezelOn(){
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/gg.cfg"'
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_aspect_adjust_landscape' '"-0.115000"'
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.545000"'

	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/gg.cfg"'
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_aspect_adjust_landscape' '"-0.115000"'
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_scale_landscape' '"1.545000"'
}

RetroArch_Multiple_gamegear_shaderOn(){
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'video_shader_enable' '"true"'
}

RetroArch_Multiple_gamegear_shaderOff(){
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'video_shader_enable' '"true"'
}

RetroArch_Genesis_Plus_GX_mastersystem_bezelOn(){
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/mastersystem.cfg"'
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000"'
}

RetroArch_PicoDrive_sega32x_bezelOn(){
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/sega32x.cfg"'
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_hide_in_menu' '"false"'
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_scale_landscape' '"1.250000"'
}

RetroArch_mGBA_bezelOn(){
	#missing stuff?
	RetroArch_setOverride 'gba.cfg' 'mGBA'  'aspect_ratio_index' '"21"'
}

RetroArch_mGBA_shaderOn(){
	RetroArch_setOverride 'gba.cfg' 'mGBA'  'video_shader_enable' '"true"'
}

RetroArch_mGBA_shaderOn(){
	RetroArch_setOverride 'gba.cfg' 'mGBA'  'video_shader_enable' '"false"'
}



RetroArch_Gambatte_gb_bezelOn(){
	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/gb.cfg"'
	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay_scale_landscape' '"1.860000"'
	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay_y_offset_landscape' '"-0.150000"'
}

RetroArch_Gambatte_gb_shaderOn(){
	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'video_shader_enable' '"true"'
}

RetroArch_Gambatte_gb_shaderOn(){
	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'video_shader_enable' '"false"'
}

RetroArch_Gambatte_gbc_bezelOn(){
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/gbc.cfg"'
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_scale_landscape' '"1.870000"'
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_y_offset_landscape' '"-0.220000"'
}

RetroArch_Gambatte_gbc_shaderOn(){
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'video_shader_enable' '"true"'
}

RetroArch_Gambatte_gbc_shaderOn(){
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'video_shader_enable' '"false"'
}



RetroArch_Snes9x_bezelOn(){
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/snes.cfg"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_opacity' '"0.700000"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'video_scale_integer' '"false"'
}

RetroArch_Snes9x_ar43(){
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_scale_landscape' '"1.170000"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_aspect_adjust_landscape' '"0"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/snes.cfg"'
}

RetroArch_Snes9x_ar87(){
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/snes87.cfg"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_scale_landscape' '"1.380000"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_aspect_adjust_landscape' '"-0.170000"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'aspect_ratio_index' '"21"'
}


RetroArch_Nestopia_bezelOn(){
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay' '"/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays/pegasus/nes.cfg"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_opacity' '"0.700000"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_scale_landscape' '"1.070000"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'video_scale_integer' '"false"'
}

RetroArch_bsnes_hd_beta_bezelOn(){
	RetroArch_setOverride 'sneshd.cfg' 'bsnes-hd beta'  'video_scale_integer' '"false"'
}

#BezelOn
RetroArch_bezelOn(){
	echo "NYI"
}

#BezelOff
RetroArch_bezelOff(){
	echo "NYI"
}

#finalExec - Extra stuff
RetroArch_finalize(){
	echo "NYI"
}

RetroArch_installCores(){

	#Requests for:
	#GP32
	#N-gage
	#Game.com

	mkdir -p "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores"
	raUrl="https://buildbot.libretro.com/nightly/linux/x86_64/latest/"
	RAcores=(bsnes_hd_beta_libretro.so flycast_libretro.so gambatte_libretro.so genesis_plus_gx_libretro.so \
			genesis_plus_gx_wide_libretro.so mednafen_lynx_libretro.so mednafen_ngp_libretro.so mednafen_wswan_libretro.so melonds_libretro.so \
			mesen_libretro.so mgba_libretro.so mupen64plus_next_libretro.so nestopia_libretro.so picodrive_libretro.so ppsspp_libretro.so snes9x_libretro.so \
			stella_libretro.so yabasanshiro_libretro.so yabause_libretro.so yabause_libretro.so mame2003_plus_libretro.so mame2010_libretro.so mame_libretro.so \
			melonds_libretro.so fbneo_libretro.so bluemsx_libretro.so desmume_libretro.so sameboy_libretro.so gearsystem_libretro.so mednafen_saturn_libretro.so \
			opera_libretro.so dosbox_core_libretro.so dosbox_pure_libretro.so dosbox_svn_libretro.so puae_libretro.so)
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
	

	RAcores=(a5200_libretro.so 81_libretro.so atari800_libretro.so bluemsx_libretro.so chailove_libretro.so fbneo_libretro.so freechaf_libretro.so \
			freeintv_libretro.so fuse_libretro.so gearsystem_libretro.so gw_libretro.so hatari_libretro.so lutro_libretro.so mednafen_pcfx_libretro.so \
			mednafen_vb_libretro.so mednafen_wswan_libretro.so mu_libretro.so neocd_libretro.so nestopia_libretro.so nxengine_libretro.so o2em_libretro.so \
			picodrive_libretro.so pokemini_libretro.so prboom_libretro.so prosystem_libretro.so px68k_libretro.so quasi88_libretro.so scummvm_libretro.so \
			squirreljme_libretro.so theodore_libretro.so uzem_libretro.so vecx_libretro.so vice_xvic_libretro.so virtualjaguar_libretro.so x1_libretro.so \
			mednafen_lynx_libretro.so mednafen_ngp_libretro.so mednafen_pce_libretro.so mednafen_pce_fast_libretro.so mednafen_psx_libretro.so mednafen_psx_hw_libretro.so \
			mednafen_saturn_libretro.so mednafen_supafaust_libretro.so mednafen_supergrafx_libretro.so blastem_libretro.so bluemsx_libretro.so bsnes_libretro.so \
			bsnes_mercury_accuracy_libretro.so cap32_libretro.so citra2018_libretro.so citra_libretro.so crocods_libretro.so desmume2015_libretro.so desmume_libretro.so \
			dolphin_libretro.so dosbox_core_libretro.so dosbox_pure_libretro.so dosbox_svn_libretro.so fbalpha2012_cps1_libretro.so fbalpha2012_cps2_libretro.so \
			fbalpha2012_cps3_libretro.so fbalpha2012_libretro.so fbalpha2012_neogeo_libretro.so fceumm_libretro.so fbneo_libretro.so flycast_libretro.so fmsx_libretro.so \
			frodo_libretro.so gambatte_libretro.so gearboy_libretro.so gearsystem_libretro.so genesis_plus_gx_libretro.so genesis_plus_gx_wide_libretro.so gpsp_libretro.so \
			handy_libretro.so kronos_libretro.so mame2000_libretro.so mame2003_plus_libretro.so mame2010_libretro.so mame_libretro.so melonds_libretro.so mesen_libretro.so \
			mesen-s_libretro.so mgba_libretro.so mupen64plus_next_libretro.so nekop2_libretro.so np2kai_libretro.so nestopia_libretro.so parallel_n64_libretro.so \
			pcsx2_libretro.so pcsx_rearmed_libretro.so picodrive_libretro.so ppsspp_libretro.so puae_libretro.so quicknes_libretro.so race_libretro.so sameboy_libretro.so \
			smsplus_libretro.so snes9x2010_libretro.so snes9x_libretro.so stella2014_libretro.so stella_libretro.so tgbdual_libretro.so vbam_libretro.so vba_next_libretro.so \
			vice_x128_libretro.so vice_x64_libretro.so vice_x64sc_libretro.so vice_xscpu64_libretro.so yabasanshiro_libretro.so yabause_libretro.so bsnes_hd_beta_libretro.so \
	swanstation_libretro.so)
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

RetroArch_autoSaveOn(){
	changeLine 'savestate_auto_load = ' 'savestate_auto_load = "true"' "$RetroArch_configFile"
	changeLine 'savestate_auto_save = ' 'savestate_auto_save = "true"' "$RetroArch_configFile"
}
RetroArch_autoSaveOn(){
	changeLine 'savestate_auto_load = ' 'savestate_auto_load = "false"' "$RetroArch_configFile"
	changeLine 'savestate_auto_save = ' 'savestate_auto_save = "false"' "$RetroArch_configFile"
}
RetroArch_retroAchievementsOn(){
	changeLine 'cheevos_enable = ' 'cheevos_enable = "true"' "$RetroArch_configFile"
}
RetroArch_retroAchievementsOff(){
	changeLine 'cheevos_enable = ' 'cheevos_enable = "false"' "$RetroArch_configFile"
}
RetroArch_retroAchievementsPromptLogin(){
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
RetroArch_retroAchievementsSetLogin(){
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
RetroArch_setSNESAR(){
	AR=$1
	if [ $SNESAR == 43 ]; then	
		cp ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes43.cfg ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes.cfg	
	else
		cp ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes87.cfg ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes.cfg	
	fi	
}
RetroArch_bezelOn(){
	if [ $RABezels == true ]; then	
		find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.bak" | while read f; do mv -v "$f" "${f%.*}.cfg"; done 
	else
		find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.cfg" | while read f; do mv -v "$f" "${f%.*}.bak"; done 
	fi	
}
