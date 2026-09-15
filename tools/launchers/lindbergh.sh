#!/bin/bash
# Lindbergh Loader launcher for EmuDeck
# Lindbergh games must be launched from their own directory
# as lindbergh-loader reads lindbergh.ini relative to CWD

emudeckBackend="$HOME/.config/EmuDeck/backend/"
source "$emudeckBackend/functions/all.sh"

emulatorInit "lindbergh"

# Get the game directory and executable name
GAME_PATH="$1"
GAME_DIR="$(dirname "$GAME_PATH")"
GAME_ELF="$(basename "$GAME_PATH")"

# Change to game directory (required for lindbergh-loader)
cd "$GAME_DIR" || exit 1

# Check if AppImage exists, otherwise use Flatpak
	APPIMAGE_PATH=$(ls ~/Applications/Lindbergh*.AppImage 2>/dev/null | head -n 1)
	if [[ -z "$APPIMAGE_PATH" ]]; then
		APPIMAGE_PATH=$(ls ~/AppImages/lindbergh*.appimage 2>/dev/null | head -n 1)
	fi
	if [[ -n "$APPIMAGE_PATH" && -x "$APPIMAGE_PATH" ]]; then
		# Use AppImage
		"$APPIMAGE_PATH" "./$GAME_ELF"
	else
		# Use Flatpak
		/usr/bin/flatpak run com.github.lindberghloader "./$GAME_ELF"
	fi

# Sync saves after exit
cloud_sync_uploadForced
