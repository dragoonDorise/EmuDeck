0.17.4
- EmuDeck WE beta ( Windows Edition )
- Auto close of Steam Desktop when opening SRM, and auto going back to SteamUI on closing SRM but only when launched from EmuDeck
- Fixed RPCS3 Controller not working on new install
- Changed Cemu default controller to gamepad with gyro (gyro requires SteamDeckGyroDSU installation. See Expert mode for more details)
- updated Mupen64Plus-Next defaults for N64. Should be much better now. more accurate, faster, and look better.
- new tool added - proton-launch.sh (for all your non-steam windows app shenanigans, courtesy of Angel) 
- Citra left trackpad as mouse instead of D-pad
redid the menu system:
General Changes:
   - SD card is only available if one is inserted, writable, and supports symlinks
   - If the user does not have an SD Card, and chooses easy mode, it will skip location choice and install to ~/
   - If the user has installed EmuDeck before, we won't write the roms folders over their existing ones anymore.
   - logging is more verbose.

Expert Mode Changes:
   - Expert mode now has a list of changes intead of a series of questions.
   - Expert mode now has a custom install location available. It will be tested for the ability to both write and link, and 
      rejected if either fail.
   - Now has option to clobber roms folders even if you have already run it before.
