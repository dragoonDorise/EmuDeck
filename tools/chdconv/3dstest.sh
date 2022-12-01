#!/bin/bash

find "/home/griffin/Downloads/" -type f -iname "*.3ds" ! -name '*.trimmed*' | while read -r f; do
	# Keep a log of all trimmed files to avoid re-trimming
	# if find . ! -name '*.trimmed*'; then
		echo "Converting: $f"
		# 3dstool modifies files, doesn't replace
		/home/griffin/Projects/EmuDeck/tools/chdconv/3dstool -r -f "$f" && mv "$f" "${f%%.*}.trimmed.3ds"
		# Append filename of trimmed roms to list
		# echo "$f">> "3ds-trimmed.log"
	# else
	# 	echo "$f already trimmed, skipping..."
	# fi
done