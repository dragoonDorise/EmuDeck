#!/bin/bash
#variables
emuName="RetroArch"
emuType="FlatPak"
emuPath="org.libretro.RetroArch"
releaseURL=""

#cleanupOlderThings
RetroArch.cleanup() {
	#na
}

#Install
RetroArch.install() {
	installEmuFP "${emuName}" "${emuPath}"
	flatpak override "${emuPath}" --filesystem=host --user
}

#ApplyInitialSettings
RetroArch.init() {
	configEmuFP "${emuName}" "${emuPath}" "true"
	RetroArch.setEmulationFolder
	RetroArch.setupSaves
	RetroArch.installCores
}

#update
RetroArch.update() {
	configEmuFP "${emuName}" "${emuPath}"
	RetroArch.setEmulationFolder
	RetroArch.setupSaves
	RetroArch.installCores
}

#ConfigurePaths
RetroArch.setEmulationFolder() {
	configFile = "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg"
	system_directory='system_directory = '
	system_directorySetting="${system_directory}""\"${biosPath}\""
	sed -i "/${system_directory}/c\\${system_directorySetting}" $configFile
}

#SetupSaves
RetroArch.setupSaves() {
	linkToSaveFolder retroarch states "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/states"
	linkToSaveFolder retroarch saves "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/saves"
}

#SetupStorage
RetroArch.setupStorage() {
	#na
}

#WipeSettings
RetroArch.wipe() {
	rm -rf "$HOME/.var/app/$emuPath"
	# prob not cause roms are here
}

#Uninstall
RetroArch.uninstall() {
	flatpack uninstall $emuPath -y
}

#setABXYstyle
RetroArch.setABXYstyle() {

}

#Migrate
RetroArch.migrate() {

}

#WideScreenOn
RetroArch.wideScreenOn() {
	#na
}

#WideScreenOff
RetroArch.wideScreenOff() {
	#na
}

#BezelOn
RetroArch.bezelOn() {
	#na
}

#BezelOff
RetroArch.bezelOff() {
	#na
}

#finalExec - Extra stuff
RetroArch.finalize() {
	#na
}

RetroArch.installCores() {
	mkdir -p "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores"
	raUrl="https://buildbot.libretro.com/nightly/linux/x86_64/latest/"
	RAcores=(bsnes_hd_beta_libretro.so flycast_libretro.so gambatte_libretro.so genesis_plus_gx_libretro.so genesis_plus_gx_wide_libretro.so mednafen_lynx_libretro.so mednafen_ngp_libretro.so mednafen_wswan_libretro.so melonds_libretro.so mesen_libretro.so mgba_libretro.so mupen64plus_next_libretro.so nestopia_libretro.so picodrive_libretro.so ppsspp_libretro.so snes9x_libretro.so stella_libretro.so yabasanshiro_libretro.so yabause_libretro.so yabause_libretro.so mame2003_plus_libretro.so mame2010_libretro.so mame_libretro.so melonds_libretro.so fbneo_libretro.so bluemsx_libretro.so desmume_libretro.so sameboy_libretro.so gearsystem_libretro.so mednafen_saturn_libretro.so opera_libretro.so dosbox_core_libretro.so dosbox_pure_libretro.so dosbox_svn_libretro.so puae_libretro.so)
	setMSG "Downloading RetroArch Cores for EmuDeck"
	for i in "${RAcores[@]}"; do
		FILE="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}"
		if [ -f "$FILE" ]; then
			echo "${i}...Already Downloaded"
		else
			curl $raUrl$i.zip --output "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip"
			#rm "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip"
			echo "${i}...Downloaded!"
		fi
	done

	RAcores=(a5200_libretro.so 81_libretro.so atari800_libretro.so bluemsx_libretro.so chailove_libretro.so fbneo_libretro.so freechaf_libretro.so freeintv_libretro.so fuse_libretro.so gearsystem_libretro.so gw_libretro.so hatari_libretro.so lutro_libretro.so mednafen_pcfx_libretro.so mednafen_vb_libretro.so mednafen_wswan_libretro.so mu_libretro.so neocd_libretro.so nestopia_libretro.so nxengine_libretro.so o2em_libretro.so picodrive_libretro.so pokemini_libretro.so prboom_libretro.so prosystem_libretro.so px68k_libretro.so quasi88_libretro.so scummvm_libretro.so squirreljme_libretro.so theodore_libretro.so uzem_libretro.so vecx_libretro.so vice_xvic_libretro.so virtualjaguar_libretro.so x1_libretro.so mednafen_lynx_libretro.so mednafen_ngp_libretro.so mednafen_pce_libretro.so mednafen_pce_fast_libretro.so mednafen_psx_libretro.so mednafen_psx_hw_libretro.so mednafen_saturn_libretro.so mednafen_supafaust_libretro.so mednafen_supergrafx_libretro.so blastem_libretro.so bluemsx_libretro.so bsnes_libretro.so bsnes_mercury_accuracy_libretro.so cap32_libretro.so citra2018_libretro.so citra_libretro.so crocods_libretro.so desmume2015_libretro.so desmume_libretro.so dolphin_libretro.so dosbox_core_libretro.so dosbox_pure_libretro.so dosbox_svn_libretro.so fbalpha2012_cps1_libretro.so fbalpha2012_cps2_libretro.so fbalpha2012_cps3_libretro.so fbalpha2012_libretro.so fbalpha2012_neogeo_libretro.so fceumm_libretro.so fbneo_libretro.so flycast_libretro.so fmsx_libretro.so frodo_libretro.so gambatte_libretro.so gearboy_libretro.so gearsystem_libretro.so genesis_plus_gx_libretro.so genesis_plus_gx_wide_libretro.so gpsp_libretro.so handy_libretro.so kronos_libretro.so mame2000_libretro.so mame2003_plus_libretro.so mame2010_libretro.so mame_libretro.so melonds_libretro.so mesen_libretro.so mesen-s_libretro.so mgba_libretro.so mupen64plus_next_libretro.so nekop2_libretro.so np2kai_libretro.so nestopia_libretro.so parallel_n64_libretro.so pcsx2_libretro.so pcsx_rearmed_libretro.so picodrive_libretro.so ppsspp_libretro.so puae_libretro.so quicknes_libretro.so race_libretro.so sameboy_libretro.so smsplus_libretro.so snes9x2010_libretro.so snes9x_libretro.so stella2014_libretro.so stella_libretro.so tgbdual_libretro.so vbam_libretro.so vba_next_libretro.so vice_x128_libretro.so vice_x64_libretro.so vice_x64sc_libretro.so vice_xscpu64_libretro.so yabasanshiro_libretro.so yabause_libretro.so bsnes_hd_beta_libretro.so swanstation_libretro.so)
	setMSG "Downloading RetroArch Cores for EmulationStation DE"
	for i in "${RAcores[@]}"; do
		FILE="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}"
		if [ -f "$FILE" ]; then
			echo "${i}...Already Downloaded"
		else
			curl $raUrl$i.zip --output "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip"
			#rm "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip"
			echo "${i}...Downloaded!"
		fi
	done

	for entry in "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/*.zip"; do
		unzip -o "$entry" -d "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/"
	done

	for entry in "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/*.zip"; do
		rm -f "$entry"
	done
}
