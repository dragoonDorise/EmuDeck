#!/bin/sh
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
{
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
BLINK='\x1b[5m'

. "$HOME/.config/EmuDeck/backend/tools/scrapers/retroarch.sh"
. "$HOME/.config/EmuDeck/backend/tools/scrapers/screenscraper.sh"

romParser_RA_start
#romParser_LB_start
if [ -f "$HOME/emudeck/.userSS" ]; then
	romParser_SS_start
fi
} | tee "$HOME/emudeck/logs/parser.log" 2>&1