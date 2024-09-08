#!/bin/bash

#variables
Android_RetroArch_emuName="RetroArch"
Android_RetroArch_emuPath="$Android_temp_internal/RetroArch"
Android_RetroArch_path="$Android_temp_internal/RetroArch/config/"
Android_RetroArch_configFile="$Android_temp_internal/retroarch.cfg"
Android_RetroArch_coreConfigFolders="$Android_temp_internal/RetroArch/config"

#cleanupOlderThings
Android_RetroArch_cleanup(){
	echo "NYI"
}

Android_RetroArch_backupConfigs(){
	cp -vp "$Android_RetroArch_configFile" "$Android_RetroArch_configFile.bak"
	find "$Android_RetroArch_coreConfigFolders" -type f -name "*.cfg" -o -type f -name "*.opt" -o -type f -name "*.slangp" -o -type f -name "*.glslp"| while read -r backupfile
	do
		cp -vp "$backupfile" "$backupfile.bak"
	done
}


function Android_RetroArch_install(){
	setMSG "Installing RetroArch"
	temp_url="https://buildbot.libretro.com/stable/1.16.0/android/RetroArch_aarch64.apk"
	temp_emu="ra"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}


#ApplyInitialSettings
Android_RetroArch_init(){
	#Android_RetroArch_backupConfigs
	#Android_RetroArch_setEmulationFolder
	#Android_RetroArch_setupSaves
	#Android_RetroArch_setupStorage
	#Android_RetroArch_installCores
	Android_RetroArch_setUpCoreOptAll
	Android_RetroArch_setConfigAll
	#Android_RetroArch_setupConfigurations
	Android_RetroArch_setCustomizations
	#Android_RetroArch_autoSave
	#Android_RetroArch_setRetroAchievements
	#Android_RetroArch_melonDSDSMigration
	#Android_ADB_push $Android_RetroArch_emuPath $androidStoragePath
}



Android_RetroArch_setCustomizations(){
	# User customizations
	Android_RetroArch_setShadersCRT
	Android_RetroArch_setShaders3DCRT
	Android_RetroArch_setShadersMAT
	Android_RetroArch_setBezels

	#
	#New Aspect Ratios
	#

	#Sega Games
		#Master System
		#Genesis
		#Sega CD
		#Sega 32X

	case $arSega in
	  "32")
		Android_RetroArch_mastersystem_ar32
		Android_RetroArch_genesis_ar32
		Android_RetroArch_segacd_ar32
		  Android_RetroArch_sega32x_ar32
		;;
	  *)
		Android_RetroArch_mastersystem_ar43
		Android_RetroArch_genesis_ar43
		  Android_RetroArch_segacd_ar43
		  Android_RetroArch_sega32x_ar43
		  if [ "$RABezels" == true ] && [ "$doSetupRA" == "true" ]; then
			  Android_RetroArch_mastersystem_bezelOn
			  Android_RetroArch_genesis_bezelOn
			  Android_RetroArch_segacd_bezelOn
			  Android_RetroArch_sega32x_bezelOn
		fi
	  ;;
	esac

	#Snes and NES
	case $arSnes in
	  "87")
		Android_RetroArch_snes_ar87
		Android_RetroArch_nes_ar87
	  ;;
	  "32")
			Android_RetroArch_snes_ar32
		  Android_RetroArch_nes_ar32
		;;
	  *)
		Android_RetroArch_snes_ar43
		Android_RetroArch_nes_ar43
		if [ "$RABezels" == true ] && [ "$doSetupRA" == "true" ]; then
			Android_RetroArch_snes_bezelOn
		fi
	  ;;
	esac
	# Classic 3D Games
		#Dreamcast
		#PSX
		#Nintendo 64
		#Saturn
		#Xbox
	if [ "$arClassic3D" == 169 ]; then
			Android_RetroArch_Beetle_PSX_HW_wideScreenOn
			Android_RetroArch_Flycast_wideScreenOn
			Android_RetroArch_dreamcast_bezelOff
			Android_RetroArch_psx_bezelOff
			Android_RetroArch_n64_wideScreenOn
			Android_RetroArch_SwanStation_wideScreenOn
	else
			Android_RetroArch_Flycast_wideScreenOff
			Android_RetroArch_n64_wideScreenOff
			Android_RetroArch_Beetle_PSX_HW_wideScreenOff
			Android_RetroArch_SwanStation_wideScreenOff
		#"Bezels on"
		if [ "$RABezels" == true ]; then
			Android_RetroArch_dreamcast_bezelOn
			Android_RetroArch_n64_bezelOn
			Android_RetroArch_psx_bezelOn
		fi
	fi
}

Android_RetroArch_setRetroAchievements(){
	#RetroAchievments
	Android_RetroArch_retroAchievementsSetLogin
	if [ "$achievementsHardcore" == "true" ]; then
		Android_RetroArch_retroAchievementsHardCoreOn
	else
		Android_RetroArch_retroAchievementsHardCoreOff
	fi
}


#ConfigurePaths
Android_RetroArch_setEmulationFolder(){
	system_directory='system_directory = '
	system_directorySetting="${system_directory}""\"${biosPath}\""
	Android_RetroArch_setConfigOverride "$system_directory" "$system_directorySetting" "$Android_RetroArch_configFile"

	rgui_browser_directory='rgui_browser_directory = '
	rgui_browser_directorySetting="${rgui_browser_directory}""\"${romsPath}\""
	Android_RetroArch_setConfigOverride "$rgui_browser_directory" "$rgui_browser_directorySetting" "$Android_RetroArch_configFile"

}

#SetupSaves
Android_RetroArch_setupSaves(){
	Android_RetroArch_setConfigOverride 'savestate_directory' "$savesPath/retroarch/states" "$Android_RetroArch_configFile"
	Android_RetroArch_setConfigOverride 'savefile_directory' "$savesPath/retroarch/saves" "$Android_RetroArch_configFile"
}

#SetupConfigurations
Android_RetroArch_setupConfigurations(){

	# Set input driver to SDL. X input driver does not seem to work ootb on some non-SteamOS distributions including ChimeraOS.
	input_driver='input_driver = '
	input_driverSetting="${input_driver}"\""sdl"\"
	changeLine "$input_driver" "$input_driverSetting" "$Android_RetroArch_configFile"

	# Set microphone driver to SDL. Potentially fixes RetroArch hanging when closing content.
	microphone_driver='microphone_driver = '
	microphone_driverSetting="${microphone_driver}"\""sdl"\"
	changeLine "$microphone_driver" "$microphone_driverSetting" "$Android_RetroArch_configFile"

}

#WipeSettings
Android_RetroArch_wipe(){
	echo "NYI"
}


#Uninstall
Android_RetroArch_uninstall(){
	echo "NYI"
}

#setABXYstyle
Android_RetroArch_setABXYstyle(){
	echo "NYI"
}

#Migrate
Android_RetroArch_migrate(){
	echo "NYI"
}

#WideScreenOn
Android_RetroArch_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
Android_RetroArch_wideScreenOff(){
echo "NYI"
}

Android_RetroArch_setOverride(){
	local fileName=$1
	local coreName=$2
	local option=$3
	local value=$4
	local settingLine="$option = $value"
	local fullPath="$Android_RetroArch_coreConfigFolders/$coreName"
	local configFile="$fullPath/$fileName"

	if [[ $value == 'ED_RM_LINE' ]]; then
		echo "Deleting $option from $configFile"
		sed -i '/^'"$option"'/d' "$configFile"
	else
		updateOrAppendConfigLine "$configFile" "$option =" "$settingLine"
	fi
}

Android_RetroArch_setConfigOverride(){
	local option=$1
	local value=$2
	local configFile=$3
	local settingLine="$option = $value"

	if [[ $value == 'ED_RM_LINE' ]]; then
		echo "Deleting $option from $configFile"
		sed -i '/^'"$option"'/d' "$configFile"
	else
		updateOrAppendConfigLine "$configFile" "$option =" "$settingLine"
	fi
}

Android_RetroArch_vice_xvic_setConfig(){
	Android_RetroArch_setOverride 'xvic.cfg' 'VICE xvic'  'video_driver' '"glcore"'
}
Android_RetroArch_vice_xscpu64_setConfig(){
	Android_RetroArch_setOverride 'xscpu64.cfg' 'VICE xscpu64'  'video_driver' '"glcore"'
}
Android_RetroArch_vice_x64sc_setConfig(){
	Android_RetroArch_setOverride 'x64sc.cfg' 'VICE x64sc'  'video_driver' '"glcore"'
}
Android_RetroArch_vice_x64_setConfig(){
	Android_RetroArch_setOverride 'x64.cfg' 'VICE x64'  'video_driver' '"glcore"'
}

Android_RetroArch_wswanc_setConfig(){
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'  'input_player1_analog_dpad_mode' '"1"'
}
Android_RetroArch_wswanc_bezelOn(){
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'  'input_overlay_enable' '"false"'
}
Android_RetroArch_wswanc_bezelOff(){
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'  'input_overlay_enable' '"false"'
}
Android_RetroArch_wswanc_MATshaderOn(){
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'  'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'	'video_smooth' '"false"'

	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'  'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'	 'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'	 'video_smooth' '"false"'
}

