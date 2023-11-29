#!/bin/bash
#variables
PCSX2QT_emuName="PCSX2-QT"
PCSX2QT_emuType="AppImage"
PCSX2QT_emuPath="$HOME/Applications/pcsx2-Qt.AppImage"
PCSX2QT_configFile="$HOME/.config/PCSX2/inis/PCSX2.ini"

#cleanupOlderThings
PCSX2QT_cleanup() {
	echo "NYI"
}

#Install
PCSX2QT_install() {
	echo "Begin PCSX2-QT Install"
	local showProgress="$1"

	if installEmuAI "${PCSX2QT_emuName}" "https://github.com/PCSX2/pcsx2/releases/download/v1.7.4749/pcsx2-v1.7.4749-linux-appimage-x64-Qt.AppImage" "pcsx2-Qt" "$showProgress"; then # pcsx2-Qt.AppImage - filename capitalization matters for ES-DE to find it
	#if installEmuAI "${PCSX2QT_emuName}" "$(getReleaseURLGH "PCSX2/pcsx2" "Qt.AppImage")" "pcsx2-Qt" "$showProgress"; then #pcsx2-Qt.AppImage
		rm -rf $HOME/.local/share/applications/pcsx2-Qt.desktop &>/dev/null # delete old shortcut
	else
		return 1
	fi
}

#ApplyInitialSettings
PCSX2QT_init() {
	setMSG "Initializing $PCSX2QT_emuName settings."

	if [ -e "$PCSX2QT_configFile" ]; then
		mv -f "$PCSX2QT_configFile" "$PCSX2QT_configFile.bak"
	fi

	if ! "$PCSX2QT_emuPath" -testconfig; then # try to generate the config file. if it fails, insert one as a fallback.
		#fallback
		configEmuAI "$PCSX2QT_emuName" "config" "$HOME/.config/PCSX2" "$EMUDECKGIT/configs/pcsx2qt/.config/PCSX2" "true"
	fi

	PCSX2QT_setEmulationFolder
	PCSX2QT_setupStorage
	PCSX2QT_setupSaves
	PCSX2QT_setupControllers
	PCSX2QT_setCustomizations
	PCSX2QT_setRetroAchievements

}

#update
PCSX2QT_update() {
	setMSG "Updating $PCSX2QT_emuName settings."
	configEmuAI "$PCSX2QT_emuName" "config" "$HOME/.config/PCSX2" "$EMUDECKGIT/configs/pcsx2qt/.config/PCSX2"
	PCSX2QT_setEmulationFolder
	PCSX2QT_setupStorage
	PCSX2QT_setupSaves
	PCSX2QT_setupControllers


}

#ConfigurePaths
PCSX2QT_setEmulationFolder() {
	setMSG "Setting $PCSX2QT_emuName Emulation Folder"

	iniFieldUpdate "$PCSX2QT_configFile" "Folders" "Bios" "${biosPath}"
	iniFieldUpdate "$PCSX2QT_configFile" "Folders" "Snapshots" "${storagePath}/pcsx2/snaps"
	iniFieldUpdate "$PCSX2QT_configFile" "Folders" "Savestates" "${savesPath}/pcsx2/states"
	iniFieldUpdate "$PCSX2QT_configFile" "Folders" "MemoryCards" "${savesPath}/pcsx2/saves"
	iniFieldUpdate "$PCSX2QT_configFile" "Folders" "Cache" "${storagePath}/pcsx2/cache"
	iniFieldUpdate "$PCSX2QT_configFile" "Folders" "Covers" "${storagePath}/pcsx2/covers"
	iniFieldUpdate "$PCSX2QT_configFile" "Folders" "Textures" "${storagePath}/pcsx2/textures"

	iniFieldUpdate "$PCSX2QT_configFile" "GameList" "RecursivePaths" "${romsPath}/ps2"

}

#SetupSaves
PCSX2QT_setupSaves() {
	#link fp and ap saves / states?
	moveSaveFolder pcsx2 saves "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards"
	moveSaveFolder pcsx2 states "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates"
}

PCSX2QT_setupControllers() {
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


	iniSectionUpdate "${PCSX2QT_configFile}" "Hotkeys" "${new_hotkey_section}"

	iniSectionUpdate "${PCSX2QT_configFile}" "Pad1" "${new_pad1_section}"

	iniSectionUpdate "${PCSX2QT_configFile}" "Pad2" "${new_pad2_section}"

}

