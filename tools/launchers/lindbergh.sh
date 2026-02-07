#!/bin/bash
# Lindbergh Loader launcher for EmuDeck
# Lindbergh games must be launched from their own directory
# as lindbergh-loader reads lindbergh.ini relative to CWD

source "$HOME/.config/EmuDeck/backend/functions/all.sh"

emulatorInit "lindbergh"

# Get the game directory and executable name
GAME_PATH="$1"
GAME_DIR="$(dirname "$GAME_PATH")"
GAME_ELF="$(basename "$GAME_PATH")"

# Change to game directory (required for lindbergh-loader)
cd "$GAME_DIR" || exit 1

# Run the game via Flatpak
/usr/bin/flatpak run com.github.lindberghloader "./$GAME_ELF"

# Sync saves after exit
cloud_sync_uploadForced
