#!/bin/bash
#variables
HypseusSinge_emuName="Hypseus Singe"
HypseusSinge_emuType="$emuDeckEmuTypeAppImage"
HypseusSinge_emuPath="$HOME/Applications/pcsx2-Qt.AppImage"
HypseusSinge_configFile="$HOME/.config/PCSX2/inis/PCSX2.ini"

#cleanupOlderThings
HypseusSinge_cleanup() {
	echo "NYI"
}

#Install
HypseusSinge_install() {
	echo "Begin PCSX2-QT Install"
	local showProgress="$1"

	#if installEmuAI "${HypseusSinge_emuName}" "https://github.com/PCSX2/pcsx2/releases/download/v1.7.4749/pcsx2-v1.7.4749-linux-appimage-x64-Qt.AppImage" "pcsx2-Qt" "$showProgress"; then # pcsx2-Qt.AppImage - filename capitalization matters for ES-DE to find it
	if installEmuAI "${HypseusSinge_emuName}" "$(getReleaseURLGH "PCSX2/pcsx2" "Qt.AppImage")" "pcsx2-Qt" "$showProgress"; then # pcsx2-Qt.AppImage - filename capitalization matters for ES-DE to find it
		rm -rf $HOME/.local/share/applications/pcsx2-Qt.desktop &>/dev/null # delete old shortcut
	else
		return 1
	fi
}
#Fix for autoupdate
Pcsx2_install(){
	HypseusSinge_install
}

#ApplyInitialSettings
HypseusSinge_init() {
	setMSG "Initializing $HypseusSinge_emuName settings."

	if [ -e "$HypseusSinge_configFile" ]; then
		mv -f "$HypseusSinge_configFile" "$HypseusSinge_configFile.bak"
	fi

	if ! "$HypseusSinge_emuPath" -testconfig; then # try to generate the config file. if it fails, insert one as a fallback.
		#fallback
		configEmuAI "$HypseusSinge_emuName" "config" "$HOME/.config/PCSX2" "$EMUDECKGIT/configs/HypseusSinge/.config/PCSX2" "true"
	fi

	HypseusSinge_setEmulationFolder
	HypseusSinge_setupStorage
	HypseusSinge_setupSaves
	HypseusSinge_setupControllers
	HypseusSinge_setCustomizations
	HypseusSinge_setRetroAchievements

}

#update
HypseusSinge_update() {
	setMSG "Updating $HypseusSinge_emuName settings."
	configEmuAI "$HypseusSinge_emuName" "config" "$HOME/.config/PCSX2" "$EMUDECKGIT/configs/HypseusSinge/.config/PCSX2"
	HypseusSinge_setEmulationFolder
	HypseusSinge_setupStorage
	HypseusSinge_setupSaves
	HypseusSinge_setupControllers


}

#ConfigurePaths
HypseusSinge_setEmulationFolder() {
	setMSG "Setting $HypseusSinge_emuName Emulation Folder"

	iniFieldUpdate "$HypseusSinge_configFile" "UI" "ConfirmShutdown" "false"
	iniFieldUpdate "$HypseusSinge_configFile" "Folders" "Bios" "${biosPath}"
	iniFieldUpdate "$HypseusSinge_configFile" "Folders" "Snapshots" "${storagePath}/pcsx2/snaps"
	iniFieldUpdate "$HypseusSinge_configFile" "Folders" "Savestates" "${savesPath}/pcsx2/states"
	iniFieldUpdate "$HypseusSinge_configFile" "Folders" "MemoryCards" "${savesPath}/pcsx2/saves"
	iniFieldUpdate "$HypseusSinge_configFile" "Folders" "Cache" "${storagePath}/pcsx2/cache"
	iniFieldUpdate "$HypseusSinge_configFile" "Folders" "Covers" "${storagePath}/pcsx2/covers"
	iniFieldUpdate "$HypseusSinge_configFile" "Folders" "Textures" "${storagePath}/pcsx2/textures"

	iniFieldUpdate "$HypseusSinge_configFile" "GameList" "RecursivePaths" "${romsPath}/ps2"

}

#SetupSaves
HypseusSinge_setupSaves() {
	#link fp and ap saves / states?
	moveSaveFolder pcsx2 saves "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards"
	moveSaveFolder pcsx2 states "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates"
}

