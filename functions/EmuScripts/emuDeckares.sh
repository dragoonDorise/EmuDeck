#!/bin/bash
#variables
ares_emuName="ares"
ares_emuType="FlatPak"
ares_emuPath="dev.ares.ares"
ares_configFile="$HOME/.var/app/dev.ares.ares/data/ares/settings.bml"

#cleanupOlderThings
ares_cleanup(){
 echo "NYI"
}

#Install
ares_install() {
	setMSG "Installing $ares_emuName"	

	installEmuFP "${ares_emuName}" "${ares_emuPath}"
	flatpak override "${ares_emuPath}" --filesystem=host --user
}

#ApplyInitialSettings

ares_init() {

    setMSG "Initializing $ares_emuName settings."

	configEmuFP "${ares_emuName}" "${ares_emuPath}" "true"
	ares_setupStorage
	ares_setEmulationFolder
	ares_setupSaves
	ares_addSteamInputProfile

}

#update
ares_update() {
	setMSG "Installing $ares_emuName"		

	configEmuFP "${ares_emuName}" "${ares_emuPath}"
	ares_setupStorage
	ares_setEmulationFolder
	ares_setupSaves
	ares_addSteamInputProfile

}

#ConfigurePaths
ares_setEmulationFolder(){
	setMSG "Setting $ares_emuName Emulation Folder"

    # ROM Paths
	iniFieldUpdate "$ares_configFile" "Atari2600" "Path" "${romsPath}/atari2600"
	iniFieldUpdate "$ares_configFile" "WonderSwan" "Path" "${romsPath}/wonderswan"
	iniFieldUpdate "$ares_configFile" "WonderSwanColor" "Path" "${romsPath}/wonderswancolor"
	iniFieldUpdate "$ares_configFile" "PocketChallengeV2" "Path" "${romsPath}/pocketchallengev2"
	iniFieldUpdate "$ares_configFile" "MSX" "Path" "${romsPath}/msx"
	iniFieldUpdate "$ares_configFile" "MSX2" "Path" "${romsPath}/msx2"
	iniFieldUpdate "$ares_configFile" "PCEngine" "Path" "${romsPath}/pcengine"
	iniFieldUpdate "$ares_configFile" "PCEngineCD" "Path" "${romsPath}/pcenginecd"
	iniFieldUpdate "$ares_configFile" "SuperGrafx" "Path" "${romsPath}/pcengine"
	iniFieldUpdate "$ares_configFile" "Famicom" "Path" "${romsPath}/nes"
	iniFieldUpdate "$ares_configFile" "FamicomDiskSystem" "Path" "${romsPath}/fdc"
	iniFieldUpdate "$ares_configFile" "Nintendo64" "Path" "${romsPath}/n64"
	iniFieldUpdate "$ares_configFile" "Nintendo64DD" "Path" "${romsPath}/n64dd"
	iniFieldUpdate "$ares_configFile" "GameBoy" "Path" "${romsPath}/gb"
	iniFieldUpdate "$ares_configFile" "GameBoyColor" "Path" "${romsPath}/gbc"
	iniFieldUpdate "$ares_configFile" "GameBoyAdvance" "Path" "${romsPath}/gba"
	iniFieldUpdate "$ares_configFile" "SG-1000" "Path" "${romsPath}/sg-1000"
	iniFieldUpdate "$ares_configFile" "MasterSystem" "Path" "${romsPath}/mastersystem"
	iniFieldUpdate "$ares_configFile" "GameGear" "Path" "${romsPath}/gamegear"
	iniFieldUpdate "$ares_configFile" "MegaDrive" "Path" "${romsPath}/genesis"
	iniFieldUpdate "$ares_configFile" "Mega32X" "Path" "${romsPath}/genesis"
	iniFieldUpdate "$ares_configFile" "MegaCD" "Path" "${romsPath}/segacd"
	iniFieldUpdate "$ares_configFile" "MegaCD32X" "Path" "${romsPath}/segacd"
	iniFieldUpdate "$ares_configFile" "NeoGeoAES" "Path" "${romsPath}/arcade"
	iniFieldUpdate "$ares_configFile" "NeoGeoMVS" "Path" "${romsPath}/arcade"
	iniFieldUpdate "$ares_configFile" "NeoGeoPocket" "Path" "${romsPath}/ngp"
	iniFieldUpdate "$ares_configFile" "NeoGeoPocketColor" "Path" "${romsPath}/ngpc"
	iniFieldUpdate "$ares_configFile" "PlayStation" "Path" "${romsPath}/psx"
	iniFieldUpdate "$ares_configFile" "ZXSpectrum" "Path" "${romsPath}/zxspectrum"
	iniFieldUpdate "$ares_configFile" "ZXSpectrum128" "Path" "${romsPath}/zxspectrum"
	iniFieldUpdate "$ares_configFile" "SuperFamicom" "GameBoy" "${romsPath}/gb"
	iniFieldUpdate "$ares_configFile" "SuperFamicom" "SufamiTurbo" "${romsPath}/sufami"

	# BIOS Path
	iniFieldUpdate "$ares_configFile" "ColecoVision" "Firmware" "${biosPath}/colecovision.rom"
	iniFieldUpdate "$ares_configFile" "MSX" "Firmware" "${biosPath}/MSX.ROM"
	iniFieldUpdate "$ares_configFile" "MSX2" "BIOS.Japan" "${biosPath}/MSX2.ROM"
	iniFieldUpdate "$ares_configFile" "PCEngineCD" "BIOS.US" "${biosPath}/syscard3u.pce"
	iniFieldUpdate "$ares_configFile" "PCEngineCD" "BIOS.JAPAN" "${biosPath}/syscard3.pce"
	iniFieldUpdate "$ares_configFile" "SuperGrafxCD" "BIOS.Japan" "${biosPath}/syscard3.pce"
	iniFieldUpdate "$ares_configFile" "FamicomDiskSystem" "BIOS.Japan" "${biosPath}/disksys.rom"
	iniFieldUpdate "$ares_configFile" "Nintendo64DD" "BIOS.Japan" "${biosPath}/64DD_IPL_US.n64"
	iniFieldUpdate "$ares_configFile" "Nintendo64DD" "BIOS.US" "${biosPath}/64DD_IPL_JP.n64"
	iniFieldUpdate "$ares_configFile" "Nintendo64DD" "BIOS.DEV" "${biosPath}/64DD_IPL_DEV.n64"
	iniFieldUpdate "$ares_configFile" "MasterSystem" "BIOS.US" "${biosPath}/bios_CD_U.bin"
	iniFieldUpdate "$ares_configFile" "MasterSystem" "BIOS.Japan" "${biosPath}/bios_CD_J.bin"
	iniFieldUpdate "$ares_configFile" "MasterSystem" "BIOS.Europe" "${biosPath}/bios_CD_E.bin"
	iniFieldUpdate "$ares_configFile" "NeoGeoAES" "BIOS.World" "${biosPath}/neo-po.bin"
	iniFieldUpdate "$ares_configFile" "NeoGeoPocket" "BIOS.World" "${biosPath}/[BIOS] SNK Neo Geo Pocket (Japan, Europe).ngp"
	iniFieldUpdate "$ares_configFile" "NeoGeoPocketColor" "BIOS.World" "${biosPath}/[BIOS] SNK Neo Geo Pocket Color (World) (En,Ja).ngp"
	iniFieldUpdate "$ares_configFile" "PlayStation" "BIOS.US" "${biosPath}/scph5501.bin"
	iniFieldUpdate "$ares_configFile" "PlayStation" "BIOS.JAPAN" "${biosPath}/scph5500.bin"
	iniFieldUpdate "$ares_configFile" "PlayStation" "BIOS.EUROPE" "${biosPath}/scph5502.bin"

}

