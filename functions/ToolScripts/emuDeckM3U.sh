#!/bin/bash
#based in https://gist.github.com/ibackz/b959df705ed071852146510714f970d7

EmuDeckM3U(){
	local system=$1
	# A variable to store all M3U files to be created
	declare -A m3u_files

	# Iterate through all directories in the current location
	for dir in $romsPath/$system; do
		  # Skip if not a directory
		  [ -d "$dir" ] || continue

		  # Change into the directory
		  cd "$dir"

		  # Iterate through all files in the directory
		  for file in *; do
			# Check if the file contains the pattern '(Disc {digit})', skip if not
			if [[ ! $file =~ \(Disc\ [0-9]+\).* ]]; then
			  continue
			fi

			# Extract the base filename by removing everything from the pattern '(Disc {digit})' onward
			base_name="${file%% (Disc [0-9]*).*}"

			# Skip if the M3U file already exists
			if [ -f "$base_name.m3u" ]; then
			  continue
			fi

			# Append the file to the list associated with its base name
			m3u_files["$base_name"]+="$base_name/$file"$'\n'

		  done

		  # Change back to the parent directory
		  cd ..
	done

	# Check if there are any M3U files to be created
	if [ ${#m3u_files[@]} -eq 0 ]; then
	  text="$(printf "<b>No M3U files to be created.</b>\nMake sure your files are named\n<b>Game (Disc X)</b> with no spaces in (Disc X)")"
	   zenity --error \
		   --title="EmuDeck M3U tool" \
		   --width=250 \
		   --ok-label="Bye" \
		   --text="${text}" 2>/dev/null
		exit
	fi

	# List all M3U files to be created

	concatenated=""
	for base_name in "${!m3u_files[@]}"; do
	  concatenated+="$base_name.m3u "
	done
	concatenated="${concatenated% }"

	# Provide a rough estimate for time needed
	#echo "Estimated time to complete: ${#m3u_files[@]} seconds."

	# Ask the user for confirmation
	text="$(printf "Lists to be created: $concatenated")"
	zenity --question \
		--title="Would you like to create the playlists?" \
		--width=450 \
		--cancel-label="Exit" \
		--ok-label="Continue" \
		--text="${text}" 2>/dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		echo "Continue..."
	else
		exit
	fi

	for dir in $romsPath/$system; do
	  # Skip if not a directory
	  [ -d "$dir" ] || continue

	  # Change into the directory
	  cd "$dir"

	  # Iterate through all files in the directory
	  for file in *; do
		# Check if the file contains the pattern '(Disc {digit})', skip if not
		if [[ ! $file =~ \(Disc\ [0-9]+\).* ]]; then
		  continue
		fi

		# Extract the base filename by removing everything from the pattern '(Disc {digit})' onward
		base_name="${file%% (Disc [0-9]*).*}"

		#We move the files in its own subfolders
		mkdir -p $base_name
		mv "$file" "$base_name/$file"
	  done

	  # Change back to the parent directory
	  cd ..
	done


	# Iterate through the base filenames and create .m3u files for each
	for dir in */; do
	  # Skip if not a directory
	  [ -d "$dir" ] || continue

	  # Change into the directory
	  cd "$dir"

	  for base_name in "${!m3u_files[@]}"; do
		# Get the files for this base name
		files="${m3u_files["$base_name"]}"

		# Define the M3U file path
		m3u_file="$base_name.m3u"

		# Create an .m3u file
		echo -e "$files" > "$m3u_file"

		echo "Created $m3u_file"

	  done

	  # Change back to the parent directory
	  cd ..

	done

	  zenity --info \
	  --text="Lists created, old files moved to new subfolders" \
	  --title="EmuDeck M3U Tool" \
	  --width=400 \
	  --height=300

	# Close the window (this might be OS-dependent)
	exit
}