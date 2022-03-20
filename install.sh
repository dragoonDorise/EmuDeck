#!/bin/sh
mkdir dragoonDorise
cd dragoonDorise

git clone https://github.com/dragoonDorise/EmuDeck.git ~/dragoonDoriseTools/EmuDeck

#Get SD Card name
sdCard=$(ls /run/media)
sdCardPath="/run/media/${sdCard}"

#Generate rom folders
mkdir $sdCardPath/romss
rsync -r ~/dragoonDoriseTools/roms $sdCardPath/romss

#Overlays
mkdir /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays
rsync -r ~/dragoonDoriseTools/EmuDeck/RetroArch/config/ /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/config
rsync -r ~/dragoonDoriseTools/EmuDeck/RetroArch/overlays/ /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays
rsync -r ~/dragoonDoriseTools/EmuDeck/RetroArch/config/ /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/config

#Retroarch config

#cp /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg /home/deck/.#var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg.bak
#sed -i 's/config_save_on_exit = "true"/config_save_on_exit = "false"/g' /home/deck/.#var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/input_overlay_enable = "true"/input_overlay_enable = "false"/g' /home/deck/.#var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/menu_show_load_content_animation = "true"/menu_show_load_content_animation = #"false"/g' /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/notification_show_autoconfig = "true"/notification_show_autoconfig = "false"/g' #/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/notification_show_config_override_load = #"true"/notification_show_config_override_load = "false"/g' /home/deck/.var/app/org.libretro.#RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/notification_show_refresh_rate = "true"/notification_show_refresh_rate = "false"/g' #/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/notification_show_remap_load = "true"/notification_show_remap_load = "false"/g' #/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/notification_show_screenshot = "true"/notification_show_screenshot = "false"/g' #/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/notification_show_set_initial_disk = "true"/notification_show_set_initial_disk = #"false"/g' /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/notification_show_patch_applied = "true"/notification_show_patch_applied = #"false"/g' /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/input_menu_toggle_gamepad_combo = "0"/input_menu_toggle_gamepad_combo = "6"/g' #/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/input_enable_hotkey_btn = "nul"/input_enable_hotkey_btn = "4"/g' /home/deck/.#var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/input_exit_emulator_btn = "nul"/input_exit_emulator_btn = "108"/g' /home/deck/.#var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/input_load_state_btn = "nul"/input_load_state_btn = "9"/g' /home/deck/.var/app/org.#libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/input_menu_toggle_gamepad_combo = "nul"/input_menu_toggle_gamepad_combo = "6"/g' #/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/input_rewind_btn = "nul"/input_rewind_btn = "104"/g' /home/deck/.var/app/org.#libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/input_save_state_btn = "nul"/input_save_state_btn = "10"/g' /home/deck/.var/app/org.#libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/input_state_slot_decrease_btn = "nul"/input_state_slot_decrease_btn = "h0down"/g' #/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/input_state_slot_increase_btn = "nul"/input_state_slot_increase_btn = "h0up"/g' #/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/input_toggle_fast_forward_btn = "nul"/input_toggle_fast_forward_btn = "+5"/g' #/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg 
#sed -i 's/menu_driver = "glui"/menu_driver = "ozone"/g' /home/deck/.var/app/org.libretro.#RetroArch/config/retroarch/retroarch.cfg 

#Overlays
mkdir /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays
rsync -r ~/dragoonDoriseTools/EmuDeck/RetroArch/config/ /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/config
rsync -r ~/dragoonDoriseTools/EmuDeck/RetroArch/overlays/ /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays
