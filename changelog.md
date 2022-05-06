0.1 > 0.4

- Several fixes

  0.5

- RetroArch Core downloader
- MAME 2003 Plus
- Genesis

  0.5.1

- Dreamcast 16:9 hacks

  0.5.2

- Fixes Genesis (SRM) & Gamecube(folder name)

  0.5.3

- Fullscreen Citra + Steam Input for Citra Roms
  steam://controllerconfig/3151590086/2784099045

  0.6

- Added Yuzu and NDS support

  0.6.1

- Added FBNeo support

  0.6.2

- Fix BIOS folder RA

  0.6.3

- Cemu Experimental

  0.6.4

- Ryujinx controls
- Fix RA Toggle Menu L3+R3
- Nunchuk fix

  0.7

- PrimeHacks support
- Fix .md on genesis folders

  0.8

- Automatic Steam Input for Citra and Cemu

  0.8.1

- CEMU Steam Input fix

  0.9

- Added EmulationStation rom path configuration, folders and cores

  0.10

- Fixed Yuzu's controls on Steam UI
- Added standalone PPSSPP
- Added PS2 optimized configuration

  0.11

- Automatic Emulator Installation
- No need to launch the emulators before playing for the first time
- Yuzu paths for Firmware and Keys are symlinked in Emulation/bios

  0.12

- Fixes several Bugs
- Adds cores for EmulationStation DE
- Installs EmulationStation DE
- Creates EmulationStation DE icon on SteamUI
- Removes readme.md files to prevent problems with Sega Systems
- Added Cemu icon to SteamUI
- Vulkan for CEMU
- ES Fix

  0.13

- RA Fix
- Cemu autoinstallation
- Log file
- RPCS3 Controls
- SRM autoinstallation
- ES Fix

  0.14

- RPCS3 is working from SteamUI thanks to Flatseal

  0.15

- Complete revamp of the interface
- Now you can customize some RetroArch Options: Bezels
- Emulators can now be skipped so you can mantain your custom configuration

  0.15.1

- Added support for .rpx Wii U Games

  0.15.2

- Fixed Gamecube and Wii controls
- Dolphin FPS meter disabled by default

  0.15.3

- Fixed RA bios path on internal storage
- RA changed fast forward mode from hold to toggle
- Added MAME folders for 2010, 2003 and current.
- Fixed some EmuDeck customize menus that weren't appearing
- Fixed Citra buttons to original hardware button positions A<->B

  0.15.4

- Fixes a bug on 0.15.3 that prevented the script to finish
- Amber Elec Hotkeys configured for almost all emulators
- Hotkeys and Emulators cheatsheet available on github: https://github.com/dragoonDorise/EmuDeck

  0.15.5

- More PS1 formats supported. Thanks to https://github.com/Godsbane
- SRM always up to date. Thanks to https://github.com/Nikki1993
- Fixed Atary Linx
- Fixed symlinks repeating itselfs inside folders
- Fixes RA save configuration file issue
- Removes symlinks for MegaDrive y MegaCD
- Fixed recursive symlinks on yuzu folders
- Added 3DO support
- Fixed issues with bios paths when using internal storage
- Better BIOS detection for PS1 and PS2
- Fixes autoload / autosave option on RetroArch

  0.16

- Fixes Nes Bezels when using Mesen Core
- Fixes RA warning "Controller not configured, using fallback"
- Showing latest changelog when updating EmuDeck
- New Easy mode - 100% Plug and play for non tech savvy users.
- New Expert mode - Power users can now customize EmuDeck installations:

  - Choose what Emulators to install
  - Choose if you want to keep your configuration or if you want EmuDeck to overwrite it.
  - RA configuration: Bezels ON/OFF Autosave ON/OFF
  - Allows users to be able to save its own RA configuration ( Bezels needs to be turned OFF, it's a RA Bug)
  - This mode will allow a lot more in the future: Use non EXT4 SD Cards, use experimental emulators, choose different frontends, etc.

    0.16.2

- Cemu installation fixes

  0.17

- Added Beta and Dev release channels
- ESDE Downloaded data moved to SD Card if the user chose SD card on install
- Uninstall icon for those that want to uninstall EmuDeck
- Updated Icon with current version installed
- Fixes Bezels and Autosave configuration
- Added Xemu emulator support - Godsbane
- Enabled rumble motor on Dolphin
- Improved SD Card detection - Godsbane
- Added .wua support for upcoming Cemu 1.27 - v-tron

  0.17.1

- New Emulation/saves folder so you can sync your saved games and states using Dropbox or similar
- Snes Aspect Ratio selection (4:3 or 8:7)
- Widescreen Hacks selection (Flycast RA, Dolphin, DuckStation)
- CHD Conversion script
- Support for PowerTools on Expert Mode - Improves Yuzu and Dolphin performance
- Added support for DualShock 4 and DualSense controllers for player 2 and 3
- Wii U Rom folder creation fix
- Fixed PrimeHack SRM config - Godsbane
- Fixed PS1 SRM parsers to avoid duplicated titles - Godsbane
- Fixed PrimeHack controller config
- Fixes for people with custom flathubs repos - Godsbane
- New SD Card detection method ( BTRFS Support is back ) - popsUlfr + Godsbane
- Added Emulators parser on SRM