Android_RetroArch_wswanc_MATshaderOff(){
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'  'video_shader_enable' 'false'
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'	'video_smooth' '"true"'

	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'  'video_shader_enable' 'false'
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'	 'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'	 'video_smooth' '"true"'
}

Android_RetroArch_wswan_setConfig(){
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'  'input_player1_analog_dpad_mode' '"1"'
}
Android_RetroArch_wswan_bezelOn(){
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'  'input_overlay_enable' '"false"'
}

Android_RetroArch_wswan_bezelOff(){
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'  'input_overlay_enable' '"false"'
}

Android_RetroArch_wswan_MATshaderOn(){
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'  'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'	'video_smooth' '"false"'

	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'  'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'	 'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'	 'video_smooth' '"false"'
}

Android_RetroArch_wswan_MATshaderOff(){
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'  'video_shader_enable' 'false'
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'	'video_smooth' '"true"'

	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'  'video_shader_enable' 'false'
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'	 'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'	 'video_smooth' '"true"'
}

Android_RetroArch_dolphin_emu_setConfig(){
	Android_RetroArch_setOverride 'dolphin_emu.cfg' 'dolphin_emu'  'video_driver' '"gl"'
	Android_RetroArch_setOverride 'dolphin_emu.cfg' 'dolphin_emu'  'video_driver' '"gl"'
}

Android_RetroArch_PPSSPP_setConfig(){
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_auto_frameskip' '"disabled"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_block_transfer_gpu' '"enabled"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_button_preference' '"Cross"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_cheats' '"disabled"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_cpu_core' '"JIT"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_disable_slow_framebuffer_effects' '"disabled"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_fast_memory' '"enabled"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_force_lag_sync' '"disabled"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_frameskip' '"Off"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_frameskiptype' '"Number'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_gpu_hardware_transform' '"enabled"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_ignore_bad_memory_access' '"enabled"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_inflight_frames' '"Up'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_internal_resolution' '"1440x816"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_io_timing_method' '"Fast"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_language' '"Automatic"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_lazy_texture_caching' '"disabled"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_locked_cpu_speed' '"off"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_lower_resolution_for_effects' '"Off"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_rendering_mode' '"Buffered"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_retain_changed_textures' '"disabled"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_software_skinning' '"enabled"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_spline_quality' '"Low"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_anisotropic_filtering' '"off"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_deposterize' '"disabled"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_filtering' '"Auto"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_replacement' '"enabled"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_scaling_level' '"Off"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_scaling_type' '"xbrz"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_shader' '"Off"'
	Android_RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_vertex_cache' '"disabled"'
}

Android_RetroArch_pcengine_setConfig(){
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'input_player1_analog_dpad_mode' '"1"'
}
Android_RetroArch_pcengine_bezelOn(){
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'custom_viewport_height' '"1200"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'custom_viewport_x' '"0"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/pcengine.cfg"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_aspect_adjust_landscape' '"-0.150000"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_scale_landscape' '"1.075000"'

	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'custom_viewport_height' '"1200"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'custom_viewport_x' '"0"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/pcengine.cfg"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'input_overlay_aspect_adjust_landscape' '"-0.150000"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'input_overlay_scale_landscape' '"1.075000"'

	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'custom_viewport_height' '"1200"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'custom_viewport_x' '"0"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/pcengine.cfg"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'input_overlay_aspect_adjust_landscape' '"-0.150000"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'input_overlay_scale_landscape' '"1.075000"'

	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'custom_viewport_height' '"1200"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'custom_viewport_x' '"0"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/pcengine.cfg"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'input_overlay_aspect_adjust_landscape' '"-0.150000"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'input_overlay_scale_landscape' '"1.075000"'

}

Android_RetroArch_pcengine_bezelOff(){
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'input_overlay_enable' '"false"'
}

Android_RetroArch_pcengine_CRTshaderOn(){
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'	'video_smooth' '"false"'

	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'	'video_smooth' '"false"'

	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'	'video_smooth' '"false"'

	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'	'video_smooth' '"false"'
}

Android_RetroArch_pcengine_CRTshaderOff(){
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'	'video_smooth' '"true"'

	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'	'video_smooth' '"true"'

	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'	'video_smooth' '"true"'

	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'	'video_smooth' '"true"'
}

Android_RetroArch_amiga1200_CRTshaderOff(){
	Android_RetroArch_setOverride 'amiga1200.cfg' 'PUAE'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'amiga1200.cfg' 'PUAE'  'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'amiga1200.cfg' 'PUAE'  'video_smooth' '"true"'
}

Android_RetroArch_amiga1200_CRTshaderOn(){
	Android_RetroArch_setOverride 'amiga1200.cfg' 'PUAE'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'amiga1200.cfg' 'PUAE'  'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'amiga1200.cfg' 'PUAE'  'video_smooth' '"false"'
}

Android_RetroArch_amiga1200_setUpCoreOpt(){
	Android_RetroArch_setOverride 'amiga1200.opt' 'PUAE'  'puae_model' '"A1200"'
}

Android_RetroArch_nes_setConfig(){
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_player1_analog_dpad_mode' '"1"'
}

Android_RetroArch_nes_bezelOn(){
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/nes.cfg"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_opacity' '"0.700000"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_scale_landscape' '"1.070000"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_aspect_adjust_landscape' '"0.100000"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'video_scale_integer' '"false"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'aspect_ratio_index' '"0"'



	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/nes.cfg"'
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_opacity' '"0.700000"'
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_scale_landscape' '"1.070000"'
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_aspect_adjust_landscape' '"0.100000"'
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'video_scale_integer' '"false"'
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'aspect_ratio_index' '"0"'

	case $arSnes in
	  "87")
		Android_RetroArch_nes_ar87
	  ;;
	  "32")
		  Android_RetroArch_nes_ar32
		;;
	  *)
		Android_RetroArch_nes_ar43
	  ;;
	esac


}

Android_RetroArch_nes_bezelOff(){
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_enable' '"false"'
}

Android_RetroArch_nes_CRTshaderOn(){
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'	'video_smooth' '"false"'

	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'	'video_smooth' '"false"'
}

Android_RetroArch_nes_CRTshaderOff(){
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'	'video_smooth' '"true"'

	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'	'video_smooth' '"true"'
}

Android_RetroArch_nes_ar43(){
	#Android_RetroArch_nes_bezelOn
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'aspect_ratio_index' '"0"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'aspect_ratio_index' '"0"'
}

Android_RetroArch_nes_ar87(){
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_scale_landscape' '"1.380000"'
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_aspect_adjust_landscape' '"-0.170000"'
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'aspect_ratio_index' '"15"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_scale_landscape' '"1.380000"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_aspect_adjust_landscape' '"-0.170000"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'aspect_ratio_index' '"15"'
}

Android_RetroArch_nes_ar32(){
	Android_RetroArch_setOverride 'nes.cfg' 'Nestopia'  'aspect_ratio_index' '"7"'
	Android_RetroArch_setOverride 'nes.cfg' 'Mesen'  'aspect_ratio_index' '"7"'
	Android_RetroArch_nes_bezelOff
}

Android_RetroArch_Mupen64Plus_Next_setConfig(){
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'aspect_ratio_index' '"0"'
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_crop_overscan' '"false"'
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_smooth' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'input_overlay_auto_scale'  '"false"'
}




 Android_RetroArch_n64_3DCRTshaderOn(){
	 Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_smooth' 'ED_RM_LINE'
 }

Android_RetroArch_n64_3DCRTshaderOff(){
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_smooth' 'ED_RM_LINE'
}

Android_RetroArch_n64_setConfig(){
	Android_RetroArch_n64_3DCRTshaderOff
}

Android_RetroArch_lynx_setConfig(){
	Android_RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'input_player1_analog_dpad_mode' '"1"'
}

Android_RetroArch_lynx_bezelOn(){
	Android_RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/lynx.cfg"'
	Android_RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_opacity' '"0.700000"'
	Android_RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_scale_landscape' '"1.170000"'
	Android_RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'video_scale_integer' '"false"'

	Android_RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/lynx.cfg"'
	Android_RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'input_overlay_opacity' '"0.700000"'
	Android_RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'input_overlay_scale_landscape' '"1.170000"'
	Android_RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'video_scale_integer' '"false"'
}

Android_RetroArch_lynx_bezelOff(){
	Android_RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'input_overlay_enable' '"false"'
}

Android_RetroArch_lynx_MATshaderOn(){
	Android_RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'	'video_smooth' '"false"'

	Android_RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'atarilynx.cfg' 'Handy'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'atarilynx.cfg' 'Handy'	'video_smooth' '"false"'
}

Android_RetroArch_lynx_MATshaderOff(){
	Android_RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'video_shader_enable' 'false'
	Android_RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'	'video_smooth' '"true"'

	Android_RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'video_shader_enable' 'false'
	Android_RetroArch_setOverride 'atarilynx.cfg' 'Handy'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'atarilynx.cfg' 'Handy'	'video_smooth' '"true"'
}


Android_RetroArch_SameBoy_gb_setConfig(){
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_dark_filter_level' '"0"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_bootloader' '"enabled"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_colorization' '"internal"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_hwmode' '"Auto"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_internal_palette' '"GB'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_mode' '"Not'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_port' '"56400"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_1' '"0"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_10' '"0"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_11' '"0"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_12' '"0"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_2' '"0"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_3' '"0"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_4' '"0"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_5' '"0"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_6' '"0"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_7' '"0"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_8' '"0"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_9' '"0"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_palette_twb64_1' '"TWB64'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_palette_twb64_2' '"TWB64'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_mix_frames' '"disabled"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_rumble_level' '"10"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_show_gb_link_settings' '"disabled"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_turbo_period' '"4"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_up_down_allowed' '"disabled"'
}

