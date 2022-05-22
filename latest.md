0.17.4
- EmuDeck WE beta ( Windows Edition )
- Rom folder creation will respect user's custom symlinks
- When you first install EmuDeck an you Launch SteamRomManager we will get you back to GamingMode when closing SteamRomManager
- SRM is now located on Emulation/tools and will close Steam automatically for you.
- Fixed RPCS3 Controller not working on new install
- Changed Cemu default controller to gamepad with gyro (gyro requires SteamDeckGyroDSU installation. See Expert mode for more details)
- Updated Mupen64Plus-Next defaults for N64. Should be much better now. more accurate, faster, and look better.
- New tool added - proton-launch.sh (for all your non-steam windows app shenanigans, courtesy of Angel) 
- Citra left trackpad used now as mouse instead of D-pad on our SteamInput template
- Fix Citra non exiting while pressing R5
- PPSSPP Audio Fix when the Deck goes into Sleep Mode
- Fixed 3ds bad symlink for older installations
SD Card detection fixes:
General Changes:
   - SD card is only available if one is inserted, writable, and supports symlinks
   - If the user does not have an SD Card, and chooses easy mode, it will skip location choice and install directly to ~/
   - New user interface

Expert Mode Changes:
   - New preselection screen where you can chose what do you want to customize.
   - You can now chose a custom install location. It will be tested for the ability to both write and link, and 
      rejected if either fail.
