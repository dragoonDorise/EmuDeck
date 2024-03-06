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

  0.17.2

- Added RetroAchievments for RA
- Added Amiga support on SRM
- Set default emulators on ESDE
- Uninstaller fixes
- Fixed Widescreen toggle for Dolphin
- RA video driver changed to Vulkan except for Dolphin - AngelofWoe
- Xbox Parser turned on by default on SRM - Godsbane
- Added PS1 Beetle PSX RA Core on SRM (disabled by default) - Godsbane
- Added DOSBOX to SRM - AngelofWoe
- FIX 3DS parser on SRM, Remove CIA / Add CCI - Godsbane
- Updated Xemu toml config file - Godsbane
- RPCS3 Installed games moved to /Emulation/saves/rpcs3 - Godsbane
- Added PS3 PKG games on SRM - Godsbane
- Fixed Emulators flatpak permission to access their roms folder when not using SRM or ESDE - Godsbane
- Fixed Emulator launchers, only created for the ones the user chooses to install - Godsbane
- Get ESDE latest version from Dynamic url - Godsbane
- CHD script improvements - Godsbane
- Fix PCSX2 Save/Load state mappings - LBRapid

  0.17.3

- New ESDE Epic Noir Theme set as default & Theme Selector
- Ability to launch WiiU Games from ESDE
- Cemu Script added to installers. Adding WiiU games to SRM no longer requires proton to be set, it just works TM!
- Widescreen Hacks for PS2 Games - Only US
- Widescreen for 70 Wii and GC games - SkyHighBrownie
- Added log files for Community Dolphin ini hacks. Send us your own!
- Added new ExpertMode feature - SteamGyroDSU. (requires sudo)
- Added logging to CHDman script so you can check what it did after the run.
- Added paths to Yuzu for roms directory.
- Added paths to Citra for roms directory.
- Added paths to Primehack for roms directory.
- Added permissions for PCSX2 to do netplay.
- Added permissions for Xemu to write to its hdd if it's internal.
- Added default paths for Cemu to mlc01
- Added default paths for Cemu to roms folder. When you launch cemu with proton, you may need to refresh the games list manually for them to show up.
- Set new default emulators for ES-DE to be more in line with the ones we set for SRM and set preparations for future ESDE updates
-     New emulation station defaults:
           'Genesis Plus GX' gamegear
           'Gambatte' gb
           'Gambatte' gbc
           'Dolphin (Standalone)' gc
           'PPSSPP (Standalone)' psp
           'Dolphin (Standalone)' wii
           'Mesen' nes
           'DOSBox-Pure' dos
           'PCSX2 (Standalone)' ps2
           'melonDS' nds
- Update RPCS3 config with new version, as its config had changed
- Update PowerTools to version 4.1 ( Expert mode ). SMT Toggle is in. Be aware that this may crash MangoHud(stats) if enabled, but it won't hurt anything. MangoHud will come back on reboot.
- Fixed SRM Parser for Installed PS3 games for internal users.
- Expert mode will ask about Bezels and Autosave again
- Dolphin set as 16:9 by default on easy mode
- Fix Sega Genesis missing extension and adds Commodore 64
- Add support for holoISO

  0.17.4

- New user interface on install both on Easy and Expert modes
- Rom folder creation will respect user's custom symlinks
- When you first install EmuDeck an you Launch SteamRomManager we will get you back to GamingMode when closing SteamRomManager
- SRM is now located on Emulation/tools and will close Steam automatically for you.
- Fixed RPCS3 Controller not working on new install
- Updated Mupen64Plus-Next defaults for N64. Should be much better now. more accurate, faster, and look better.
- New tool added - proton-launch.sh (for all your non-steam windows app shenanigans, courtesy of Angel)
- Citra left trackpad used now as mouse instead of D-pad on our SteamInput template
- Fix Citra non exiting while pressing R5
- PPSSPP Audio Fix when the Deck goes into Sleep Mode
- Fixed 3ds bad symlink for older installations
- PrimeHack Controller tweaks and performance gain
- Fix PCSX2 Turbo Mode
- Wii nkit.gcz support
- FBNeo fixes on SteamRomManager
- SD card is only available if one is inserted, writable, and supports symlinks
- Expert mode - Fixes RA Autosave selection
- Expert mode - Changed Cemu default controller to gamepad with gyro (gyro requires SteamDeckGyroDSU installation. See Expert mode for more details)
- Expert mode - You can now chose a custom install location. It will be tested for the ability to both write and link, and rejected if either fail.

0.17.5