Android_RetroArch_ngp_setConfig(){
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_player1_analog_dpad_mode' '"1"'
}

Android_RetroArch_ngp_bezelOn(){
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/ngpc.cfg"'
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_aspect_adjust_landscape' '"-0.310000"'
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_hide_in_menu' '"false"'
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_scale_landscape' '"1.625000"'
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_x_separation_portrait' '"-0.010000"'
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_y_offset_landscape' '"-0.135000"'
}

Android_RetroArch_ngp_bezelOff(){
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_enable' '"false"'
}

Android_RetroArch_ngp_MATshaderOn(){
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'	 'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'	 'video_smooth' '"false"'
}

Android_RetroArch_ngp_MATshaderOff(){
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'video_shader_enable' 'false'
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'	 'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'	 'video_smooth' '"true"'
}

Android_RetroArch_ngpc_setConfig(){
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_player1_analog_dpad_mode' '"1"'
}

Android_RetroArch_ngpc_bezelOn(){
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/ngpc.cfg"'
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_aspect_adjust_landscape' '"-0.170000"'
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_scale_landscape' '"1.615000"'
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_x_separation_portrait' '"-0.010000"'
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_y_offset_landscape' '"-0.135000"'
}

Android_RetroArch_ngpc_bezelOff(){
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_enable' '"false"'
}

Android_RetroArch_ngpc_MATshaderOn(){
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'video_smooth' '"false"'
}

Android_RetroArch_ngpc_MATshaderOff(){
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'video_shader_enable' 'false'
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'video_smooth' '"true"'
}

Android_RetroArch_atari2600_setConfig(){
	Android_RetroArch_setOverride 'atari2600.cfg' 'Stella'  'input_player1_analog_dpad_mode' '"1"'
}

Android_RetroArch_atari2600_bezelOn(){
	Android_RetroArch_setOverride 'atari2600.cfg' 'Stella'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/atari2600.cfg"'
	Android_RetroArch_setOverride 'atari2600.cfg' 'Stella'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'atari2600.cfg' 'Stella'  'input_overlay_aspect_adjust_landscape' '"0.095000"'
	Android_RetroArch_setOverride 'atari2600.cfg' 'Stella'  'input_overlay_scale_landscape' '"1.070000"'
	Android_RetroArch_setOverride 'atari2600.cfg' 'Stella'  'aspect_ratio_index' '"0"'
}

Android_RetroArch_atari2600_bezelOff(){
	Android_RetroArch_setOverride 'atari2600.cfg' 'Stella' 'input_overlay_enable' '"false"'
}

Android_RetroArch_atari2600_CRTshaderOn(){
	Android_RetroArch_setOverride 'atari2600.cfg' 'Stella' 'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'atari2600.cfg' 'Stella'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'atari2600.cfg' 'Stella'	'video_smooth' '"false"'
}

Android_RetroArch_atari2600_CRTshaderOff(){
	Android_RetroArch_setOverride 'atari2600.cfg' 'Stella' 'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'atari2600.cfg' 'Stella'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'atari2600.cfg' 'Stella'	'video_smooth' '"true"'
}

Android_RetroArch_mame_setConfig(){
	Android_RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'mame.cfg' 'MAME'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'mame.cfg' 'MAME'  'cheevos_enable = "false"'
}

Android_RetroArch_mame_bezelOn(){
	Android_RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'mame.cfg' 'MAME'  'input_overlay_enable' '"false"'
}

Android_RetroArch_mame_bezelOff(){
	Android_RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'mame.cfg' 'MAME'  'input_overlay_enable' '"false"'
}

Android_RetroArch_mame_CRTshaderOn(){
	Android_RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'   'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'	'video_smooth' '"false"'

	Android_RetroArch_setOverride 'mame.cfg' 'MAME' 'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'mame.cfg' 'MAME'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'mame.cfg' 'MAME'	'video_smooth' '"false"'
}

Android_RetroArch_mame_CRTshaderOff(){
	Android_RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'video_shader_enable' 'false'
	Android_RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'	'video_smooth' '"true"'

	Android_RetroArch_setOverride 'mame.cfg' 'MAME'  'video_shader_enable' 'false'
	Android_RetroArch_setOverride 'mame.cfg' 'MAME'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'mame.cfg' 'MAME'	'video_smooth' '"true"'
}

Android_RetroArch_neogeo_bezelOn(){
	Android_RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'  'input_overlay' "/storage/emulated/0/RetroArch/overlays/pegasus/neogeo.cfg"
	Android_RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'  'input_overlay_hide_in_menu' '"false"'
	Android_RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'  'input_overlay_scale_landscape' '"1.170000'
}

Android_RetroArch_neogeo_bezelOff(){
	Android_RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'  'input_overlay_enable' '"false"'
}

Android_RetroArch_neogeo_CRTshaderOn(){
	Android_RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo' 'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'	'video_smooth' '"false"'
}

Android_RetroArch_neogeo_CRTshaderOff(){
	Android_RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo' 'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'	'video_smooth' '"true"'
}

Android_RetroArch_fbneo_bezelOn(){
	Android_RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'  'input_overlay' "/storage/emulated/0/RetroArch/overlays/pegasus/neogeo.cfg"
	Android_RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'  'input_overlay_hide_in_menu' '"false"'
	Android_RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'  'input_overlay_scale_landscape' '"1.170000'
}

Android_RetroArch_fbneo_bezelOff(){
	Android_RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'  'input_overlay_enable' '"false"'
}

Android_RetroArch_fbneo_CRTshaderOn(){
	Android_RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo' 'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'	'video_smooth' '"false"'
}

Android_RetroArch_fbneo_CRTshaderOff(){
	Android_RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo' 'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'	'video_smooth' '"true"'
}


Android_RetroArch_segacd_setConfig(){
	Android_RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_player1_analog_dpad_mode' '"1"'
}

Android_RetroArch_segacd_bezelOn(){
	Android_RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/segacd.cfg"'
	Android_RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_hide_in_menu' '"false"'
	Android_RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000'
	Android_RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"0"'

	Android_RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/segacd.cfg"'
	Android_RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_hide_in_menu' '"false"'
	Android_RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000'
	Android_RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"0"'
}
Android_RetroArch_segacd_bezelOff(){
	Android_RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"false"'
}

Android_RetroArch_segacd_CRTshaderOn(){
	Android_RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
}

Android_RetroArch_segacd_CRTshaderOff(){
	Android_RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'video_shader_enable' '"false"'
}


Android_RetroArch_segacd_ar32(){
	Android_RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"7"'
	Android_RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"7"'
	Android_RetroArch_segacd_bezelOff
}
Android_RetroArch_segacd_ar43(){
	Android_RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
}

Android_RetroArch_genesis_setConfig(){
	Android_RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'input_player1_analog_dpad_mode' '"1"'
}

Android_RetroArch_genesis_bezelOn(){
	Android_RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/genesis.cfg"'
	Android_RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000"'
	Android_RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"0"'

	Android_RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/genesis.cfg"'
	Android_RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000"'
	Android_RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"0"'

}

Android_RetroArch_genesis_bezelOff(){
	Android_RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"false"'
}

Android_RetroArch_genesis_ar32(){
	Android_RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"7"'
	Android_RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"7"'
	Android_RetroArch_genesis_bezelOff
}

Android_RetroArch_genesis_ar43(){
	Android_RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
}

Android_RetroArch_genesis_CRTshaderOn(){
	Android_RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'	'video_smooth' '"false"'

	Android_RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'	'video_smooth' '"false"'
}

Android_RetroArch_genesis_CRTshaderOff(){
	Android_RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'	'video_smooth' '"true"'

	Android_RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'	'video_smooth' '"true"'
}

Android_RetroArch_gamegear_setConfig(){
	Android_RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_player1_analog_dpad_mode' '"1"'
}

Android_RetroArch_gamegear_bezelOn(){
	Android_RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/gg.cfg"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_aspect_adjust_landscape' '"-0.115000"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.545000"'

	Android_RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/gg.cfg"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_aspect_adjust_landscape' '"-0.115000"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_scale_landscape' '"1.545000"'
}

Android_RetroArch_gamegear_bezelOff(){
	Android_RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"false"'

	Android_RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_enable' '"false"'
}

Android_RetroArch_gamegear_MATshaderOn(){
	Android_RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'	'video_smooth' '"false"'

	Android_RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'	'video_smooth' '"false"'
}

Android_RetroArch_gamegear_MATshaderOff(){
	Android_RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'	'video_smooth' '"true"'

	Android_RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'	'video_smooth' '"true"'
}

Android_RetroArch_mastersystem_setConfig(){
	Android_RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_player1_analog_dpad_mode' '"1"'
}

Android_RetroArch_mastersystem_bezelOn(){
	Android_RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/mastersystem.cfg"'
	Android_RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000"'
}

Android_RetroArch_mastersystem_bezelOff(){
	Android_RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"false"'
}

Android_RetroArch_mastersystem_ar32(){
	Android_RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"7"'
	Android_RetroArch_mastersystem_bezelOff
}

