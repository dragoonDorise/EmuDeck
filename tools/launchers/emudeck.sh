#!/usr/bin/env bash
# Native Wayland breaks EmuDeck's frameless window with fractional scaling, run it through XWayland
args=()
if [ "$XDG_SESSION_TYPE" = "wayland" ] || [ -n "$WAYLAND_DISPLAY" ]; then
	args+=(--ozone-platform=x11)
fi
exec "$HOME/Applications/EmuDeck.AppImage" "${args[@]}" "$@"
