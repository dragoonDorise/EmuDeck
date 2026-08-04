#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
source "$romsPath/cloud/cloud.conf"

LINK="https://www.youtube.com/"

# Allow opening YouTube TV with a --tv flag
# You will need to make sure your browser is set up to open YouTube in TV UI.
# This can be done in browsers like Firefox by setting a custom user agent or
# installing 3P browser extensions.
for arg in "$@"; do
	case "$arg" in
		--tv)
			LINK="https://www.youtube.com/tv/"
			;;
	esac
done

browsercommand