Android_RetroArch_mastersystem_CRTshaderOn(){
	Android_RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'	'video_smooth' '"false"'
}

Android_RetroArch_mastersystem_CRTshaderOff(){
	Android_RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'	'video_smooth' '"true"'
}

Android_RetroArch_mastersystem_ar43(){
	Android_RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
}
Android_RetroArch_sega32x_setConfig(){
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_player1_analog_dpad_mode' '"1"'
}
Android_RetroArch_sega32x_bezelOn(){
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/sega32x.cfg"'
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_hide_in_menu' '"false"'
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_scale_landscape' '"1.070000"'
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_aspect_adjust_landscape' '"0.095000"'
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'aspect_ratio_index' '"0"'

	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/sega32x.cfg"'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_overlay_hide_in_menu' '"false"'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_overlay_scale_landscape' '"1.070000"'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_overlay_aspect_adjust_landscape' '"0.095000"'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'aspect_ratio_index' '"0"'
}

Android_RetroArch_sega32x_bezelOff(){
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_overlay_enable' '"false"'
}

Android_RetroArch_sega32x_CRTshaderOn(){
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'	 'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'	 'video_smooth' '"false"'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'	 'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'	 'video_smooth' '"false"'
}

Android_RetroArch_sega32x_CRTshaderOff(){
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'	 'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'	 'video_smooth' '"true"'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'	 'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'	 'video_smooth' '"true"'
}

Android_RetroArch_sega32x_ar32(){
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'aspect_ratio_index' '"7"'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'aspect_ratio_index' '"7"'
	Android_RetroArch_sega32x_bezelOff
}

Android_RetroArch_sega32x_ar43(){
	Android_RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'aspect_ratio_index' '"21"'
	Android_RetroArch_sega32x_bezelOff
}

#Android_RetroArch_gba_bezelOn(){
#	#missing stuff?
#	Android_RetroArch_setOverride 'gba.cfg' 'mGBA'  'aspect_ratio_index' '"21"'
#}
Android_RetroArch_gba_setConfig(){
	Android_RetroArch_setOverride 'gba.cfg' 'mGBA'  'input_player1_analog_dpad_mode' '"1"'
}
Android_RetroArch_gba_MATshaderOn(){
	Android_RetroArch_setOverride 'gba.cfg' 'mGBA'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'gba.cfg' 'mGBA'	 'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'gba.cfg' 'mGBA'	 'video_smooth' '"false"'
}

Android_RetroArch_gba_MATshaderOff(){
	Android_RetroArch_setOverride 'gba.cfg' 'mGBA'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'gba.cfg' 'mGBA'	 'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'gba.cfg' 'mGBA'	 'video_smooth' '"true"'
}

Android_RetroArch_gb_bezelOn(){
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/gb.cfg"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay_scale_landscape' '"1.860000"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay_y_offset_landscape' '"-0.150000"'

	Android_RetroArch_setOverride 'gb.cfg' 'Gambatte'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/gb.cfg"'
	Android_RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay_scale_landscape' '"1.860000"'
	Android_RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay_y_offset_landscape' '"-0.150000"'
}

Android_RetroArch_gb_setConfig(){
	Android_RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_player1_analog_dpad_mode' '"1"'
}

Android_RetroArch_gb_bezelOff(){
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay_enable' '"false"'


	Android_RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay_enable' '"false"'
}

Android_RetroArch_gb_MATshaderOn(){
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'	 'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'	 'video_smooth' '"false"'

	Android_RetroArch_setOverride 'gb.cfg' 'Gambatte'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'gb.cfg' 'Gambatte'	 'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'gb.cfg' 'Gambatte'	 'video_smooth' '"false"'
}

Android_RetroArch_gb_MATshaderOff(){
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'  'video_shader_enable' 'false'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'	 'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'gb.cfg' 'SameBoy'	 'video_smooth' '"true"'

	Android_RetroArch_setOverride 'gb.cfg' 'Gambatte'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'gb.cfg' 'Gambatte'	 'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'gb.cfg' 'Gambatte'	 'video_smooth' '"true"'
}

Android_RetroArch_SameBoy_gbc_setConfig(){
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'gambatte_gbc_color_correction' '"GBC'
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'gambatte_gbc_color_correction_mode' '"accurate"'
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'gambatte_gbc_frontlight_position' '"central"'
}


Android_RetroArch_gbc_setConfig(){
	Android_RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_player1_analog_dpad_mode' '"1"'
}

Android_RetroArch_gbc_bezelOn(){
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/gbc.cfg"'
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_scale_landscape' '"1.870000"'
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_y_offset_landscape' '"-0.220000"'

	Android_RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'aspect_ratio_index' '"21"'
	Android_RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/gbc.cfg"'
	Android_RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_scale_landscape' '"1.870000"'
	Android_RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_y_offset_landscape' '"-0.220000"'
}

Android_RetroArch_gbc_bezelOff(){
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_enable' '"false"'


	Android_RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_enable' '"false"'
}

Android_RetroArch_gbc_MATshaderOn(){
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'	 'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'	 'video_smooth' '"false"'

	Android_RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'gbc.cfg' 'Gambatte'	 'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'gbc.cfg' 'Gambatte'	 'video_smooth' '"false"'
}

Android_RetroArch_gbc_MATshaderOff(){
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'video_shader_enable' 'false'
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'	 'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'gbc.cfg' 'SameBoy'	 'video_smooth' '"true"'

	Android_RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'video_shader_enable' 'false'
	Android_RetroArch_setOverride 'gbc.cfg' 'Gambatte'	 'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'gbc.cfg' 'Gambatte'	 'video_smooth' '"true"'
}

Android_RetroArch_n64_wideScreenOn(){
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-aspect' '"16:9 adjusted"'
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'aspect_ratio_index' '"1"'
	Android_RetroArch_n64_bezelOff
	Android_RetroArch_n64_3DCRTshaderOff
}

Android_RetroArch_n64_wideScreenOff(){
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-aspect' '"4:3"'
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'aspect_ratio_index' '"0"'
	#Android_RetroArch_n64_bezelOn
}

Android_RetroArch_n64_bezelOn(){
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'aspect_ratio_index' '"0"'
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/N64.cfg"'
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'input_overlay_aspect_adjust_landscape' '"0.085000"'
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'input_overlay_scale_landscape' '"1.065000"'
}

Android_RetroArch_n64_bezelOff(){
	Android_RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'input_overlay_enable' '"false"'
}

Android_RetroArch_atari800_setConfig(){
	Android_RetroArch_setOverride 'atari800.cfg' 'Stella'  'input_player1_analog_dpad_mode' '"1"'
}

Android_RetroArch_atari800_bezelOn(){
	Android_RetroArch_setOverride 'atari800.cfg' 'Stella'  'aspect_ratio_index' '"0"'
	Android_RetroArch_setOverride 'atari800.cfg' 'Stella'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/atari800.cfg"'
	Android_RetroArch_setOverride 'atari800.cfg' 'Stella'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'atari800.cfg' 'Stella'  'input_overlay_hide_in_menu' '"true"'
	Android_RetroArch_setOverride 'atari800.cfg' 'Stella'  'input_overlay_scale_landscape' '"1.175000"'
	Android_RetroArch_setOverride 'atari800.cfg' 'Stella'  'input_overlay_aspect_adjust_landscape' '"0.000000"'
}

Android_RetroArch_atari800_bezelOff(){
	Android_RetroArch_setOverride 'atari800.cfg' 'Stella'  'input_overlay_enable' '"false"'
}

Android_RetroArch_atari5200_setConfig(){
	Android_RetroArch_setOverride 'atari5200.cfg' 'Stella'  'input_player1_analog_dpad_mode' '"1"'
}

Android_RetroArch_atari5200_bezelOn(){
	Android_RetroArch_setOverride 'atari5200.cfg' 'Stella'  'aspect_ratio_index' '"0"'
	Android_RetroArch_setOverride 'atari5200.cfg' 'Stella'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/atari5200.cfg"'
	Android_RetroArch_setOverride 'atari5200.cfg' 'Stella'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'atari5200.cfg' 'Stella'  'input_overlay_hide_in_menu' '"true"'
	Android_RetroArch_setOverride 'atari5200.cfg' 'Stella'  'input_overlay_scale_landscape' '"1.175000"'
	Android_RetroArch_setOverride 'atari5200.cfg' 'Stella'  'input_overlay_aspect_adjust_landscape' '"0.000000"'
}

Android_RetroArch_atari5200_bezelOff(){
	Android_RetroArch_setOverride 'atari5200.cfg' 'Stella'  'input_overlay_enable' '"false"'
}

Android_RetroArch_dreamcast_bezelOn(){
	Android_RetroArch_setOverride 'dreamcast.cfg' 'Flycast'  'aspect_ratio_index' '"0"'
	Android_RetroArch_setOverride 'dreamcast.cfg' 'Flycast'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/Dreamcast.cfg"'
	Android_RetroArch_setOverride 'dreamcast.cfg' 'Flycast'  'input_overlay_aspect_adjust_landscape' '"0.110000"'
	Android_RetroArch_setOverride 'dreamcast.cfg' 'Flycast'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'dreamcast.cfg' 'Flycast'  'input_overlay_scale_landscape' '"1.054998"'
}

