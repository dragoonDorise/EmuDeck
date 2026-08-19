#!/bin/bash

function logToFrontend(){
	local payload="$1"
	{ exec 3<>/dev/tcp/127.0.0.1/"${EMUDECK_BACKEND_PORT:-8099}"; } 2>/dev/null || return 1
	printf '%s\n' "$payload" 2>/dev/null >&3
	exec 3>&- 2>/dev/null
	return 0
} #OK

function checkSpace(){
	local origin="$1" destination="$2" label="$3"
	local neededSpace freeSpace

	logToFrontend "$(jq -nc --arg key "importExport.calculatingSize" --arg item "$label" '{key:$key,params:{item:$item},percentage:0,finished:false}')"

	neededSpace=$(du -s "$origin" 2>/dev/null | awk '{print $1}')
	freeSpace=$(df -k "$destination" --output=avail 2>/dev/null | tail -1 | tr -d ' ')

	if [ "$freeSpace" -lt "$neededSpace" ]; then
		logToFrontend "$(jq -nc --arg key "importExport.noSpace" --arg item "$label" --arg destination "$destination" '{key:$key,params:{item:$item,destination:$destination},percentage:100,finished:false}')"
		return 1
	fi

	return 0
} #OK

function get_external_drives(){
	local dir user
	user="${USER:-$(id -un)}"

	for dir in "/run/media/$user"/* /run/media/* "/media/$user"/* /media/* /mnt/*; do
		[ -d "$dir" ] || continue
		#mountpoint -q "$dir" || continue
		printf '%s\n' "$dir"
	done | sort -u
} #OK

function get_locations(){
	local mount source label removable name type
	local -a entries=()

	while read -r mount; do
		source=$(findmnt -no SOURCE "$mount" 2>/dev/null | head -n1)
		label=$(lsblk -no LABEL "$source" 2>/dev/null | head -n1)
		removable=$(lsblk -no RM "$source" 2>/dev/null | head -n1 | tr -d ' ')

		label="${label#"${label%%[![:space:]]*}"}"
		label="${label%"${label##*[![:space:]]}"}"
		[ -z "$label" ] && label="No label"

		case "$source" in
			*mmcblk*) name="SD Card"; type="External" ;;
			*)
				name="$label"
				if [ "$removable" = "1" ]; then
					type="External"
				else
					type="Internal"
				fi
				;;
		esac

		entries+=("$(jq -nc \
			--arg letter "$mount" \
			--arg name "$name" \
			--arg label "$label" \
			--arg type "$type" \
			'{letter:$letter,name:$name,label:$label,type:$type}')")
	done < <(get_external_drives)

	if [ "${#entries[@]}" -eq 0 ]; then
		entries+=("$(jq -nc \
		--arg letter "$HOME" \
		--arg name "User folder" \
		--arg label "User folder" \
		--arg type "Internal" \
		'{letter:$letter,name:$name,label:$label,type:$type}')")
		
		printf '%s\n' "${entries[@]}" | jq -sc '.'
		return 0
	fi

	printf '%s\n' "${entries[@]}" | jq -sc '.'
	return 0
} #OK

function rsync_progress(){
	local action="$1"
	local item="$2"
	local origin="$3"
	local destination="$4"
	local rsyncParams="$5"
	local status

	mkdir -p "$destination"

	logToFrontend "$(jq -nc --arg key "importExport.$action" --arg item "$item" '{key:$key,params:{item:$item},percentage:0,finished:false}')"

	rsync -a -m --info=progress2 --no-inc-recursive $rsyncParams "$origin" "$destination" | tr '\r' '\n' | {
		last="0"
		while read -r line; do
			# case "$line" in
			# 	*%*) ;;
			# 	*) continue ;;
			# esac
			#We get the percentage from rsync output 
			percent="${line%%%*}"
			percent="${percent##* }"
			# case "$percent" in
			# 	''|*[!0-9]*) continue ;;
			# esac
			#We only send new percetages to the frontend, avoiding duplicates
			[ "$percent" = "$last" ] && continue
			last="$percent"
			logToFrontend "$(jq -nc --arg key "importExport.$action" --arg item "$item" --argjson percentage "$percent" '{key:$key,params:{item:$item},percentage:$percentage,finished:false}')"
		done
	}
	status=${PIPESTATUS[0]}

	if [ "$status" -ne 0 ]; then
		logToFrontend "$(jq -nc --arg key "importExport.failed" --arg item "$item" --argjson code "$status" '{key:$key,params:{item:$item,code:$code},percentage:100,finished:false}')"
		sleep 1
		return "$status"
	fi

	logToFrontend "$(jq -nc --arg key "importExport.$action" --arg item "$item" '{key:$key,params:{item:$item},percentage:100,finished:false}')"
	return 0
} #OK

function import_emudeck(){
	local items="$1"
	local origin="$2"
	local item root selected failed=0
	local -a failedItems=()

	if [ -z "$origin" ] || [ ! -d "$origin" ]; then
		logToFrontend "$(jq -nc --arg key "importExport.invalidOrigin" --arg path "$origin" '{key:$key,params:{path:$path},percentage:100,finished:true}')"
		return 1
	fi

	root="$origin/EmuDeckBackup"
	selected=$(printf '%s' "$items" | jq -r 'to_entries[] | select(.value == true) | .key | ascii_downcase' 2>/dev/null)

	if [ -z "$selected" ]; then
		logToFrontend "$(jq -nc --arg key "importExport.nothingSelectedImport" '{key:$key,params:{},percentage:100,finished:true}')"
		return 0
	fi

	while read -r item; do
		case "$item" in
			saves)
				checkSpace "$root/saves" "$emulationPath" "saves" || { failed=1; failedItems+=("saves"); continue; }
				rsync_progress "importing" "saves" "$root/saves/" "$emulationPath/saves/" || { failed=1; failedItems+=("saves"); }
				;;
			storage)
				checkSpace "$root/storage" "$emulationPath" "storage" || { failed=1; failedItems+=("storage"); continue; }
				rsync_progress "importing" "storage" "$root/storage/" "$emulationPath/storage/" || { failed=1; failedItems+=("storage"); }
				;;
			esdeartwork|esdemedia|"es-de media")
				checkSpace "$root/tools/downloaded_media" "$emulationPath" "esdeArtwork" || { failed=1; failedItems+=("esdeArtwork"); continue; }
				rsync_progress "importing" "esdeArtwork" "$root/tools/downloaded_media/" "$ESDEscrapData/" || { failed=1; failedItems+=("esdeArtwork"); }
				;;
			bios)
				checkSpace "$root/bios" "$emulationPath" "bios" || { failed=1; failedItems+=("bios"); continue; }
				rsync_progress "importing" "bios" "$root/bios/" "$emulationPath/bios/" || { failed=1; failedItems+=("bios"); }
				;;
			roms)
				checkSpace "$root/roms" "$emulationPath" "roms" || { failed=1; failedItems+=("roms"); continue; }
				rsync_progress "importing" "roms" "$root/roms/" "$emulationPath/roms/" "--exclude=*.txt" || { failed=1; failedItems+=("roms"); }
				;;
		esac
	done <<< "$selected"

	if [ "$failed" -eq 0 ]; then
		logToFrontend "$(jq -nc --arg key "importExport.importFinished" '{key:$key,params:{},percentage:100,finished:true}')"
	else
		logToFrontend "$(jq -nc --arg key "importExport.importFinishedWithErrors" --args '{key:$key,params:{items:$ARGS.positional},percentage:100,finished:true}' "${failedItems[@]}")"
	fi

	return "$failed"
} #OK

function export_emudeck(){
	local items="$1"
	local destination="$2"
	local item root selected failed=0
	local -a failedItems=()

	if [ -z "$destination" ] || [ ! -d "$destination" ]; then
		logToFrontend "$(jq -nc --arg key "importExport.invalidDestination" --arg path "$destination" '{key:$key,params:{path:$path},percentage:100,finished:true}')"
		return 1
	fi

	root="$destination/EmuDeckBackup"
	selected=$(printf '%s' "$items" | jq -r 'to_entries[] | select(.value == true) | .key | ascii_downcase' 2>/dev/null)

	if [ -z "$selected" ]; then
		logToFrontend "$(jq -nc --arg key "importExport.nothingSelectedExport" '{key:$key,params:{},percentage:100,finished:true}')"
		return 0
	fi

	while read -r item; do
		case "$item" in
			saves)
				checkSpace "$emulationPath/saves" "$destination" "saves" || { failed=1; failedItems+=("saves"); continue; }
				rsync_progress "exporting" "saves" "$emulationPath/saves/" "$root/saves/" "-L" || { failed=1; failedItems+=("saves"); }
				;;
			storage)
				checkSpace "$emulationPath/storage" "$destination" "storage" || { failed=1; failedItems+=("storage"); continue; }
				rsync_progress "exporting" "storage" "$emulationPath/storage/" "$root/storage/" "-L" || { failed=1; failedItems+=("storage"); }
				;;
			esdeartwork|esdemedia|"es-de media")
				checkSpace "$ESDEscrapData" "$destination" "esdeArtwork" || { failed=1; failedItems+=("esdeArtwork"); continue; }
				rsync_progress "exporting" "esdeArtwork" "$ESDEscrapData/" "$root/tools/downloaded_media/" "-L" || { failed=1; failedItems+=("esdeArtwork"); }
				;;
			bios)
				checkSpace "$emulationPath/bios" "$destination" "bios" || { failed=1; failedItems+=("bios"); continue; }
				rsync_progress "exporting" "bios" "$emulationPath/bios/" "$root/bios/" "-L" || { failed=1; failedItems+=("bios"); }
				;;
			roms)
				checkSpace "$emulationPath/roms" "$destination" "roms" || { failed=1; failedItems+=("roms"); continue; }
				rsync_progress "exporting" "roms" "$emulationPath/roms/" "$root/roms/" "-L --exclude=*.txt" || { failed=1; failedItems+=("roms"); }
				;;
		esac
	done <<< "$selected"

	if [ "$failed" -eq 0 ]; then
		logToFrontend "$(jq -nc --arg key "importExport.exportFinished" '{key:$key,params:{},percentage:100,finished:true}')"
	else
		logToFrontend "$(jq -nc --arg key "importExport.exportFinishedWithErrors" --args '{key:$key,params:{items:$ARGS.positional},percentage:100,finished:true}' "${failedItems[@]}")"
	fi

	return "$failed"
} #OK