HypseusSinge_setupControllers() {
	new_pad1_section="
Type = DualShock2
InvertL = 0
InvertR = 0
Deadzone = 0.000000
AxisScale = 1.330000
TriggerDeadzone = 0
TriggerScale = 1
LargeMotorScale = 1.000000
SmallMotorScale = 1.000000
ButtonDeadzone = 0
PressureModifier = 0.300000
Up = SDL-0/DPadUp
Right = SDL-0/DPadRight
Down = SDL-0/DPadDown
Left = SDL-0/DPadLeft
Triangle = SDL-0/Y
Circle = SDL-0/B
Cross = SDL-0/A
Square = SDL-0/X
Select = SDL-0/Back
Start = SDL-0/Start
L1 = SDL-0/LeftShoulder
L2 = SDL-0/+LeftTrigger
R1 = SDL-0/RightShoulder
R2 = SDL-0/+RightTrigger
L3 = SDL-0/LeftStick
R3 = SDL-0/RightStick
LUp = SDL-0/-LeftY
LRight = SDL-0/+LeftX
LDown = SDL-0/+LeftY
LLeft = SDL-0/-LeftX
RUp = SDL-0/-RightY
RRight = SDL-0/+RightX
RDown = SDL-0/+RightY
RLeft = SDL-0/-RightX
SmallMotor = SDL-0/SmallMotor
LargeMotor = SDL-0/LargeMotor
Analog = Keyboard/F6
Pressure = Keyboard/S"

	new_pad2_section="Type = DualShock2
Deadzone = 0.000000
AxisScale = 1.330000
LargeMotorScale = 1.000000
SmallMotorScale = 1.000000
PressureModifier = 0.300000
Up = SDL-1/DPadUp
Right = SDL-1/DPadRight
Down = SDL-1/DPadDown
Left = SDL-1/DPadLeft
Triangle = SDL-1/Y
Circle = SDL-1/B
Cross = SDL-1/A
Square = SDL-1/X
Select = SDL-1/Back
Start = SDL-1/Start
L1 = SDL-1/LeftShoulder
L2 = SDL-1/+LeftTrigger
R1 = SDL-1/RightShoulder
R2 = SDL-1/+RightTrigger
L3 = SDL-1/LeftStick
R3 = SDL-1/RightStick
Analog = SDL-1/Guide
LUp = SDL-1/-LeftY
LRight = SDL-1/+LeftX
LDown = SDL-1/+LeftY
LLeft = SDL-1/-LeftX
RUp = SDL-1/-RightY
RRight = SDL-1/+RightX
RDown = SDL-1/+RightY
RLeft = SDL-1/-RightX
LargeMotor = SDL-1/LargeMotor
SmallMotor = SDL-1/SmallMotor"

	new_hotkey_section="CycleAspectRatio = SDL-0/Start & SDL-0/DPadRight
CycleAspectRatio = Keyboard/F6
CycleInterlaceMode = Keyboard/F5
CycleMipmapMode = Keyboard/Insert
DecreaseUpscalemultiplier=SDL-0/Start & SDL-0/DPadDown
GSDumpMultiFrame = Keyboard/Control & Keyboard/Shift & Keyboard/F8
GSDumpSingleFrame = Keyboard/Shift & Keyboard/F8
HoldTurbo = Keyboard/Period
IncreaseUpscalemultiplier=SDL-0/Start & SDL-0/DPadUp
InputRecToggleMode = Keyboard/Shift & Keyboard/R
LoadStateFromSlot = Keyboard/F3
LoadStateFromSlot = SDL-0/Back & SDL-0/LeftShoulder
NextSaveStateSlot = Keyboard/F2
NextSaveStateSlot = SDL-0/Start & SDL-0/RightShoulder
OpenPauseMenu = Keyboard/Escape
OpenPauseMenu = SDL-0/Start & SDL-0/LeftStick
PreviousSaveStateSlot = Keyboard/Shift & Keyboard/F2
PreviousSaveStateSlot = SDL-0/Start & SDL-0/LeftShoulder
ResetVM = SDL-0/Back & SDL-0/B
SaveStateToSlot = Keyboard/F1
SaveStateToSlot = SDL-0/Back & SDL-0/RightShoulder
Screenshot = Keyboard/F8
ShutdownVM = SDL-0/Back & SDL-0/Start
ToggleFrameLimit = Keyboard/F4
ToggleFrameLimit = SDL-0/Start & SDL-0/DPadRight
ToggleFullscreen = Keyboard/Alt & Keyboard/Return
ToggleFullscreen = SDL-0/Back & SDL-0/RightStick
TogglePause = Keyboard/Space
TogglePause = SDL-0/Back & SDL-0/A
ToggleSlowMotion = Keyboard/Shift & Keyboard/Backtab
ToggleSlowMotion = SDL-0/Back & SDL-0/+LeftTrigger
ToggleSoftwareRendering = Keyboard/F9
ToggleSoftwareRendering = SDL-0/Start & SDL-0/DPadLeft
ToggleTurbo = Keyboard/Tab
ToggleTurbo = SDL-0/Back & SDL-0/+RightTrigger
ZoomIn = Keyboard/Control & Keyboard/Plus
ZoomOut = Keyboard/Control & Keyboard/Minus"


	iniSectionUpdate "${HypseusSinge_configFile}" "Hotkeys" "${new_hotkey_section}"

	iniSectionUpdate "${HypseusSinge_configFile}" "Pad1" "${new_pad1_section}"

	iniSectionUpdate "${HypseusSinge_configFile}" "Pad2" "${new_pad2_section}"

}