Android_RetroArch_dreamcast_bezelOff(){
	Android_RetroArch_setOverride 'dreamcast.cfg' 'Flycast'  'input_overlay_enable' '"false"'
}

#temporary
Android_RetroArch_Flycast_bezelOff(){
	Android_RetroArch_dreamcast_bezelOff
}

Android_RetroArch_Flycast_bezelOn(){
	Android_RetroArch_dreamcast_bezelOn
}

Android_RetroArch_Beetle_PSX_HW_bezelOff(){
	Android_RetroArch_psx_bezelOff
}

Android_RetroArch_Beetle_PSX_HW_bezelOn(){
	Android_RetroArch_psx_bezelOn
}

 Android_RetroArch_dreamcast_3DCRTshaderOn(){
	 Android_RetroArch_setOverride 'dreamcast.cfg' 'Flycast' 'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'dreamcast.cfg' 'Flycast'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'dreamcast.cfg' 'Flycast'	'video_smooth' 'ED_RM_LINE'
 }

Android_RetroArch_dreamcast_setConfig(){
	Android_RetroArch_dreamcast_3DCRTshaderOff
}

Android_RetroArch_dreamcast_3DCRTshaderOff(){
	Android_RetroArch_setOverride 'dreamcast.cfg' 'Flycast' 'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'dreamcast.cfg' 'Flycast'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'dreamcast.cfg' 'Flycast'	'video_smooth' 'ED_RM_LINE'
}

Android_RetroArch_saturn_setConfig(){
	mkdir -p "$biosPath/kronos"
	Android_RetroArch_setOverride 'saturn.cfg' 'Yabause'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Kronos'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_saturn_3DCRTshaderOff
}

Android_RetroArch_saturn_bezelOn(){
	Android_RetroArch_setOverride 'saturn.cfg' 'Yabause'  'aspect_ratio_index' '"0"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Yabause'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/saturn.cfg"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Yabause'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Yabause'  'input_overlay_scale_landscape' '"1.070000"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Yabause'  'input_overlay_aspect_adjust_landscape' '"0.095000"'

	Android_RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'aspect_ratio_index' '"0"'
	Android_RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/saturn.cfg"'
	Android_RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'input_overlay_scale_landscape' '"1.070000"'
	Android_RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'input_overlay_aspect_adjust_landscape' '"0.095000"'


	Android_RetroArch_setOverride 'saturn.cfg' 'Kronos'  'aspect_ratio_index' '"0"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Kronos'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/saturn.cfg"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Kronos'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Kronos'  'input_overlay_scale_landscape' '"1.070000"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Kronos'  'input_overlay_aspect_adjust_landscape' '"0.095000"'

	Android_RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'aspect_ratio_index' '"0"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/saturn.cfg"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'input_overlay_scale_landscape' '"1.070000"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'input_overlay_aspect_adjust_landscape' '"0.095000"'
}

Android_RetroArch_saturn_bezelOff(){
	Android_RetroArch_setOverride 'saturn.cfg' 'Yabause'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Kronos'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'input_overlay_enable' '"false"'
}

 Android_RetroArch_saturn_3DCRTshaderOn(){
	 Android_RetroArch_setOverride 'saturn.cfg' 'Yabause'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Yabause'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'saturn.cfg' 'Yabause'	'video_smooth' 'ED_RM_LINE'

	 Android_RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'	'video_smooth' 'ED_RM_LINE'

	Android_RetroArch_setOverride 'saturn.cfg' 'Kronos'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Kronos'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'saturn.cfg' 'Kronos'	'video_smooth' 'ED_RM_LINE'

	 Android_RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'	'video_smooth' 'ED_RM_LINE'
 }

Android_RetroArch_saturn_3DCRTshaderOff(){
	Android_RetroArch_setOverride 'saturn.cfg' 'Yabause'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Kronos'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'video_shader_enable' '"false"'

	Android_RetroArch_setOverride 'saturn.cfg' 'Yabause'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'saturn.cfg' 'Yabause'	'video_smooth' 'ED_RM_LINE'

	Android_RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'	'video_smooth' 'ED_RM_LINE'

	Android_RetroArch_setOverride 'saturn.cfg' 'Kronos'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'saturn.cfg' 'Kronos'	'video_smooth' 'ED_RM_LINE'

	Android_RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'	'video_smooth' 'ED_RM_LINE'
}

Android_RetroArch_snes_setConfig(){
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_player1_analog_dpad_mode' '"1"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_player1_analog_dpad_mode' '"1"'
}

Android_RetroArch_snes_bezelOn(){
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/snes.cfg"'
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_opacity' '"0.700000"'
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'video_scale_integer' '"false"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/snes.cfg"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_auto_scale' '"false"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_opacity' '"0.700000"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'video_scale_integer' '"false"'

	case $arSnes in
	  "87")
		Android_RetroArch_snes_ar87
	  ;;
	  "32")
			Android_RetroArch_snes_ar32
		;;
	  *)
		Android_RetroArch_snes_ar43
	  ;;
	esac
}

Android_RetroArch_snes_bezelOff(){
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_enable' '"false"'
}

Android_RetroArch_snes_CRTshaderOn(){
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'	'video_smooth' '"false"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'video_shader_enable' '"true"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'	'video_smooth' '"false"'
}

Android_RetroArch_snes_CRTshaderOff(){
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'	'video_smooth' '"true"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'	'video_filter' '"/app/lib/retroarch/filters/video/Normal4x.filt"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'	'video_smooth' '"true"'
}

Android_RetroArch_snes_ar43(){
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'aspect_ratio_index' '"0"'
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_scale_landscape' '"1.170000"'
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_aspect_adjust_landscape' '"0"'
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/snes.cfg"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'aspect_ratio_index' '"0"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_scale_landscape' '"1.170000"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_aspect_adjust_landscape' '"0"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/snes.cfg"'
}

Android_RetroArch_snes_ar87(){
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/snes87.cfg"'
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_scale_landscape' '"1.380000"'
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_aspect_adjust_landscape' '"-0.170000"'
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'aspect_ratio_index' '"15"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/snes87.cfg"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_scale_landscape' '"1.380000"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_aspect_adjust_landscape' '"-0.170000"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'aspect_ratio_index' '"15"'
}

Android_RetroArch_snes_ar32(){
	Android_RetroArch_setOverride 'snes.cfg' 'Snes9x'  'aspect_ratio_index' '"7"'
	Android_RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'aspect_ratio_index' '"7"'
	Android_RetroArch_snes_bezelOff
}


# Android_RetroArch_bsnes_hd_beta_bezelOn(){
# 	Android_RetroArch_setOverride 'sneshd.cfg' 'bsnes-hd beta'  'video_scale_integer' '"false"'
# }

Android_RetroArch_melonDS_setUpCoreOpt(){
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_audio_bitrate' '"Automatic"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_audio_interpolation' '"None"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_boot_directly' '"enabled"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_console_mode' '"DS"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_dsi_sdcard' '"disabled"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_hybrid_ratio' '"2"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_hybrid_small_screen' '"Duplicate"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_jit_block_size' '"32"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_jit_branch_optimisations' '"enabled"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_jit_enable' '"enabled"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_jit_fast_memory' '"enabled"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_jit_literal_optimisations' '"enabled"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_opengl_better_polygons' '"enabled"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_opengl_filtering' '"nearest"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_opengl_renderer' '"enabled"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_opengl_resolution' '"5x native (1280x960)"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_randomize_mac_address' '"disabled"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_screen_gap' '"0"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_screen_layout' '"Hybrid Bottom"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_swapscreen_mode' '"Toggle"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_threaded_renderer' '"disabled"'
	Android_RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_touch_mode' '"Touch"'
}

Android_RetroArch_melonDS_setConfig(){
	Android_RetroArch_setOverride 'nds.cfg' 'melonDS'  'rewind_enable' '"false"'
}

Android_RetroArch_melonDSDS_setUpCoreOpt(){
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_audio_bitdepth' '"auto"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_audio_interpolation' '"disabled"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_boot_mode' '"disabled"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS' 'melonds_console_mode' '"ds"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_dsi_sdcard' '"enabled"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_hybrid_ratio' '"2"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_hybrid_small_screen' '"both"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_jit_block_size' '"32"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_jit_branch_optimisations' '"enabled"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_jit_enable' '"enabled"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_jit_fast_memory' '"enabled"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_jit_literal_optimisations' '"enabled"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_opengl_better_polygons' '"enabled"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_opengl_filtering' '"nearest"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_render_mode' '"software"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_opengl_resolution' '"5"'
#	Unsupported in melonDSDS at this time.
#	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_randomize_mac_address' '"disabled"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_screen_gap' '"0"'
#	No equivalent in melonDSDS at this time.
#	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_screen_layout' '"Hybrid Bottom"'
#	No equivalent in melonDSDS at this time.
#	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_swapscreen_mode' '"Toggle"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_threaded_renderer' '"enabled"'
	Android_RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_touch_mode' '"auto"'
}

Android_RetroArch_melonDSDS_setConfig(){
	Android_RetroArch_setOverride 'melonDS DS.cfg' 'melonDS DS'  'rewind_enable' '"true"'
	Android_RetroArch_setOverride 'melonDS DS.cfg' 'melonDS DS'  'rewind_granularity' '"6"'
}