#SetupSaves
ares_setupSaves(){

    # Create saves folder
 	mkdir -p "${savesPath}/ares/"
    
	# Set saves path
	iniFieldUpdate "$ares_configFile" "Paths" "Saves" "${savesPath}"

}


#SetupStorage
ares_setupStorage(){
	
	# Create storage folder
	mkdir -p "${storagePath}/ares/"
	mkdir -p "${storagePath}/ares/screenshots"

    # Set screenshots path
	iniFieldUpdate "$ares_configFile" "Paths" "Screenshots" "${storagePath}/ares/screenshots"
}


#WipeSettings
ares_wipe(){
	rm -rf "$HOME/.var/app/$ares_emuPath"
}


#Uninstall
ares_uninstall(){
    flatpak uninstall "$ares_emuPath" --user -y
}

#setABXYstyle
ares_setABXYstyle(){
	echo "NYI"    
}

#Migrate
ares_migrate(){
	echo "NYI"    
}

#WideScreenOn
ares_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
ares_wideScreenOff(){
	echo "NYI"
}

#BezelOn
ares_bezelOn(){
echo "NYI"
}

#BezelOff
ares_bezelOff(){
echo "NYI"
}

ares_IsInstalled(){
	isFpInstalled "$ares_emuPath"
}

ares_resetConfig(){
	ares_init &>/dev/null && echo "true" || echo "false"
}

ares_addSteamInputProfile(){
	addSteamInputCustomIcons
	setMSG "Adding $ares_emuName Steam Input Profile."
	rsync -r "$EMUDECKGIT/configs/steam-input/ares_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

#finalExec - Extra stuff
ares_finalize(){
	echo "NYI"
}

