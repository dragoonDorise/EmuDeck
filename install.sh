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
	sdCard=$(ls /run/media)
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
curl https://github.com/SteamGridDB/steam-rom-manager/releases/download/v2.3.29/Steam-ROM-Manager-2.3.29.AppImage --output ~/Desktop/Steam-ROM-Manager.AppImage &>> /dev/null

FOLDER=~/dragoonDoriseTools/EmuDeck
if [ -d "$FOLDER" ]; then
	echo -e "${GREEN}OK!${NONE}"
else
	echo -e ""
	echo -e "${RED}We couldn't download the needed files, exiting in a few seconds${NONE}"
	echo -e "Please try again in a few minutes"
	sleep 10
	exit
fi

##Generate rom folders
if [ $destination == "internal" ]; then
	echo -ne "${BOLD}Creating roms folder in your SD Card...${NONE}"
else
	echo -ne "${BOLD}Creating roms folder in your home folder...${NONE}"
fi
mkdir -p $romsPath
mkdir -p $biosPath
sleep 3
rsync -r ~/dragoonDoriseTools/EmuDeck/roms/ $romsPath &>> /dev/null
echo -e "${GREEN}OK!${NONE}"
#Steam RomManager
echo -e ""
echo -e ""
echo -ne "${BOLD}Configuring Steam Rom Manager...${NONE}"
cp ~/dragoonDoriseTools/EmuDeck/configs/steam-rom-manager/userData/userConfigurations.json ~/.config/steam-rom-manager/userData/userConfigurations.json
sleep 3
sed -i "s/\/run\/media\/mmcblk0p1\/roms\//${romsPathSed}/g" ~/.config/steam-rom-manager/userData/userConfigurations.json

echo -e "${GREEN}OK!${NONE}"
#Check for installed emulators
doRA=false
doDolphin=false
doPCSX2=false
doRPCS3=false
doYuzu=false
doCitra=false
doDuck=false

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
	echo -e "${RED}KO :(${NONE}"
	echo -e "${RED}Install and launch Retroarch from the Discover App if you want to configure it${NONE}"
fi
#Dolphin
FOLDER=~/.var/app/org.DolphinEmu.dolphin-emu/
echo -ne "Checking Dolphin installation..."
	if [ -d "$FOLDER" ]; then
		echo -e "${GREEN}OK!${NONE}"
		doDolphin=true
else
		echo -e "${RED}KO :(${NONE}"
		echo -e "${RED}Install and launch Dolphin from the Discover App if you want to configure it${NONE}"
	fi

#PS2
FOLDER=~/.var/app/net.pcsx2.PCSX2/
echo -ne "Checking PCSX2 installation..."
	if [ -d "$FOLDER" ]; then
		echo -e "${GREEN}OK!${NONE}"
		doPCSX2=false
else
		echo -e "${RED}KO :(${NONE}"
		echo -e "${RED}Install and launch PCSX2 from the Discover App if you want to configure it${NONE}"
	fi

#PS3
FOLDER=~/.var/app/net.rpcs3.RPCS3/
echo -ne "Checking RPCS3 installation..."
	if [ -d "$FOLDER" ]; then
		echo -e "${GREEN}OK!${NONE}"
		doRPCS3=false
else
		echo -e "${RED}KO :(${NONE}"
		echo -e "${RED}Install and launch RPCS3 from the Discover App if you want to configure it${NONE}"
	fi

#YUZU
FOLDER=~/.var/app/org.yuzu_emu.yuzu/
echo -ne "Checking Yuzu installation..."
	if [ -d "$FOLDER" ]; then
		echo -e "${GREEN}OK!${NONE}"
		doYuzu=false
else
		echo -e "${RED}KO :(${NONE}"
		echo -e "${RED}Install and launch Yuzu from the Discover App if you want to configure it${NONE}"
	fi
#Citra
	FOLDER=~/.var/app/org.citra_emu.citra/
	echo -ne "Checking Citra installation..."
	if [ -d "$FOLDER" ]; then
		echo -e "${GREEN}OK!${NONE}"
		doCitra=true
	else
		echo -e "${RED}KO :(${NONE}"
		echo -e "${RED}Install and launch Citra from the Discover App if you want to configure it${NONE}"
	fi
#Duckstation
	FOLDER=~/.var/app/org.duckstation.DuckStation/
	echo -ne "Checking Duckstation installation..."
	if [ -d "$FOLDER" ]; then
		echo -e "${GREEN}OK!${NONE}"
		doDuck=true
	else
		echo -e "${RED}KO :(${NONE}"
		echo -e "${RED}Install and launch Duckstation from the Discover App if you want to configure it${NONE}"
	fi

#Emus config