#SetupStorage
HypseusSinge_setupStorage() {
	echo "Begin PCSX2-QT storage config"
	mkdir -p "${storagePath}/pcsx2/snaps"
	mkdir -p "${storagePath}/pcsx2/cache"
	mkdir -p "${storagePath}/pcsx2/textures"
	mkdir -p "${storagePath}/pcsx2/covers"
}

#WipeSettings
HypseusSinge_wipe() {
	setMSG "Wiping $HypseusSinge_emuName settings."
	rm -rf "$HOME/.config/PCSX2"
	# prob not cause roms are here
}

#Uninstall
HypseusSinge_uninstall() {
	setMSG "Uninstalling $HypseusSinge_emuName."
	rm -rf "$HypseusSinge_emuPath"
	HypseusSinge_wipe
}

#setABXYstyle
HypseusSinge_setABXYstyle() {
	echo "NYI"
}

#Migrate
HypseusSinge_migrate() {
	echo "NYI"
}

#WideScreenOn
HypseusSinge_wideScreenOn() {
	iniFieldUpdate "$HypseusSinge_configFile" "EmuCore" "EnableWideScreenPatches" "True"
	iniFieldUpdate "$HypseusSinge_configFile" "EmuCore/GS" "AspectRatio" "16:9"
}

#WideScreenOff
HypseusSinge_wideScreenOff() {
	iniFieldUpdate "$HypseusSinge_configFile" "EmuCore" "EnableWideScreenPatches" "false"
	iniFieldUpdate "$HypseusSinge_configFile" "EmuCore/GS" "AspectRatio" "Auto 4:3/3:2"
}

#BezelOn
HypseusSinge_bezelOn() {
	echo "NYI"
}

#BezelOff
HypseusSinge_bezelOff() {
	echo "NYI"
}

#finalExec - Extra stuff
HypseusSinge_finalize() {
	echo "NYI"
}

HypseusSinge_IsInstalled() {
	if [ -e "$HypseusSinge_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

HypseusSinge_resetConfig() {
	HypseusSinge_init &>/dev/null && echo "true" || echo "false"
}

HypseusSinge_addSteamInputProfile() {
	echo "NYI"
}

HypseusSinge_retroAchievementsOn() {
	iniFieldUpdate "$HypseusSinge_configFile" "Achievements" "Enabled" "True"
}
HypseusSinge_retroAchievementsOff() {
	iniFieldUpdate "$HypseusSinge_configFile" "Achievements" "Enabled" "False"
}

HypseusSinge_retroAchievementsHardCoreOn() {
	iniFieldUpdate "$HypseusSinge_configFile" "Achievements" "ChallengeMode" "True"

}
HypseusSinge_retroAchievementsHardCoreOff() {
	iniFieldUpdate "$HypseusSinge_configFile" "Achievements" "ChallengeMode" "False"
}

HypseusSinge_retroAchievementsSetLogin() {
	rau=$(cat "$HOME/.config/EmuDeck/.rau")
	rat=$(cat "$HOME/.config/EmuDeck/.rat")
	echo "Evaluate RetroAchievements Login."
	if [ ${#rat} -lt 1 ]; then
		echo "--No token."
	elif [ ${#rau} -lt 1 ]; then
		echo "--No username."
	else
		echo "Valid Retroachievements Username and Password length"
		iniFieldUpdate "$HypseusSinge_configFile" "Achievements" "Username" "$rau"
		iniFieldUpdate "$HypseusSinge_configFile" "Achievements" "Token" "$rat"
		iniFieldUpdate "$HypseusSinge_configFile" "Achievements" "LoginTimestamp" "$(date +%s)"
		HypseusSinge_retroAchievementsOn
	fi
}

HypseusSinge_setRetroAchievements(){
	HypseusSinge_retroAchievementsSetLogin
	if [ "$achievementsHardcore" == "true" ]; then
		HypseusSinge_retroAchievementsHardCoreOn
	else
		HypseusSinge_retroAchievementsHardCoreOff
	fi
}

HypseusSinge_setCustomizations(){
	echo "NYI"
}


HypseusSinge_setResolution(){

	case $pcsx2Resolution in
		"720P") multiplier=2;;
		"1080P") multiplier=3;;
		"1440P") multiplier=4;;
		"4K") multiplier=6;;
		*) echo "Error"; return 1;;
	esac

	RetroArch_setConfigOverride "upscale_multiplier" $multiplier "$HypseusSinge_configFile"
}