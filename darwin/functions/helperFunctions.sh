#!/bin/bash
#We set the proper sed
PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

darwin_installEmuDMG(){
	local name="$1"
	local url="$2"
	local altName="$3"
	local showProgress="$4"
	local lastVerFile="$5"
	local latestVer="$6"	
	if [[ "$altName" == "" ]]; then
		altName="$name"
	fi
	echo "$name"
	echo "$url"
	echo "$altName"
	echo "$showProgress"
	echo "$lastVerFile"
	echo "$latestVer"

	
	if safeDownload "$name" "$url" "$HOME/Applications/$altName.dmg" "$showProgress"; then
		chmod +x "$HOME/Applications/$altName.dmg"
		if [[ -n $lastVerFile ]] && [[ -n $latestVer ]]; then
			echo "latest version $latestVer > $lastVerFile"
			echo "$latestVer" > "$lastVerFile"
		fi
	else
		return 1
	fi


		shName=$(echo "$name" | awk '{print tolower($0)}')
		find "${toolsPath}/launchers/" -maxdepth 1 -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | \
		while read -r f
		do
			echo "deleting $f"
			rm -f "$f"
		done
	
		find "${EMUDECKGIT}/darwin/tools/launchers/" -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | \
		while read -r l
		do
			echo "deploying $l"
			launcherFileName=$(basename "$l")
			chmod +x "$l"
			cp -v "$l" "${toolsPath}/launchers/"
			chmod +x "${toolsPath}/launchers/"*
		done
	 
}

safeDownload() {
	local name="$1"
	local url="$2"
	local outFile="$3"
	local showProgress="$4"
	local headers="$5"
	if [ "$showProgress" == "true" ]; then
		echo "safeDownload()"
		echo "- $name"
		echo "- $url"
		echo "- $outFile"
		echo "- $showProgress"
		echo "- $headers"
	fi
	
	if [ $system == "darwin" ]; then
		request=$(curl -w $'\1'"%{response_code}" --fail -L "$url" -H "$headers" -o "$outFile.temp" 2>&1 && echo $'\2'0 || echo $'\2'$?)
	else
		if [ "$showProgress" == "true" ] || [[ $showProgress -eq 1 ]]; then
			request=$(curl -w $'\1'"%{response_code}" --fail -L "$url" -H "$headers" -o "$outFile.temp" 2>&1 | tee >(stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading $name" --width 600 --auto-close --no-cancel 2>/dev/null) && echo $'\2'${PIPESTATUS[0]})
		else
			request=$(curl -w $'\1'"%{response_code}" --fail -L "$url" -H "$headers" -o "$outFile.temp" 2>&1 && echo $'\2'0 || echo $'\2'$?)
		fi
	fi
	
	returnCodes="${request#*$'\1'}"
	httpCode="${returnCodes%$'\2'*}"
	exitCode="${returnCodes#*$'\2'}"
	if [ "$showProgress" == "true" ]; then
		requestInfo=$(sed -z s/.$// <<< "${request%$'\1'*}")
		echo "$requestInfo"
		echo "HTTP response code: $httpCode"
		echo "CURL exit code: $exitCode"
	fi
	echo $outFile;
	echo $httpCode;
	echo $exitCode;
	
	if [ "$httpCode" = "200" ] && [ "$exitCode" == "0" ]; then
		#echo "$name downloaded successfully";
		mv -v "$outFile.temp" "$outFile" &>/dev/null
		volumeName=$(hdiutil attach "$outFile" | grep -o '/Volumes/.*$')
		
		cp -r "$volumeName"/*.app "$HOME/Applications" && hdiutil detach "$volumeName" && rm -rf $outFile
		
		return 0
	else
		#echo "$name download failed"
		rm -f "$outFile.temp"
		return 1
	fi

}