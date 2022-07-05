#!/bin/bash
RAAchievment() {
	#if there is no rap file and we have said to enable retroachieve, we have to ask. Also if the user wants to change their sign  in, we ask.
	if [[ ! -f "$HOME/emudeck/.rap" && $doRAEnable == true ]] || [[ $doRASignIn == true ]]; then

		text=$(printf "Do you want to use RetroAchievments on Retroarch?\n\n<b>You need to have an account on https://retroachievements.org</b>\n\nActivating RetroAchievments will disable save states unless you disable hardcore mode\n\n\n\nPress STEAM + X to get the onscreen Keyboard\n\n<b>Make sure your RetroAchievments account is validated on the website or RetroArch will crash</b>")
		RAInput=$(zenity --forms \
			--title="Retroachievements Sign in" \
			--text="$text" \
			--add-entry="Username: " \
			--add-password="Password: " \
			--separator="," 2>/dev/null)
		ans=$?
		if [ $ans -eq 0 ]; then
			echo "RetroAchievment Login"
			echo "$RAInput" | awk -F "," '{print $1}' >"$HOME/emudeck/.rau"
			echo "$RAInput" | awk -F "," '{print $2}' >"$HOME/emudeck/.rap"
			rap=$(cat "$HOME/emudeck/.rap")
			rau=$(cat "$HOME/emudeck/.rau")
			if [ ${#rap} -lt 1 ]; then
				echo "No password"
				doRAEnable=false
			elif [ ${#rau} -lt 1 ]; then
				echo "No username"
				doRAEnable=false
			else
				echo "Valid Username and Password"
			fi
		else
			echo "Cancel RetroAchievment Login"
		fi
	fi

	#if we have a rap file already, and the user wanted to enable retroachievements, but didn't want to set a new username and pw.
	if [[ -f "$HOME/emudeck/.rap" && $doRAEnable == true ]]; then
		rap=$(cat "$HOME/emudeck/.rap")
		rau=$(cat "$HOME/emudeck/.rau")

		sed -i "s|cheevos_password = \"\"|cheevos_password = \"${rap}\"|g" "$raConfigFile"
		sed -i "s|cheevos_username = \"\"|cheevos_username = \"${rau}\"|g" "$raConfigFile"
		sed -i "s|cheevos_enable = \"false\"|cheevos_enable = \"true\"|g" "$raConfigFile"
	fi
}