- EmuDeck internal fixes and modularity.. setting it up for great things on the future...
- New - Steam Input Template for DuckStation with left trackpad Touch Menu (Thanks Moskeeto)
- New - Yuzu AppImage ( Seemingly better performance than the one in discover store, also right click to open menus work! )  
   It is VERY important you let Emudeck run the updates on Yuzu so the
  data migration can happen seamlessly. You will be notified if we find data in the default appimage location
  and can choose to keep and migrate the old Flatpak data, or you can use the existing AppImage data you have.  
   The chosen data will be migrated to the AppImage location, and linked back to the flatpak data location.  
   Steam ROM Manager users will need to re-parse for Yuzu games to use the new AppImage.  
   The Flatpak installation is NOT removed, but must be for EmulationStation-DE to use the AppImage instead.
- New - Storage folder to keep Xemu, Yuzu, and RPCS3 data in the Emulation folder. Migration will happen at the start.
  You may need to re-parse for rpcs3 installed files.
- New - Binary Updater tool added. Ths new tool can update EmulationStation-DE, SteamRomManager, Cemu, Yuzu, or Xenia
  to their latest versions without going through the EmuDeck install process.
- New - CHD Script now handles wii / gc iso --> rvz conversion
- New - Citra now has the microphone mapped for games that need it.
- New - Citra now has the gyro mapped for those that need it. (requires SteamDeckGyroDSU)
- New - Citra has load textures and precache on by default. (for users who want custom texture packs)
- New - Added a few properly labeled WiiMote profiles for dolphin
- New - Wiimote 2,3,4 are mapped to steaminput devices 2,3,4 - but not connected by default to avoid phantom cursors
- New - Auto download xbox hdd from xemu site on xemu install if it doesn't exist. User only needs to provide files in bios after this.
- New - Dolphin load textures and precache is now on by default. (for users who want custom texture packs)
- New - Dolphin Auto Change disc is now on by default.
- New - Dolphin cursor is now hidden by default.
- New - PCSX2 vsync is now on by default
- New - DuckStation rom path added. New hotkeys added to coincide with Steam Input Template. Changed quickMenu to Esc. (Steam + Dpad Left)
- Fix - Citra Steam Input. R5 only closes Citra after a long a press
- Fix - Cemu is now at 100% volume instead of 50% volume by default for new installs
- Fix - Dolphin pointer is now right trackpad and the joystick and works more smoothly.  
   If you have SteamGyro setup, there is are extra Wiimote profiles included that can use it.  
   _You may need to set the controller to Default Gamepad With Mouse Trackpad if steam decided to use Touchpad as Joystick instead._
- Fix - Widescreen Hacks are now off by default for all emulators. They can be enabled by running in Expert Mode and choosing to customize Widescreen.
- Fix - PCSX2 Steam Input profile updated so it wont pause on RT. (Thanks Wintermute)
- Fix - Updates won't wipe out EmulationStation-DE custom systems and EmulationStation-DE metadata info anymore.
- Fix - Updates won't wipe out Cemu graphics pack settings anymore.
- Fix - EmulationStation-DE's hidden downloaded_media wouldn't get moved
  to the Emulation/tools directory if the setting existed but was blank.
- Fix - Expert Mode: Widescreen Hacks Selection.
- Fix - Expert Mode: Emulator install Selection.
- Fix - Expert Mode: Emulator reconfiguration selection.
- Fix - Expert Mode: Entering a password wrong in the pop up will make it re-pop.
  You have 2 chances and then it will disable the Expert mode settings that require a password.
- Fix - Citra is now 2x instead of 3x res by default for performance reasons
- Fix - Dolphin hotkey for Fast Forward has been updated from just Select to Select + R2 to match the other hotkeys

0.17.6

- Added 16:9 bezel support for holoISO and Anbernic Win600 (or other 16:9 devices)
- Icon renamed to Update EmuDeck to avoid confusion
- Fixed Atari Bezels. Added bezels to Dreamcast, N64 and Saturn
- Fixed Dolphin and Primehack from sending button presses as part of hotkeys as in-game button presses
- Added Naomi (flycast) parser for Steam ROM Manager. Uses roms/naomi folder
- Fixed retroachievements not working for users with certain special characters in their passwords.
- Added easyRPG core to RA. Required additional files are not yet downloaded. You can add them manually.
- Added PCSX2-Qt AppImage and Steam ROM Manager Parser. This can live side by side with your existing pcsx2, but it should be removed.
- Migrate pcsx2 saves files to the Emulation folder. This is no longer a link.
- Both versions of Pcsx2 use the same saves location in their config so no matter which, you can save / load state.
- Expert mode settings are remembered.
    If you run expert mode, and change a setting it will be retained and used on the next run of easy mode. (except install / reconfigure)
- RetroArch settings will be backed up before update. Settings files for this are no longer replaced. The options are updated or appended.
- Installing PluginLoader (powertools) now activates dev mode and installs the new version of the loader and plugin. Reboot may be required
- CHD script Renamed to Emudeck Compression Tool. New support for Wii games to convert them to rvz format
- ... too much more to fit here!