#SetupStorage
PCSX2QT_setupStorage() {
	echo "Begin PCSX2-QT storage config"
	mkdir -p "${storagePath}/pcsx2/snaps"
	mkdir -p "${storagePath}/pcsx2/cache"
	mkdir -p "${storagePath}/pcsx2/textures"
	mkdir -p "${storagePath}/pcsx2/covers"
}

#WipeSettings
PCSX2QT_wipe() {
	setMSG "Wiping $PCSX2QT_emuName settings."
	rm -rf "$HOME/.config/PCSX2"
	# prob not cause roms are here
}

#Uninstall
PCSX2QT_uninstall() {
	setMSG "Uninstalling $PCSX2QT_emuName."
	rm -rf "$PCSX2QT_emuPath"
	PCSX2QT_wipe
}

#setABXYstyle
PCSX2QT_setABXYstyle() {
	echo "NYI"
}

#Migrate
PCSX2QT_migrate() {
	echo "NYI"
}

#WideScreenOn
PCSX2QT_wideScreenOn() {
	iniFieldUpdate "$PCSX2QT_configFile" "EmuCore" "EnableWideScreenPatches" "True"
	iniFieldUpdate "$PCSX2QT_configFile" "EmuCore/GS" "AspectRatio" "16:9"
}

#WideScreenOff
PCSX2QT_wideScreenOff() {
	iniFieldUpdate "$PCSX2QT_configFile" "EmuCore" "EnableWideScreenPatches" "false"
	iniFieldUpdate "$PCSX2QT_configFile" "EmuCore/GS" "AspectRatio" "Auto 4:3/3:2"
}

#BezelOn
PCSX2QT_bezelOn() {
	echo "NYI"
}

#BezelOff
PCSX2QT_bezelOff() {
	echo "NYI"
}

#finalExec - Extra stuff
PCSX2QT_finalize() {
	echo "NYI"
}

PCSX2QT_IsInstalled() {
	if [ -e "$PCSX2QT_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

PCSX2QT_resetConfig() {
	PCSX2QT_init &>/dev/null && echo "true" || echo "false"
}

PCSX2QT_addSteamInputProfile() {
	echo "NYI"
}

PCSX2QT_retroAchievementsOn() {
	iniFieldUpdate "$PCSX2QT_configFile" "Achievements" "Enabled" "True"
}
PCSX2QT_retroAchievementsOff() {
	iniFieldUpdate "$PCSX2QT_configFile" "Achievements" "Enabled" "False"
}

PCSX2QT_retroAchievementsHardCoreOn() {
	iniFieldUpdate "$PCSX2QT_configFile" "Achievements" "ChallengeMode" "True"

}
PCSX2QT_retroAchievementsHardCoreOff() {
	iniFieldUpdate "$PCSX2QT_configFile" "Achievements" "ChallengeMode" "False"
}

PCSX2QT_retroAchievementsSetLogin() {
	rau=$(cat "$HOME/.config/EmuDeck/.rau")
	rat=$(cat "$HOME/.config/EmuDeck/.rat")
	echo "Evaluate RetroAchievements Login."
	if [ ${#rat} -lt 1 ]; then
		echo "--No token."
	elif [ ${#rau} -lt 1 ]; then
		echo "--No username."
	else
		echo "Valid Retroachievements Username and Password length"
		iniFieldUpdate "$PCSX2QT_configFile" "Achievements" "Username" "$rau"
		iniFieldUpdate "$PCSX2QT_configFile" "Achievements" "Token" "$rat"
		iniFieldUpdate "$PCSX2QT_configFile" "Achievements" "LoginTimestamp" "$(date +%s)"
		PCSX2QT_retroAchievementsOn
	fi
}

PCSX2QT_setRetroAchievements(){
	PCSX2QT_retroAchievementsSetLogin
	if [ "$achievementsHardcore" == "true" ]; then
		PCSX2QT_retroAchievementsHardCoreOn
	else
		PCSX2QT_retroAchievementsHardCoreOff
	fi
}

PCSX2QT_setCustomizations(){
	echo "NYI"
}


PCSX2QT_setResolution(){

	case $pcsx2Resolution in
		"720P") multiplier=2;;
		"1080P") multiplier=3;;
		"1440P") multiplier=4;;
		"4K") multiplier=6;;
		*) echo "Error"; exit 1;;
	esac

	RetroArch_setConfigOverride "upscale_multiplier" $multiplier "$PCSX2QT_configFile"
}