echo -e ""
echo -e ""
echo -e "${BOLD}Configuring emulators..${NONE}"
echo -e ""
if [ $doRA == true ]; then
	
	raConfigFile="/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg"
	FILE=/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg.bak
	if [ -d "$FILE" ]; then
		echo -e "RetroArch is already backed up."
	else
		echo -ne "Backing up RA..."
		cp /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg.bak
		echo -e "${GREEN}OK!${NONE}"
	fi
	mkdir -p /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays
	rsync -r ~/dragoonDoriseTools/EmuDeck/configs/org.libretro.RetroArch/config/retroarch/overlays/ ~/.var/app/org.libretro.RetroArch/config/retroarch/overlays
	rsync -r ~/dragoonDoriseTools/EmuDeck/configs/org.libretro.RetroArch/config/retroarch/config/ ~/.var/app/org.libretro.RetroArch/config/retroarch/config

	sed -i 's/config_save_on_exit = "true"/config_save_on_exit = "false"/g' $raConfigFile
	sed -i 's/input_overlay_enable = "true"/input_overlay_enable = "false"/g' $raConfigFile
	sed -i 's/menu_show_load_content_animation = "true"/menu_show_load_content_animation = "false"/g' $raConfigFile
	sed -i 's/notification_show_autoconfig = "true"/notification_show_autoconfig = "false"/g' $raConfigFile
	sed -i 's/notification_show_config_override_load = "true"/notification_show_config_override_load = "false"/g' $raConfigFile
	sed -i 's/notification_show_refresh_rate = "true"/notification_show_refresh_rate = "false"/g' $raConfigFile
	sed -i 's/notification_show_remap_load = "true"/notification_show_remap_load = "false"/g' $raConfigFile
	sed -i 's/notification_show_screenshot = "true"/notification_show_screenshot = "false"/g' $raConfigFile
	sed -i 's/notification_show_set_initial_disk = "true"/notification_show_set_initial_disk = "false"/g' $raConfigFile
	sed -i 's/notification_show_patch_applied = "true"/notification_show_patch_applied = "false"/g' $raConfigFile
	sed -i 's/menu_swap_ok_cancel_buttons = "false"/menu_swap_ok_cancel_buttons = "true"/g' $raConfigFile
	sed -i 's/savestate_auto_save = "false"/savestate_auto_save = "true"/g' $raConfigFile
	sed -i 's/savestate_auto_load = "false"/savestate_auto_load = "true"/g' $raConfigFile
	sed -i 's/video_fullscreen = "false"/video_fullscreen = "true"/g' $raConfigFile
	sed -i 's/video_shader_enable = "false"/video_shader_enable = "true"/g' $raConfigFile
	
	
	sed -i 's/input_enable_hotkey_btn = "nul"/input_enable_hotkey_btn = "4"/g' $raConfigFile
	sed -i 's/input_fps_toggle_btn = "nul"/input_fps_toggle_btn = "3"/g' $raConfigFile
	sed -i 's/input_load_state_btn = "nul"/input_load_state_btn = "9"/g' $raConfigFile
	sed -i 's/input_rewind_axis = "nul"/input_rewind_axis = "+4"/g' $raConfigFile
	sed -i 's/input_save_state_btn = "nul"/input_save_state_btn = "10"/g' $raConfigFile
	sed -i 's/input_menu_toggle_gamepad_combo = "nul"/input_menu_toggle_gamepad_combo = "2"/g' $raConfigFile
	sed -i 's/input_hold_fast_forward_axis = "nul"/input_hold_fast_forward_axis = "+5"/g' $raConfigFile
	sed -i 's/input_quit_gamepad_combo = "0"/input_quit_gamepad_combo = "4"/g' $raConfigFile
	sed -i 's/input_pause_toggle_btn = "nul"/input_pause_toggle_btn = "0"/g' $raConfigFile
fi
echo -e ""
echo -ne "Applying Emu configurations..."
if [ $doDolphin == true ]; then
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.DolphinEmu.dolphin-emu/ ~/.var/app/org.DolphinEmu.dolphin-emu/ &>> /dev/null
fi
if [ $doPCSX2 == true ]; then
	#rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/net.pcsx2.PCSX2/ ~/.var/app/net.pcsx2.PCSX2/ &>> /dev/null
fi
if [ $doRPCS3 == true ]; then
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/net.rpcs3.RPCS3/ ~/.var/app/net.rpcs3.RPCS3/ &>> /dev/null
fi
if [ $doCitra == true ]; then
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.citra_emu.citra/ ~/.var/app/org.citra_emu.citra/ &>> /dev/null
fi
if [ $doDuck == true ]; then
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.duckstation.DuckStation/ ~/.var/app/org.duckstation.DuckStation/ &>> /dev/null
	sleep 3
	sed -i "s/\/run\/media\/mmcblk0p1\/Emulation\/bios\/${biosPathSed}/g" ~/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini
fi
if [ $doYuzu == true ]; then
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.yuzu_emu.yuzu/ ~/.var/app/org.yuzu_emu.yuzu/ &>> /dev/null
fi
echo -e "${GREEN}OK!${NONE}"
echo -e ""
echo -ne "Cleaning up downloaded files..."	
rm -rf ~/dragoonDoriseTools	
echo -e "${GREEN}OK!${NONE}"
echo -e ""
echo -e ""
echo -e "Now to add your games copy them to this exact folder within the appropiate subfolder for each system:"
echo -e $romsPath
echo -e "Copy your BIOS in this folder:"
echo -e $biosPath
echo -e "When you are done copying your roms and BIOS do the following:"
echo -e "1: Right Click the Steam Icon in the taskbar and close it. If you are using the integrated trackpads, the left mouse button is now the R2 and the right mouse button is the L1 button"
echo -e "2: Open Steam Rom Manager"
echo -e "3: On Steam Rom Manager click on Preview"
echo -e "3: Now click on Generate app list"

sleep 999999999