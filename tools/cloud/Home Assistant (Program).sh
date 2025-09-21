#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
source "$romsPath/cloud/cloud.conf"

# To use your own instance of Home Assistant, export the HOMEASSISTANT_LINK variable in your .bashrc
LINK="${HOMEASSISTANT_LINK:-https://demo.home-assistant.io/}"

browsercommand
