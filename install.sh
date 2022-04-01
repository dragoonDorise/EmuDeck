#!/bin/sh
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
BLINK='\x1b[5m'

destination=$1
romsPath="/home/deck/Emulation/roms/"
romsPathSed="\/home\/deck\/Emulation\/roms\/"
biosPath="/home/deck/Emulation/bios/"
biosPathSed="\/home\/deck\/Emulation\/bios\/"
if [ $destination == "SD" ]; then
	#Get SD Card name
	sdCard=$(ls /run/media | grep -ve '^deck$' | head -n1)
	romsPath="/run/media/${sdCard}/Emulation/roms/"
	romsPathSed="\/run\/media\/${sdCard}\/Emulation\/roms\/"
	biosPath="/run/media/${sdCard}/Emulation/bios/"
	biosPathSed="\/run\/media\/${sdCard}\/Emulation\/bios\/"
fi

rm -rf ~/dragoonDoriseTools
echo -ne "${BOLD}Downloading files...${NONE}"
sleep 5
mkdir -p dragoonDoriseTools
mkdir -p dragoonDoriseTools/EmuDeck
cd dragoonDoriseTools


git clone https://github.com/dragoonDorise/EmuDeck.git ~/dragoonDoriseTools/EmuDeck &>> /dev/null

FOLDER=~/dragoonDoriseTools/EmuDeck
if [ -d "$FOLDER" ]; then
	echo -e "${GREEN}OK!${NONE}"
else
	echo -e ""
	echo -e "${RED}We couldn't download the needed files, exiting in a few seconds${NONE}"
	echo -e "Please close this window and try again in a few minutes"
	sleep 999999
	exit
fi
clear
cat ~/dragoonDoriseTools/EmuDeck/logo.ans
version=$(cat ~/dragoonDoriseTools/EmuDeck/version.md)
echo -e "${BOLD}EmuDeck ${version}${NONE}"
echo -e ""


##Generate rom folders
if [ $destination == "SD" ]; then
	echo -ne "${BOLD}Creating roms folder in your SD Card...${NONE}"
else
	echo -ne "${BOLD}Creating roms folder in your home folder...${NONE}"
fi
mkdir -p $romsPath
mkdir -p $biosPath
mkdir -p $biosPath/yuzu/
sleep 3
rsync -r ~/dragoonDoriseTools/EmuDeck/roms/ $romsPath &>> /dev/null
echo -e "${GREEN}OK!${NONE}"
#Steam RomManager
echo -e ""
echo -e ""
echo -ne "${BOLD}Configuring Steam Rom Manager...${NONE}"
mkdir -p ~/.config/steam-rom-manager/userData/
cp ~/dragoonDoriseTools/EmuDeck/configs/steam-rom-manager/userData/userConfigurations.json ~/.config/steam-rom-manager/userData/userConfigurations.json
sleep 3

sed -i "s/\/run\/media\/mmcblk0p1\/Emulation\/roms\//${romsPathSed}/g" ~/.config/steam-rom-manager/userData/userConfigurations.json



echo -e "${GREEN}OK!${NONE}"

echo -ne "${BOLD}Configuring Emulation Station...${NONE}"
mkdir -p ~/.emulationstation/
cp ~/dragoonDoriseTools/EmuDeck/configs/emulationstation/es_settings.xml ~/.emulationstation/es_settings.xml
sed -i "s/\/run\/media\/mmcblk0p1\/Emulation\/roms\//${romsPathSed}/g" ~/.emulationstation/es_settings.xml
#sed -i "s/name=\"ROMDirectory\" value=\"/name=\"ROMDirectory\" value=\"${romsPathSed}/g" ~/.emulationstation/es_settings.xml
echo -e "${GREEN}OK!${NONE}"

#Check for installed emulators
doRA=true
doDolphin=true
doPCSX2=true
doRPCS3=true
doYuzu=true
doCitra=true
doDuck=true
doCemu=false
doRyujinx=true
doPrimeHacks=true
doPPSSPP=true

echo -e ""
echo -e ""
echo -e "${BOLD}Checking installed Emulators..${NONE}"
echo -e ""
#RA
FOLDER=~/.var/app/org.libretro.RetroArch/
echo -ne "Checking RA installation..."
if [ -d "$FOLDER" ]; then
	echo -e "${GREEN}OK!${NONE}"
	doRA=true
