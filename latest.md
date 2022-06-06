0.17.5
- EmuDeck internal fixes and modularity.. setting it up for great things on the future...
- New - Steam Input Template for DuckStation
- New - Yuzu appImage ( better performance than the one in discover store )
        It is VERY important you let Emudeck run the updates on Yuzu so the 
        data migration can happen seamlessly. You will be notified if we 
        find data in the default appimage location and can choose to keep 
        and migrate the old Flatpak data, or you can use the existing AppImage data you have.
        Steam Rom Manager users will need to re-parse for Yuzu to use the new AppImage.
- New - Storage folder to keep Xemu, Yuzu, and RPCS3 data in the Emulation folder

- Fix - DuckStation rom path added.
- Fix - Widescreen Hacks are now off by default. 
- Fix - PCSX2 Steam Input profile updated so it wont pause on RT. (Thanks Wintermute)
- Fix - Updates won't wipe out EmulationStation-DE custom systems.
- Fix - Updates won't wipe out EmulationStation-DE scrapes.
- Fix - EmulationStation-DE's hidden downloaded_media wouldn't get moved 
        to the Emulation/tools directory if the setting existed but was blank.
- Fix - Expert Mode: Widescreen Hacks Selection.
- Fix - Expert Mode: Emulator install Selection.
- Fix - Expert Mode: Emulator reconfiguration selection.