Android_RetroArch_Mupen64Plus_Next_setUpCoreOpt(){
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-169screensize' '"1920x1080"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-43screensize' '"1280x960"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-alt-map' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-angrylion-multithread' '"all threads"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-angrylion-overscan' '"disabled"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-angrylion-sync' '"Low"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-angrylion-vioverlay' '"Filtered"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-aspect' '"4:3"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-astick-deadzone' '"15"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-astick-sensitivity' '"100"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-BackgroundMode' '"OnePiece"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-BilinearMode' '"standard"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-CorrectTexrectCoords' '"Auto"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-CountPerOp' '"0"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-CountPerOpDenomPot' '"0"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-cpucore' '"dynamic_recompiler"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-d-cbutton' '"C3"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-DitheringPattern' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-DitheringQuantization' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableCopyAuxToRDRAM' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableCopyColorToRDRAM' '"Async"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableCopyDepthToRDRAM' '"Software"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableEnhancedHighResStorage' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableEnhancedTextureStorage' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableFBEmulation' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableFragmentDepthWrite' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableHiResAltCRC' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableHWLighting' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableInaccurateTextureCoordinates' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableLegacyBlending' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableLODEmulation' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableN64DepthCompare' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableNativeResFactor' '"4"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableNativeResTexrects' '"Optimized"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableOverscan' '"Enabled"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableShadersStorage' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableTexCoordBounds' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableTextureCache' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-ForceDisableExtraMem' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-FrameDuping' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-Framerate' '"Fullspeed"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-FXAA' '"0"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-GLideN64IniBehaviour' '"late"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-HybridFilter' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-IgnoreTLBExceptions' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-l-cbutton' '"C2"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-MaxHiResTxVramLimit' '"0"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-MaxTxCacheSize' '"8000"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-MultiSampling' '"0"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-OverscanBottom' '"0"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-OverscanLeft' '"0"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-OverscanRight' '"0"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-OverscanTop' '"0"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-pak1' '"memory"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-pak2' '"none"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-pak3' '"none"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-pak4' '"none"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-deinterlace-method' '"Bob"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-dither-filter' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-divot-filter' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-downscaling' '"disable"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-gamma-dither' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-native-tex-rect' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-native-texture-lod' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-overscan' '"0"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-super-sampled-read-back' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-super-sampled-read-back-dither' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-synchronous' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-upscaling' '"1x"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-vi-aa' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-vi-bilinear' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-r-cbutton' '"C1"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-rdp-plugin' '"gliden64"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-RDRAMImageDitheringMode' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-rsp-plugin' '"hle"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-ThreadedRenderer' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txEnhancementMode' '"As Is"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txFilterIgnoreBG' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txFilterMode' '"None"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txHiresEnable' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txHiresFullAlphaChannel' '"False"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-u-cbutton' '"C4"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-virefresh' '"Auto"'

	# hd pack settings
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txHiresEnable' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txHiresFullAlphaChannel' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txCacheCompression' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableEnhancedHighResStorage' '"True"'
	Android_RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableEnhancedTextureStorage' '"False"' # lazy loading
}

#  setupHdPacks()
Android_RetroArch_Mupen64Plus_Next_setUpHdPacks(){
  local texturePackPath="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/system/Mupen64plus/hires_texture"
	local textureCachePath="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/system/Mupen64plus/cache"

	mkdir -p "$texturePackPath"
	mkdir -p "$textureCachePath"
	mkdir -p "$emulationPath/hdpacks/retroarch/Mupen64plus"

	ln -s "$emulationPath/hdpacks/retroarch/Mupen64plus/hires_texture" "$texturePackPath"
	ln -s "$emulationPath/hdpacks/retroarch/Mupen64plus/cache" "$textureCachePath"
}

Android_RetroArch_Beetle_PSX_HW_setUpCoreOpt(){
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_adaptive_smoothing' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_analog_calibration' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_analog_toggle' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_aspect_ratio' '"corrected"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_cd_access_method' '"sync"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_cd_fastload' '"2x(native)"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_core_timing_fps' '"force_progressive"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_cpu_dynarec' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_cpu_freq_scale' '"100%(native)"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_crop_overscan' '"smart"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_crosshair_color_p1' '"red"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_crosshair_color_p2' '"blue"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_depth' '"16bpp(native)"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_display_internal_fps' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_display_vram' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_dither_mode' '"1x(native)"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_dump_textures' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_dynarec_eventcycles' '"128"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_dynarec_invalidate' '"full"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_enable_memcard1' '"enabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_enable_multitap_port1' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_enable_multitap_port2' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_filter' '"nearest"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_filter_exclude_2d_polygon' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_filter_exclude_sprite' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_frame_duping' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_gpu_overclock' '"1x(native)"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_gte_overclock' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_gun_cursor' '"cross"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_gun_input_mode' '"lightgun"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_image_crop' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_image_offset' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_image_offset_cycles' '"0"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_initial_scanline' '"0"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_initial_scanline_pal' '"0"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_internal_resolution' '"2x"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_last_scanline' '"239"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_last_scanline_pal' '"287"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_line_render' '"default"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_mdec_yuv' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_memcard_left_index' '"0"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_memcard_right_index' '"1"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_mouse_sensitivity' '"100%"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_msaa' '"1x"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_negcon_deadzone' '"0%"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_negcon_response' '"linear"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_override_bios' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_pal_video_timing_override' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_pgxp_2d_tol' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_pgxp_mode' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_pgxp_nclip' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_pgxp_texture' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_pgxp_vertex' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_renderer' '"hardware"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_renderer_software_fb' '"enabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_replace_textures' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_scaled_uv_offset' '"enabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_shared_memory_cards' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_skip_bios' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_super_sampling' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_track_textures' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_use_mednafen_memcard0_method' '"libretro"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_widescreen_hack' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_widescreen_hack_aspect_ratio' '"16:9"'
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_wireframe' '"disabled"'
}

Android_RetroArch_Flycast_setUpCoreOpt(){
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_allow_service_buttons' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_alpha_sorting' '"per-triangle (normal)"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_analog_stick_deadzone' '"15%"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_anisotropic_filtering' '"4"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_auto_skip_frame' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_boot_to_bios' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_broadcast' '"NTSC"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_cable_type' '"TV'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_custom_textures' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_delay_frame_swapping' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_digital_triggers' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_dump_textures' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_enable_dsp' '"enabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_enable_purupuru' '"enabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_enable_rttb' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_fog' '"enabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_force_wince' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_frame_skipping' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_gdrom_fast_loading' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_hle_bios' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_internal_resolution' '"960x720"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_language' '"English"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_lightgun1_crosshair' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_lightgun2_crosshair' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_lightgun3_crosshair' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_lightgun4_crosshair' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_mipmapping' '"enabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_oit_abuffer_size' '"512MB"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_per_content_vmus' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_pvr2_filtering' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_region' '"USA"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_screen_rotation' '"horizontal"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_show_lightgun_settings' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_show_vmu_screen_settings' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_texupscale' '"1"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_texupscale_max_filtered_texture_size' '"256"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_threaded_rendering' '"enabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_trigger_deadzone' '"0%"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu1_pixel_off_color' '"DEFAULT_OFF 01"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu1_pixel_on_color' '"DEFAULT_ON 00"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu1_screen_display' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu1_screen_opacity' '"100%"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu1_screen_position' '"Upper Left"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu1_screen_size_mult' '"1x"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu2_pixel_off_color' '"DEFAULT_OFF 01"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu2_pixel_on_color' '"DEFAULT_ON 00"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu2_screen_display' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu2_screen_opacity' '"100%"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu2_screen_position' '"Upper Left"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu2_screen_size_mult' '"1x"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu3_pixel_off_color' '"DEFAULT_OFF 01"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu3_pixel_on_color' '"DEFAULT_ON 00"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu3_screen_display' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu3_screen_opacity' '"100%"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu3_screen_position' '"Upper Left"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu3_screen_size_mult' '"1x"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu4_pixel_off_color' '"DEFAULT_OFF 01"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu4_pixel_on_color' '"DEFAULT_ON 00"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu4_screen_display' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu4_screen_opacity' '"100%"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu4_screen_position' '"Upper Left"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu4_screen_size_mult' '"1x"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_volume_modifier_enable' '"enabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_widescreen_cheats' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_widescreen_hack' '"disabled"'
}

Android_RetroArch_Gambatte_setUpCoreOpt(){
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_audio_resampler' '"sinc"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_dark_filter_level' '"0"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_bootloader' '"enabled"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_colorization' '"auto"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_hwmode' '"Auto"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_internal_palette' '"GB - DMG"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_mode' '"Not Connected"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_port' '"56400"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_1' '"0"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_10' '"0"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_11' '"0"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_12' '"0"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_2' '"0"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_3' '"0"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_4' '"0"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_5' '"0"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_6' '"0"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_7' '"0"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_8' '"0"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_9' '"0"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_palette_pixelshift_1' '"PixelShift 01 - Arctic Green"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_palette_twb64_1' '"WB64 001 - Aqours Blue"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_palette_twb64_2' '"TWB64 101 - 765PRO Pink"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gbc_color_correction' '"GBC only"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gbc_color_correction_mode' '"accurate"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gbc_frontlight_position' '"central"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_mix_frames' '"disabled"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_rumble_level' '"10"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_show_gb_link_settings' '"disabled"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_turbo_period' '"4"'
	Android_RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_up_down_allowed' '"disabled"'
}