else
	echo -e "${RED}Installing...${NONE}"
	flatpak install flathub org.libretro.RetroArch -y
fi
#DolphinPrimeHacks
FOLDER=~/.var/app/io.github.shiiion.primehack/
echo -ne "Checking PrimeHacks installation..."
if [ -d "$FOLDER" ]; then
	echo -e "${GREEN}OK!${NONE}"
	doPrimeHacks=true
else
	echo -e "${RED}Installing...${NONE}"
	flatpak install flathub io.github.shiiion.primehack -y
fi


#Dolphin
FOLDER=~/.var/app/org.DolphinEmu.dolphin-emu/
echo -ne "Checking Dolphin installation..."
if [ -d "$FOLDER" ]; then
	echo -e "${GREEN}OK!${NONE}"
	doDolphin=true
else
	echo -e "${RED}Installing...${NONE}"
	flatpak install flathub org.DolphinEmu.dolphin-emu -y
fi
#PPSSPP
FOLDER=~/.var/app/org.ppsspp.PPSSPP/
echo -ne "Checking StandAlone PPSSPP installation..."
if [ -d "$FOLDER" ]; then
	echo -e "${GREEN}OK!${NONE}"
	doPPSSPP=true
else
	echo -e "${RED}Installing...${NONE}"
	flatpak install flathub org.ppsspp.PPSSPP -y
fi
	

#PS2
FOLDER=~/.var/app/net.pcsx2.PCSX2/
echo -ne "Checking PCSX2 installation..."
if [ -d "$FOLDER" ]; then
	echo -e "${GREEN}OK!${NONE}"
	doPCSX2=true
else
	echo -e "${RED}Installing...${NONE}"
	flatpak install flathub net.pcsx2.PCSX2 -y
fi

#PS3
FOLDER=~/.var/app/net.rpcs3.RPCS3/
echo -ne "Checking RPCS3 installation..."
if [ -d "$FOLDER" ]; then
	echo -e "${GREEN}OK!${NONE}"
	doRPCS3=true
else
	echo -e "${RED}Installing...${NONE}"
	flatpak install flathub net.rpcs3.RPCS3 -y
fi

#YUZU
FOLDER=~/.var/app/org.yuzu_emu.yuzu/
echo -ne "Checking Yuzu installation..."
if [ -d "$FOLDER" ]; then
	echo -e "${GREEN}OK!${NONE}"
	doYuzu=true
else
	echo -e "${RED}Installing...${NONE}"
	flatpak install flathub org.yuzu_emu.yuzu -y
fi
#Citra
FOLDER=~/.var/app/org.citra_emu.citra/
echo -ne "Checking Citra installation..."
if [ -d "$FOLDER" ]; then
	echo -e "${GREEN}OK!${NONE}"
	doCitra=true
else
	echo -e "${RED}Installing...${NONE}"
	flatpak install flathub org.citra_emu.citra -y
fi
#Duckstation
FOLDER=~/.var/app/org.duckstation.DuckStation/
echo -ne "Checking Duckstation installation..."
if [ -d "$FOLDER" ]; then
	echo -e "${GREEN}OK!${NONE}"
	doDuck=true
else
	echo -e "${RED}Installing...${NONE}"
	flatpak install flathub org.duckstation.DuckStation -y
fi

#Cemu
if [ $destination == "SD" ]; then
	FILE="/run/media/${sdCard}/Emulation/roms/wiiu/Cemu.exe"
else
	FILE="/home/deck/Emulation/roms/wiiu/Cemu.exe"
fi

echo -ne "Checking Cemu installation..."
if [ -f "$FILE" ]; then
	echo -e "${GREEN}OK!${NONE}"
	doCemu=true
else
	echo -e "${RED}Cemu it's not installed...${NONE}"
	doCemu=false
fi
#Ryujimx
#FOLDER=~/.var/app/org.ryujinx.Ryujinx/
#echo -ne "Checking Ryujinx installation..."
#if [ -d "$FOLDER" ]; then
#	echo -e "${GREEN}OK!${NONE}"
#	doRyujinx=false
#else
#	echo -e "${RED}Installing...${NONE}"
#	flatpak install flathub org.libretro.RetroArch -y
#fi
#Emus config

