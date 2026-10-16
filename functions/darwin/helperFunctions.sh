#!/usr/bin/env bash

changeLine(){
	local KEYWORD=$1
	local REPLACE=$2
	local FILE=$3
	local tmp
	tmp=$(mktemp)
	K="$KEYWORD" R="$REPLACE" awk 'index($0, ENVIRON["K"]) == 1 { print ENVIRON["R"]; next } { print }' "$FILE" > "$tmp" && cat "$tmp" > "$FILE"
	rm -f "$tmp"
}

setSetting(){
	local var=$1
	local new_val=$2
	if grep -q "^$var=" "$emuDecksettingsFile"; then
		changeLine "$var=" "$var=$new_val" "$emuDecksettingsFile"
	else
		echo "$var=$new_val" >> "$emuDecksettingsFile"
	fi
	# shellcheck source=settings.sh
	source "$emuDecksettingsFile"
}