Android_RetroArch_Nestopia_setUpCoreOpt(){
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_arkanoid_device' '"mouse"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_aspect' '"auto"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_dpcm' '"100"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_fds' '"100"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_mmc5' '"100"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_n163' '"100"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_noise' '"100"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_s5b' '"100"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_sq1' '"100"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_sq2' '"100"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_tri' '"100"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_vrc6' '"100"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_vrc7' '"100"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_blargg_ntsc_filter' '"disabled"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_button_shift' '"disabled"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_favored_system' '"auto"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_fds_auto_insert' '"enabled"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_genie_distortion' '"disabled"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_nospritelimit' '"disabled"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_overclock' '"1x"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_overscan_h' '"disabled"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_overscan_v' '"enabled"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_palette' '"cxa2025as"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_ram_power_state' '"0x00"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_select_adapter' '"auto"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_show_advanced_av_settings' '"disabled"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_show_crosshair' '"enabled"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_turbo_pulse' '"2"'
	Android_RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_zapper_device' '"lightgun"'
}
Android_RetroArch_bsnes_hd_beta_setUpCoreOpt(){
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_blur_emulation' '"OFF"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_coprocessor_delayed_sync' '"ON"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_coprocessor_prefer_hle' '"ON"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_cpu_fastmath' '"OFF"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_cpu_overclock' '"100"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_cpu_sa1_overclock' '"100"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_cpu_sfx_overclock' '"100"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_dsp_cubic' '"OFF"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_dsp_echo_shadow' '"OFF"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_dsp_fast' '"ON"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_entropy' '"Low"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_hotfixes' '"OFF"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_ips_headered' '"OFF"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_bgGrad' '"4"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_igwin' '"outside"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_igwinx' '"128"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_mosaic' '"1x scale"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_perspective' '"on'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_scale' '"1x"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_strWin' '"OFF"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_supersample' '"none"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_widescreen' '"16:10"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_windRad' '"0"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsbg1' '"auto horz and vert"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsbg2' '"auto horz and vert"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsbg3' '"auto horz and vert"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsbg4' '"auto horz and vert"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsBgCol' '"auto"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsMarker' '"none"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsMarkerAlpha' '"1/1"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsMode' '"all"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsobj' '"safe"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_ppu_deinterlace' '"ON"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_ppu_fast' '"ON"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_ppu_no_sprite_limit' '"ON"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_ppu_no_vram_blocking' '"OFF"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_ppu_show_overscan' '"OFF"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_run_ahead_frames' '"OFF"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_sgb_bios' '"SGB1.sfc"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_video_aspectcorrection' '"OFF"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_video_gamma' '"100"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_video_luminance' '"100"'
	Android_RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_video_saturation' '"100"'
}

Android_RetroArch_dos_box_setUpCoreOpt(){
	Android_RetroArch_setOverride 'DOSBox-pure.opt' 'DOSBox-pure'  'dosbox_pure_conf' '"inside"'
}

Android_RetroArch_setUpCoreOptAll(){

	for func in $(compgen -A 'function' | grep '\_setUpCoreOpt$')
		do echo  "$func" && "$func"
	done
}

Android_RetroArch_setConfigAll(){

	for func in $(compgen -A 'function' | grep '\_setConfig$' | grep '^Android_RetroArch_' )
		do echo  "$func" && "$func"
	done
}

Android_RetroArch_Flycast_wideScreenOn(){
	Android_RetroArch_setOverride 'Flycast.opt' 	'Flycast'  	'reicast_widescreen_cheats' 	'"enabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 	'Flycast'  	'reicast_widescreen_hack' 	'"enabled"'
	Android_RetroArch_setOverride 'dreamcast.cfg' 	'Flycast'  	'aspect_ratio_index' 		'"1"'
	Android_RetroArch_dreamcast_bezelOff
	Android_RetroArch_dreamcast_3DCRTshaderOff
}

Android_RetroArch_Flycast_wideScreenOff(){
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_widescreen_cheats' '"disabled"'
	Android_RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_widescreen_hack' '"disabled"'
	Android_RetroArch_setOverride 'dreamcast.cfg' 'Flycast'  'aspect_ratio_index' '"0"'
}

Android_RetroArch_Beetle_PSX_HW_wideScreenOn(){
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_widescreen_hack' '"enabled"'
	Android_RetroArch_setOverride 'Beetle PSX.opt' 'Beetle PSX'  'beetle_psx_hw_widescreen_hack' '"enabled"'
	Android_RetroArch_psx_bezelOff
}

Android_RetroArch_Beetle_PSX_HW_wideScreenOff(){
	Android_RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_widescreen_hack' '"disabled"'
	Android_RetroArch_setOverride 'Beetle PSX.opt' 'Beetle PSX'  'beetle_psx_hw_widescreen_hack' '"disabled"'
}


Android_RetroArch_SwanStation_setConfig(){
	Android_RetroArch_setOverride 'SwanStation.opt' 'SwanStation'  'duckstation_GPU.ResolutionScale' '"3"'
}

Android_RetroArch_SwanStation_wideScreenOn(){
	Android_RetroArch_setOverride 'SwanStation.opt' 'SwanStation'  'duckstation_GPU.WidescreenHack' '"true"'
	Android_RetroArch_setOverride 'SwanStation.opt' 'SwanStation'  'duckstation_Display.AspectRatio' '"16:9"'
	Android_RetroArch_setOverride 'psx.cfg' 'SwanStation'  'aspect_ratio_index' '"1"'
	Android_RetroArch_psx_bezelOff
}

Android_RetroArch_SwanStation_wideScreenOff(){
	Android_RetroArch_setOverride 'SwanStation.opt' 'SwanStation'  'duckstation_GPU.WidescreenHack' '"false"'
	Android_RetroArch_setOverride 'SwanStation.opt' 'SwanStation'  'duckstation_Display.AspectRatio' '"auto"'
	Android_RetroArch_setOverride 'psx.cfg' 'SwanStation'  'aspect_ratio_index' '"0"'
}

Android_RetroArch_psx_bezelOn(){
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW' 'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW' 'aspect_ratio_index' '"0"'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW' 'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/psx.cfg"'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW' 'input_overlay_aspect_adjust_landscape' '"0.100000"'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW' 'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW' 'input_overlay_scale_landscape' '"1.060000"'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX' 'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX' 'aspect_ratio_index' '"0"'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX' 'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/psx.cfg"'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX' 'input_overlay_aspect_adjust_landscape' '"0.100000"'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX' 'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX' 'input_overlay_scale_landscape' '"1.060000"'
	Android_RetroArch_setOverride 'psx.cfg' 'SwanStation' 'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'psx.cfg' 'SwanStation' 'aspect_ratio_index' '"0"'
	Android_RetroArch_setOverride 'psx.cfg' 'SwanStation' 'input_overlay' '"/storage/emulated/0/RetroArch/overlays/pegasus/psx.cfg"'
	Android_RetroArch_setOverride 'psx.cfg' 'SwanStation' 'input_overlay_aspect_adjust_landscape' '"0.100000"'
	Android_RetroArch_setOverride 'psx.cfg' 'SwanStation' 'input_overlay_enable' '"true"'
	Android_RetroArch_setOverride 'psx.cfg' 'SwanStation' 'input_overlay_scale_landscape' '"1.060000"'
}


Android_RetroArch_psx_bezelOff(){
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX'  'input_overlay_enable' '"false"'
	Android_RetroArch_setOverride 'psx.cfg' 'SwanStation'  'input_overlay_enable' '"false"'
}

 Android_RetroArch_psx_3DCRTshaderOn(){
	 Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW'  'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW'	'video_smooth' 'ED_RM_LINE'

	 Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX'  'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX'	'video_smooth' 'ED_RM_LINE'

	 Android_RetroArch_setOverride 'psx.cfg' 'SwanStation'  'video_shader_enable' 'true'
	Android_RetroArch_setOverride 'psx.cfg' 'SwanStation'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'psx.cfg' 'SwanStation'	'video_smooth' 'ED_RM_LINE'
 }

Android_RetroArch_psx_3DCRTshaderOff(){
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW'	'video_smooth' 'ED_RM_LINE'

	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'psx.cfg' 'Beetle PSX'	'video_smooth' 'ED_RM_LINE'

	Android_RetroArch_setOverride 'psx.cfg' 'SwanStation'  'video_shader_enable' '"false"'
	Android_RetroArch_setOverride 'psx.cfg' 'SwanStation'	'video_filter' 'ED_RM_LINE'
	Android_RetroArch_setOverride 'psx.cfg' 'SwanStation'	'video_smooth' 'ED_RM_LINE'
}

Android_RetroArch_psx_setConfig(){
	Android_RetroArch_psx_3DCRTshaderOff
}

Android_RetroArch_cdi_setConfig(){
	mkdir -p "${biosPath}/same_cdi/bios"
}

#BezelOn
Android_RetroArch_bezelOnAll(){
	for func in $(compgen -A 'function' | grep '\_bezelOn$' | grep '^Android_RetroArch_' | grep -v "Android_RetroArch_bezelOn")
		do echo  "$func" && "$func"
	done
}

