0.17.6

- Added Anbernic Win600 support
- Added 16:9 bezel support for holoISO users
- Icon renamed to Update EmuDeck to avoid confusion
- Fixed Atari Bezels
- Added bezels to Dreamcast, N64 and Saturn
- Fixed Dolphin and Primehack from sending button presses as part of hotkeys as in-game button presses
- CHDDeck now finds and removes files from gdi and cue
- Added Naomi (flycast) parser for Steam Rom Manager. uses roms/naomi folder
- fixed retroachievements not working for users with certain special characters in their passwords.
- added easyRPG core to RA. Required additinal files.
- added PCSX2-Qt AppImage
- added new parser for the pcsx2-Qt AppImage. This can live side by side with your existing pcsx2.
- migrate pcsx2 saves files to the Emulation folder. This is no longer a link.
- both versions of Pcsx2 use the same saves location in their config.

- The script now has functions for many options. Will be exposing many of these in the UI later.
- Expert mode settings are remembered.
        If you run expert mode, and change a setting it will be retained and used on the next run of easy mode.

- RetroArch settings will be backedup before update. Settings files for this are no longer replaced. The options are updated or appended.
- Installing PluginLoader (powertools) now installs the new version of the loader and plugin. 
    cef_debugging/dev mode is now applied for you, but a reboot may be required for it to become active.
- CHD script is installed and updated by default now. Renamed to Emudeck Compression Tool.
    Now handles dolphin / wii folders and compresses to rzv as well.
    Properly handles cue / gdi parsing and bin removal
- Expert mode selections to retain settings should now be respected... finally
    As a warning, using this will stop you from recieving the updates we bundle for that specific emu. 
- Expert mode selections to install emulators now work.