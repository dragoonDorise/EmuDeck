0.17.5

- New - Steam Input Template for DuckStation with left trackpad Touchinput (Thanks Moskeeto)
- New - Yuzu AppImage ( Seemingly better performance than the one in discover store, also right click to open menus work! )
  It is VERY important you let Emudeck run the updates on Yuzu so the
  data migration can happen seamlessly. You will be notified if we find data in the default appimage location
  and can choose to keep and migrate the old Flatpak data, or you can use the existing AppImage data you have.
  The chosen data will be migrated to the AppImage location, and linked back to the flatpak data location.
  Steam Rom Manager users will need to re-parse for Yuzu games to use the new AppImage.
  The Flatpak installation is NOT removed, but must be for EmulationStation-DE to use the AppImage instead.
- New - Storage folder to keep Xemu, Yuzu, and RPCS3 data in the Emulation folder. Migration will happen at the start.
  You may need to re-parse for rpcs3 installed files.
- New - Binary Updater tool added. Ths new tool can update EmulationStation-DE, SteamRomManager, Cemu, Yuzu, or Xenia
  to their latest versions without going through the EmuDeck install process.
- New - CHD Script now handles wii / gc iso --> rvz conversion
- Fix - Dolphin pointer is now right trackpad and works more smoothly. If you have SteamGyro setup, motion now works.
  \*You may need to set the controller to Default Gamepad With Mouse Trackpad if steam decided to use Touchpad as Joystick instead.
- Fix - DuckStation rom path added. New hotkeys added to coincide with Steam Input Template. Changed quickMenu to Esc. (Steam + Dpad Left)
- Fix - Widescreen Hacks are now off by default for all emulators. They can be enabled by running in Expert Mode.
- Fix - PCSX2 Steam Input profile updated so it wont pause on RT. (Thanks Wintermute)
- Fix - Citra Steam Input. R5 only closes Citra after a long a press
- Fix - Updates won't wipe out EmulationStation-DE custom systems and EmulationStation-DE metadata info anymore.
- Fix - Updates won't wipe out Cemu graphics pack settings anymore.
- Fix - EmulationStation-DE's hidden downloaded_media wouldn't get moved
  to the Emulation/tools directory if the setting existed but was blank.
- Fix - Expert Mode: Widescreen Hacks Selection.
- Fix - Expert Mode: Emulator install Selection & reconfiguration selection.
- Fix - Expert Mode: Entering a password wrong in the pop up will make it re-pop.
  You have 2 chances and then it will disable the Expert mode settings that require a password.