#BezelOff
Android_RetroArch_bezelOffAll(){
	for func in $(compgen -A 'function' | grep '\_bezelOff$' | grep '^Android_RetroArch_')
		do echo  "$func" && "$func"
	done
}

#shadersCRTOn
Android_RetroArch_CRTshaderOnAll(){
	for func in $(compgen -A 'function' | grep '\_CRTshaderOn$' | grep '^Android_RetroArch_' | grep -v "Android_RetroArch_bezelOn")
		do echo  "$func" && "$func"
	done
}

#shadersCRTOff
Android_RetroArch_CRTshaderOffAll(){
	for func in $(compgen -A 'function' | grep '\_CRTshaderOff$' | grep '^Android_RetroArch_')
		do echo  "$func" && "$func"
	done
}

#shaders3DCRTOn
Android_RetroArch_3DCRTshaderOnAll(){
	for func in $(compgen -A 'function' | grep '\_3DCRTshaderOn$' | grep '^Android_RetroArch_' | grep -v "Android_RetroArch_bezelOn")
		do echo  "$func" && "$func"
	done
}

#shaders3DCRTOff
Android_RetroArch_3DCRTshaderOffAll(){
	for func in $(compgen -A 'function' | grep '\_3DCRTshaderOff$' | grep '^Android_RetroArch_')
		do echo  "$func" && "$func"
	done
}
#shadersMATOn
Android_RetroArch_MATshadersOnAll(){
	for func in $(compgen -A 'function' | grep '\_MATshaderOn$' | grep '^Android_RetroArch_' | grep -v "Android_RetroArch_bezelOn")
		do echo  "$func" && "$func"
	done
}

#shadersMATOff
Android_RetroArch_MATshadersOffAll(){
	for func in $(compgen -A 'function' | grep '\_MATshaderOff$' | grep '^Android_RetroArch_')
		do echo  "$func" && "$func"
	done
}


#finalExec - Extra stuff
Android_RetroArch_finalize(){
	echo "NYI"
}

Android_RetroArch_installCores(){
	echo "NYI"
}

#Android_RetroArch_dlAdditionalFiles

function Android_RetroArch_dlAdditionalFiles(){
	#EasyRPG
	mkdir -p "$biosPath/rtp/2000"
	mkdir -p "$biosPath/rtp/2003"

	curl -L https://dl.degica.com/rpgmakerweb/run-time-packages/rpg2003_rtp_installer.zip --output "$biosPath/rtp/2003/rpg2003.zip.tmp" && mv "$biosPath/rtp/2003/rpg2003.zip.tmp" "$biosPath/rtp/2003/rpg2003.zip"
	curl -L https://dl.degica.com/rpgmakerweb/run-time-packages/rpg2000_rtp_installer.exe --output "$biosPath/rtp/2000/rpg2000.zip.tmp" && mv "$biosPath/rtp/2000/rpg2000.zip.tmp" "$biosPath/rtp/2000/rpg2000.zip"

	7z x "$biosPath/rtp/2003/rpg2003.zip" -o"$biosPath/rtp/2003" && rm "$biosPath/rtp/2003/rpg2003.zip"
	7z x "$biosPath/rtp/2003/rpg2003_rtp_installer.exe" -o"$biosPath/rtp/2003" && rm "$biosPath/rtp/2003/rpg2003_rtp_installer.exe"
	7z x "$biosPath/rtp/2000/rpg2000.zip" -o"$biosPath/rtp/2000" && rm "$biosPath/rtp/2000/rpg2000.zip"
}


function Android_RetroArch_resetCoreConfigs(){

	find "$Android_RetroArch_coreConfigFolders" -type f -iname "*.cfg" -o -type f -iname "*.opt"| while read -r file
		do
			mv "$file"  "$file".bak
		done
	Android_RetroArch_init
	echo "true"
}

Android_RetroArch_autoSaveOn(){
	Android_RetroArch_setConfigOverride 'savestate_auto_load' '"true"' "$Android_RetroArch_configFile"
	Android_RetroArch_setConfigOverride 'savestate_auto_save' '"true"' "$Android_RetroArch_configFile"
}
Android_RetroArch_autoSaveOff(){
	Android_RetroArch_setConfigOverride 'savestate_auto_load' '"false"' "$Android_RetroArch_configFile"
	Android_RetroArch_setConfigOverride 'savestate_auto_save' '"false"' "$Android_RetroArch_configFile"
}
Android_RetroArch_retroAchievementsOn(){
	iniFieldUpdate "$Android_RetroArch_configFile" "" "cheevos_enable" "true"
	#Mame fix
	#Android_RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'cheevos_enable' '"false"'
	#Android_RetroArch_setOverride 'mame.cfg' 'MAME'  'cheevos_enable' '"false"'
}
Android_RetroArch_retroAchievementsOff(){
	iniFieldUpdate "$Android_RetroArch_configFile" "" "cheevos_enable" "false"
	#Mame fix
	#Android_RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'cheevos_enable' '"false"'
	#Android_RetroArch_setOverride 'mame.cfg' 'MAME'  'cheevos_enable' '"false"'
}

Android_RetroArch_retroAchievementsHardCoreOn(){
	Android_RetroArch_setConfigOverride 'cheevos_hardcore_mode_enable' '"true"' "$Android_RetroArch_configFile"
}
Android_RetroArch_retroAchievementsHardCoreOff(){
	Android_RetroArch_setConfigOverride 'cheevos_hardcore_mode_enable' '"false"' "$Android_RetroArch_configFile"
}

Android_RetroArch_retroAchievementsPromptLogin(){
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
		echo "$RAInput" | awk -F "," '{print $1}' > "$HOME/.config/EmuDeck/.rau"
		echo "$RAInput" | awk -F "," '{print $2}' > "$HOME/.config/EmuDeck/.rap"
	else
		echo "Cancel RetroAchievment Login"
	fi
}
Android_RetroArch_retroAchievementsSetLogin(){
	rm -rf "$HOME/.config/EmuDeck/.rap"
	rau=$(cat "$HOME/.config/EmuDeck/.rau")
	rat=$(cat "$HOME/.config/EmuDeck/.rat")
	echo "Evaluate RetroAchievements Login."
	if [ ${#rat} -lt 1 ]; then
		echo "--No token."
	elif [ ${#rau} -lt 1 ]; then
		echo "--No username."
	else
		echo "Valid Retroachievements Username and Password length"
		Android_RetroArch_setConfigOverride 'cheevos_username' '"'"${rau}"'"' "$Android_RetroArch_configFile" &>/dev/null && echo 'RetroAchievements Username set.' || echo 'RetroAchievements Username not set.'
		Android_RetroArch_setConfigOverride 'cheevos_token' '"'"${rat}"'"' "$Android_RetroArch_configFile" &>/dev/null && echo 'RetroAchievements Token set.' || echo 'RetroAchievements Token not set.'

		Android_RetroArch_retroAchievementsOn

		iniFieldUpdate "$Android_RetroArch_configFile" "" "cheevos_username" "$rau"
		iniFieldUpdate "$Android_RetroArch_configFile" "" "cheevos_token" "$rat"

	fi
}
Android_RetroArch_setBezels(){
	if [ "$RABezels" == true ]; then
		Android_RetroArch_bezelOnAll
	else
		Android_RetroArch_bezelOffAll
	fi
}
Android_RetroArch_setShadersCRT(){
	if [ "$RAHandClassic2D" == true ]; then
		Android_RetroArch_CRTshaderOnAll
	else
		Android_RetroArch_CRTshaderOffAll
	fi
}
Android_RetroArch_setShaders3DCRT(){
	if [ "$RAHandClassic3D" == true ]; then
		Android_RetroArch_3DCRTshaderOnAll
	else
		Android_RetroArch_3DCRTshaderOffAll
	fi
}
Android_RetroArch_setShadersMAT(){
	if [ "$RAHandHeldShader" == true ]; then
		Android_RetroArch_MATshadersOnAll
	else
		Android_RetroArch_MATshadersOffAll
	fi
}

Android_RetroArch_autoSave(){
	if [ "$RAautoSave" == true ]; then
		Android_RetroArch_autoSaveOn
	else
		Android_RetroArch_autoSaveOff
	fi
}

Android_RetroArch_melonDSDSMigration(){

local Android_RetroArch_saves="$Android_RetroArch_path/saves"
local melonDS_remaps="$Android_RetroArch_path/config/remaps/melonDS"
local melonDSDS_remaps="$Android_RetroArch_path/config/remaps/melonDS DS"

# Copying melonDS saves to melonDSDS
for file in $Android_RetroArch_saves/*.sav; do

	cp -- "${file}" "${file/%sav/srm}";
	echo "melonDS saves copied to melonDSDS"
done

# Copying melonDS remaps to melonDSDS
if [ ! -d "$melonDSDS_remaps" ]; then
	mkdir -p "$melonDSDS_remaps"
fi

if [ -d "$melonDS_remaps" ]; then
	cp -r "$melonDS_remaps/." "$melonDSDS_remaps"
	echo "melonDS remaps copied to melonDSDS"
fi

}

Android_RetroArch_IsInstalled(){
	package="org.retroarch.com"
	Android_ADB_appInstalled $package
}

Android_RetroArch_resetConfig(){
	Android_RetroArch_resetCoreConfigs &>/dev/null && Android_RetroArch_init &>/dev/null && echo "true" || echo "false"
}