echo -e ""
echo -e ""
echo -ne "${BOLD}Configuring Steam Input for emulators..${NONE}"
echo -e ""
rsync -r ~/dragoonDoriseTools/EmuDeck/configs/steam-input/ ~/.steam/steam/controller_base/templates/
echo -e "${GREEN}OK!${NONE}"

echo -e ""
echo -e ""
echo -e "${BOLD}Configuring emulators..${NONE}"
echo -e ""
if [ $doRA == true ]; then
	
	raUrl="https://buildbot.libretro.com/nightly/linux/x86_64/latest/"
	raCorePath=""
	RAcores=(bsnes_hd_beta_libretro.so flycast_libretro.so gambatte_libretro.so genesis_plus_gx_libretro.so genesis_plus_gx_wide_libretro.so mednafen_lynx_libretro.so mednafen_ngp_libretro.so mednafen_wswan_libretro.so melonds_libretro.so mesen_libretro.so mgba_libretro.so mupen64plus_next_libretro.so nestopia_libretro.so picodrive_libretro.so ppsspp_libretro.so snes9x_libretro.so stella_libretro.so yabasanshiro_libretro.so yabause_libretro.so yabause_libretro.so mame2003_plus_libretro.so melonds_libretro.so fbneo_libretro.so bluemsx_libretro.so desmume_libretro.so sameboy_libretro.so gearsystem_libretro.so mednafen_saturn_libretro.so)
	echo -e "Downloading RetroArch Cores"
	mkdir -p /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/
	for i in "${RAcores[@]}"
	do
		FILE=/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}
		if [ -f "$FILE" ]; then
			echo -e "${i}...${YELLOW}Already Downloaded${NONE}"	
		else
			curl $raUrl$i.zip --output /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip
			#rm /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip
			echo -e "${i}...${GREEN}Downloaded!${NONE}"	
		fi
	done
	
	for entry in /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/*.zip
	do
		 unzip -o $entry -d /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/
	done
	
	for entry in /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/*.zip
	do
		 rm -f $entry
	done
	
	raConfigFile="/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg"
	FILE=/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg.bak
	if [ -f "$FILE" ]; then
		echo -e "RetroArch is already backed up."
	else
		echo -ne "Backing up RA..."
		cp /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg.bak
		echo -e "${GREEN}OK!${NONE}"
	fi
	#mkdir -p /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays
	rsync -r ~/dragoonDoriseTools/EmuDeck/configs/org.libretro.RetroArch/config/ ~/.var/app/org.libretro.RetroArch/config/
	#rsync -r ~/dragoonDoriseTools/EmuDeck/configs/org.libretro.RetroArch/config/retroarch/config/ ~/.var/app/org.libretro.RetroArch/config/retroarch/config
	
#	sed -i 's/config_save_on_exit = "true"/config_save_on_exit = "false"/g' $raConfigFile
#	sed -i 's/input_overlay_enable = "true"/input_overlay_enable = "false"/g' $raConfigFile
#	sed -i 's/menu_show_load_content_animation = "true"/menu_show_load_content_animation = "false"/g' $raConfigFile
#	sed -i 's/notification_show_autoconfig = "true"/notification_show_autoconfig = "false"/g' $raConfigFile
#	sed -i 's/notification_show_config_override_load = "true"/notification_show_config_override_load = "false"/g' $raConfigFile
#	sed -i 's/notification_show_refresh_rate = "true"/notification_show_refresh_rate = "false"/g' $raConfigFile
#	sed -i 's/notification_show_remap_load = "true"/notification_show_remap_load = "false"/g' $raConfigFile
#	sed -i 's/notification_show_screenshot = "true"/notification_show_screenshot = "false"/g' $raConfigFile
#	sed -i 's/notification_show_set_initial_disk = "true"/notification_show_set_initial_disk = "false"/g' $raConfigFile
#	sed -i 's/notification_show_patch_applied = "true"/notification_show_patch_applied = "false"/g' $raConfigFile
#	sed -i 's/menu_swap_ok_cancel_buttons = "false"/menu_swap_ok_cancel_buttons = "true"/g' $raConfigFile
#	sed -i 's/savestate_auto_save = "false"/savestate_auto_save = "true"/g' $raConfigFile
#	sed -i 's/savestate_auto_load = "false"/savestate_auto_load = "true"/g' $raConfigFile
#	sed -i 's/video_fullscreen = "false"/video_fullscreen = "true"/g' $raConfigFile
#	sed -i 's/video_shader_enable = "false"/video_shader_enable = "true"/g' $raConfigFile
	
	sed -i "s/system_directory = \"~\/.var\/app\/org.libretro.RetroArch\/config\/retroarch\/system\"/system_directory = \"${biosPathSed}\"/g" $raConfigFile
	
#	sed -i 's/input_enable_hotkey_btn = "nul"/input_enable_hotkey_btn = "4"/g' $raConfigFile
#	sed -i 's/input_fps_toggle_btn = "nul"/input_fps_toggle_btn = "3"/g' $raConfigFile
#	sed -i 's/input_load_state_btn = "nul"/input_load_state_btn = "9"/g' $raConfigFile
#	sed -i 's/input_rewind_axis = "nul"/input_rewind_axis = "+4"/g' $raConfigFile
#	sed -i 's/input_save_state_btn = "nul"/input_save_state_btn = "10"/g' $raConfigFile
#	sed -i 's/input_menu_toggle_gamepad_combo = "0"/input_menu_toggle_gamepad_combo = "2"/g' $raConfigFile
#	sed -i 's/input_hold_fast_forward_axis = "nul"/input_hold_fast_forward_axis = "+5"/g' $raConfigFile
#	sed -i 's/input_quit_gamepad_combo = "0"/input_quit_gamepad_combo = "4"/g' $raConfigFile
#	sed -i 's/input_pause_toggle_btn = "nul"/input_pause_toggle_btn = "0"/g' $raConfigFile
fi
echo -e ""
echo -ne "Applying Emu configurations..."
if [ $doPrimeHacks == true ]; then
	FOLDER=~/.var/app/io.github.shiiion.primehack/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> /dev/null
	else
		echo -ne "Backing up PrimeHacks..."
		cp -r ~/.var/app/io.github.shiiion.primehack/config ~/.var/app/io.github.shiiion.primehack/config_bak
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/io.github.shiiion.primehack/ ~/.var/app/io.github.shiiion.primehack/ &>> /dev/null
fi
if [ $doDolphin == true ]; then
	FOLDER=~/.var/app/org.DolphinEmu.dolphin-emu/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> /dev/null
	else
		echo -ne "Backing up Dolphin..."
		cp -r ~/.var/app/org.DolphinEmu.dolphin-emu/config ~/.var/app/org.DolphinEmu.dolphin-emu/config_bak
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.DolphinEmu.dolphin-emu/ ~/.var/app/org.DolphinEmu.dolphin-emu/ &>> /dev/null
fi
if [ $doPCSX2 == true ]; then
	FOLDER=~/dragoonDoriseTools/EmuDeck/configs/net.pcsx2.PCSX2/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> /dev/null
	else
		echo -ne "Backing up PCSX2..."
		cp -r ~/.var/app/net.pcsx2.PCSX2/config ~/.var/app/net.pcsx2.PCSX2/config_bak
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/net.pcsx2.PCSX2/ ~/.var/app/net.pcsx2.PCSX2/ &>> /dev/null
	#Bios Fix
	sed -i "s/\/run\/media\/mmcblk0p1\/Emulation\/bios\//${biosPathSed}/g" ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/inis/PCSX2_ui.ini &>> /dev/null
fi
if [ $doRPCS3 == true ]; then
	FOLDER=~/.var/app/net.rpcs3.RPCS3/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> /dev/null
	else
		echo -ne "Backing up RPCS3..."
		cp -r ~/.var/app/net.rpcs3.RPCS3/config ~/.var/app/net.rpcs3.RPCS3/config_bak
		echo -e "${GREEN}OK!${NONE}"
	fi

	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/net.rpcs3.RPCS3/ ~/.var/app/net.rpcs3.RPCS3/ &>> /dev/null
fi
if [ $doCitra == true ]; then
	FOLDER=~/.var/app/org.citra_emu.citra/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> /dev/null
	else
		echo -ne "Backing up Citra..."
		cp -r ~/.var/app/org.citra_emu.citra/config ~/.var/app/org.citra_emu.citra/config_bak
		echo -e "${GREEN}OK!${NONE}"
	fi

	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.citra_emu.citra/ ~/.var/app/org.citra_emu.citra/ &>> /dev/null
fi
if [ $doDuck == true ]; then
	FOLDER=~/.var/app/org.duckstation.DuckStation/data_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> /dev/null
	else
		echo -ne "Backing up DuckStation..."
		cp -r ~/.var/app/org.duckstation.DuckStation/data ~/.var/app/org.duckstation.DuckStation/data_bak
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.duckstation.DuckStation/ ~/.var/app/org.duckstation.DuckStation/ &>> /dev/null
	sleep 3
	sed -i "s/\/run\/media\/mmcblk0p1\/Emulation\/bios\//${biosPathSed}/g" ~/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini
fi
if [ $doYuzu == true ]; then
	FOLDER=~/.var/app/org.yuzu_emu.yuzu/config
	if [ -d "$FOLDER" ]; then
		echo "" &>> /dev/null
	else
		echo -ne "Backing up Yuzu..."
		cp -r ~/.var/app/org.yuzu_emu.yuzu/config ~/.var/app/org.yuzu_emu.yuzu/config_bak
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.yuzu_emu.yuzu/ ~/.var/app/org.yuzu_emu.yuzu/ &>> /dev/null
fi
if [ $doCemu == true ]; then
	echo "" &>> /dev/null
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/cemu/ ${romsPath}/wiiu &>> /dev/null
fi
if [ $doRyujinx == true ]; then
	echo "" &>> /dev/null
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.ryujinx.Ryujinx/ ~/.var/app/org.ryujinx.Ryujinx/ &>> /dev/null
fi
if [ $doPPSSPP == true ]; then
	FOLDER=~/.var/app/org.ppsspp.PPSSPP/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> /dev/null
	else
		echo -ne "Backing up PPSSPP..."
		cp -r ~/.var/app/org.ppsspp.PPSSPP/config ~/.var/app/org.ppsspp.PPSSPP/config_bak
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.ppsspp.PPSSPP/ ~/.var/app/org.ppsspp.PPSSPP/ &>> /dev/null
fi
echo -e "${GREEN}OK!${NONE}"
echo -e ""
echo -ne "Cleaning up downloaded files..."	
rm -rf ~/dragoonDoriseTools	
echo -e "${GREEN}OK!${NONE}"
echo -e ""
echo -e ""
echo -e "Now to add your games copy them to this exact folder within the appropiate subfolder for each system:"
echo -e ""
echo -e ${BOLD}$romsPath${NONE}
echo -e ""
echo -e "Copy your BIOS in this folder:"
echo -e ""
echo -e ${BOLD}$biosPath${NONE}
echo -e ""
echo -e "When you are done copying your roms and BIOS do the following:"
echo -e "1: Right Click the Steam Icon in the taskbar and close it. If you are using the integrated trackpads, the left mouse button is now the R2 and the right mouse button is the L1 button"
echo -e "2: Open Steam Rom Manager"
echo -e "3: On Steam Rom Manager click on Preview"
echo -e "4: Now click on Generate app list"
echo -e "5: Wait for the images to finish (Marked as remaining providers on the top)"
echo -e "6: Click Save app list"
echo -e "7: Close Steam Rom Manager and this window and click on Return to Gaming Mode."
echo -e "8: Enjoy!"

echo -e "${RED}Cemu Special configuration${NONE}"
echo -e "Download Cemu from cemu.info and copy its files to ${romsPath}/wiiu"
echo -e "Copy your games on wux or wud format to ${romsPath}/wiiu/roms"
echo -e "When you add a Wii U game to Steam using Steam Rom Manager"
echo -e "you need to go to that game Properties and activate Compatibility -> proton 7.0-1"
#Symlinks
cd $(echo $romsPath | tr -d '\r')
ln -s segacd megacd
ln -s gamecube gc
ln -s genesis megadrive
ln -s ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/keys $biosPath/yuzu/keys
ln -s ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/nand/system/Contents/registered $biosPath/yuzu/firmware
sleep 999999999