#!/bin/bash

# Why?
# Steam RetroArch allows you to save your game states and saves with steam cloud saves which is nice when 
# switching between your steamdeck and desktop. Without having to deal with google drive or dropbox.
# You can also gain acess to steam only features like online coop and remote play.

# Requirements:
# RetroArch must be installed on SD card and not internal storage 
# EmuDeck must be installed on SD card as well
# make sure you copy over any saves or states in the Flatpack version of RetroArch to the steam version 
# as any current saves will be over written with that of the steam verstion

# steps:
# Install RetroArch
# Run EmuDeck in easy mode
# Run this script


# What will happend:
# Will create symbolic links between Flatpak RetroArch and Steam RetroArch
# Current folders shared:
    # cheats (From Steam)
    # config (From Emu)
    # cores  (From Emu)
    # filters (From Steam)
    # playlist (From Steam)
    # saves (From Steam)
    # screenshots (From Steam)
    # states (From Steam)
    # thumbnails (From Steam)
# ln -s /<path to file/folder to be linked> <path of the link to be created>

# After running I recomend open EmuDeck steam in scanning the emulators forlder
# Next you can Go to main menu -> online updater and download all of thumbnails for you roms
# Now if you launce Steam Retroarch and load in your roms all the thumbnails should also be installed

# TODO does emudeck actullt install to SSD instead of SD card?
readonly STEAM=/run/media/mmcblk0p1/steamapps/common/RetroArch
readonly EMUDECK=/home/deck/.var/app/org.libretro.RetroArch/config/retroarch


# confuses steam retroarch into thinking no cores are installed
# # config (From Emu)
# rm -r $STEAM/config
# ln -s $EMUDECK/config $STEAM/config

# # cores  (From Emu)
# rm -r $STEAM/cores
# ln -s $EMUDECK/cores $STEAM/cores

# # filters (From Steam)
# rm -r $EMUDECK/filters
# ln -s $STEAM/filters $EMUDECK/filters

# cheats (From Steam)
rm -r $EMUDECK/cheats
ln -s $STEAM/cheats $EMUDECK/cheats

# thumbnails (From Steam)
rm -r $EMUDECK/thumbnails
ln -s $STEAM/thumbnails $EMUDECK/thumbnails

# playlist (From Steam)
rm -r $EMUDECK/playlists
ln -s $STEAM/playlists $EMUDECK/playlists

# saves (From Steam)
rm -r $EMUDECK/saves
ln -s $STEAM/saves $EMUDECK/saves

# screenshots (From Steam)
rm -r $EMUDECK/screenshots
ln -s $STEAM/screenshots $EMUDECK/screenshots

# states (From Steam)
rm -r $EMUDECK/states
ln -s $STEAM/states $EMUDECK/states