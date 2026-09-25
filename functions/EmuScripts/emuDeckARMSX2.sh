#!/usr/bin/env bash
#variables
ARMSX2_emuName="ARMSX2"
ARMSX2_emuType="$emuDeckEmuTypeAppImage"
ARMSX2_emuPath="$emusFolder/armsx2.AppImage"
ARMSX2_configFile="$HOME/.config/ARMSX2/inis/PCSX2.ini"

#cleanupOlderThings
ARMSX2_cleanup() {
	echo "NYI"
}

#Install
ARMSX2_install() {
	echo "Begin ARMSX2 Install"
	local showProgress="$1"

	#if installEmuAI "${ARMSX2_emuName}" "https://github.com/PCSX2/pcsx2/releases/download/v1.7.4749/pcsx2-v1.7.4749-linux-appimage-x64-Qt.AppImage" "pcsx2-Qt" "$showProgress"; then # pcsx2-Qt.AppImage - filename capitalization matters for ES-DE to find it
	
	
	if [ $CPUarch == "arm" ]; then
		url=$(getReleaseURLGH "ARMSX2/ARMSX2" "AppImage" "4K-pages")
	else
		return 0
	fi
	
	installEmuAI "${ARMSX2_emuName}" "" "$url" "armsx2" "" "emulator" "$showProgress"
}

#ApplyInitialSettings
ARMSX2_init() {
	setMSG "Initializing $ARMSX2_emuName settings."

	if [ -e "$ARMSX2_configFile" ]; then
		mv -f "$ARMSX2_configFile" "$ARMSX2_configFile.bak"
	fi

	if ! "$ARMSX2_emuPath" -testconfig; then # try to generate the config file. if it fails, insert one as a fallback.
		#fallback
		configEmuAI "$ARMSX2_emuName" "config" "$HOME/.config/ARMSX2" "$emudeckBackend/configs/armsx2/.config/ARMSX2" "true"
	fi

	ARMSX2_setEmulationFolder
	ARMSX2_setupStorage
	ARMSX2_setupSaves
	ARMSX2_setupControllers
	ARMSX2_setCustomizations
	ARMSX2_setRetroAchievements
	ARMSX2_setResolution
	#SRM_createParsers
	ARMSX2_flushEmulatorLauncher
	ARMSX2_addParser
	linkToStorageFolder pcsx2 cheats "$HOME/.config/ARMSX2/cheats"

}

ARMSX2_addParser(){
	addParser "sony_ps2_armsx2.json"
}

#update
ARMSX2_update() {
	setMSG "Updating $ARMSX2_emuName settings."
	configEmuAI "$ARMSX2_emuName" "config" "$HOME/.config/ARMSX2" "$emudeckBackend/configs/armsx2/.config/ARMSX2"
	ARMSX2_setEmulationFolder
	ARMSX2_setupStorage
	ARMSX2_setupSaves
	ARMSX2_setupControllers
	ARMSX2_flushEmulatorLauncher

}

#ConfigurePaths
ARMSX2_setEmulationFolder() {
	setMSG "Setting $ARMSX2_emuName Emulation Folder"

	iniFieldUpdate "$ARMSX2_configFile" "UI" "ConfirmShutdown" "false"
	 iniFieldUpdate "$ARMSX2_configFile" "UI" "SetupWizardIncomplete" "false"
	iniFieldUpdate "$ARMSX2_configFile" "UI" "StartFullscreen" "true"
	iniFieldUpdate "$ARMSX2_configFile" "Folders" "Bios" "${biosPath}"
	iniFieldUpdate "$ARMSX2_configFile" "Folders" "Snapshots" "${storagePath}/armsx2/snaps"
	iniFieldUpdate "$ARMSX2_configFile" "Folders" "SaveStates" "${savesPath}/pcsx2/states"
	iniFieldUpdate "$ARMSX2_configFile" "Folders" "MemoryCards" "${savesPath}/pcsx2/saves"
	iniFieldUpdate "$ARMSX2_configFile" "Folders" "Cache" "${storagePath}/armsx2/cache"
	iniFieldUpdate "$ARMSX2_configFile" "Folders" "Covers" "${storagePath}/armsx2/covers"
	iniFieldUpdate "$ARMSX2_configFile" "Folders" "Textures" "${storagePath}/armsx2/textures"

	iniFieldUpdate "$ARMSX2_configFile" "GameList" "RecursivePaths" "${romsPath}/ps2"

}

#SetupSaves
ARMSX2_setupSaves() {
	#link fp and ap saves / states?
	echo "NYI"
	#moveSaveFolder pcsx2 saves "$HOME/.var/app/net.pcsx2.PCSX2/config/ARMSX2/memcards"
	#moveSaveFolder pcsx2 states "$HOME/.var/app/net.pcsx2.PCSX2/config/ARMSX2/sstates"
}

ARMSX2_setupControllers() {
	new_pad1_section="Type = DualShock2
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

	new_hotkey_section="ToggleFullscreen = SDL-0/Start & SDL-0/LeftStick
CycleInterlaceMode = Keyboard/F5
CycleMipmapMode = Keyboard/Insert
GSDumpMultiFrame = Keyboard/Control & Keyboard/Shift & Keyboard/F8
Screenshot = Keyboard/F8
GSDumpSingleFrame = Keyboard/Shift & Keyboard/F8
ZoomIn = Keyboard/Control & Keyboard/Plus
ZoomOut = Keyboard/Control & Keyboard/Minus
InputRecToggleMode = Keyboard/Shift & Keyboard/R
LoadStateFromSlot = SDL-0/Back & SDL-0/LeftShoulder
SaveStateToSlot = SDL-0/Back & SDL-0/RightShoulder
ShutdownVM = SDL-0/Back & SDL-0/Start
ToggleFrameLimit = Keyboard/F4
TogglePause = SDL-0/Back & SDL-0/A
ToggleSlowMotion = SDL-0/Back & SDL-0/+LeftTrigger
ToggleTurbo = SDL-0/Back & SDL-0/+RightTrigger
HoldTurbo = Keyboard/Period
ResetVM = SDL-0/Back & SDL-0/LeftStick
OpenPauseMenu = SDL-0/Back & SDL-0/RightStick
IncreaseUpscaleMultiplier = SDL-0/Start & SDL-0/DPadUp
DecreaseUpscaleMultiplier = SDL-0/Start & SDL-0/DPadDown
CycleAspectRatio = SDL-0/Start & SDL-0/DPadRight
ToggleSoftwareRendering = SDL-0/Start & SDL-0/DPadLeft
ToggleSoftwareRendering = Keyboard/F9
NextSaveStateSlot = SDL-0/Start & SDL-0/RightShoulder
PreviousSaveStateSlot = SDL-0/Start & SDL-0/LeftShoulder"


	iniSectionUpdate "${ARMSX2_configFile}" "Hotkeys" "${new_hotkey_section}"

	iniSectionUpdate "${ARMSX2_configFile}" "Pad1" "${new_pad1_section}"

	iniSectionUpdate "${ARMSX2_configFile}" "Pad2" "${new_pad2_section}"

}

#SetupStorage
ARMSX2_setupStorage() {
	echo "Begin ARMSX2 storage config"
	mkdir -p "${storagePath}/armsx2/snaps"
	mkdir -p "${storagePath}/armsx2/cache"
	mkdir -p "${storagePath}/armsx2/textures"
	mkdir -p "${storagePath}/armsx2/covers"
}

#WipeSettings
ARMSX2_wipe() {
	setMSG "Wiping $ARMSX2_emuName settings."
	rm -rf "$HOME/.config/ARMSX2"
	# prob not cause roms are here
}

#Uninstall
ARMSX2_uninstall() {
	setMSG "Uninstalling $ARMSX2_emuName."
	uninstallEmuAI "$ARMSX2_emuName" "armsx2" "" "emulator"
	#ARMSX2_wipe
}

#setABXYstyle
ARMSX2_setABXYstyle() {
	echo "NYI"
}

#Migrate
ARMSX2_migrate() {
	echo "NYI"
}

#WideScreenOn
ARMSX2_wideScreenOn() {
	iniFieldUpdate "$ARMSX2_configFile" "EmuCore" "EnableWideScreenPatches" "true"
	iniFieldUpdate "$ARMSX2_configFile" "EmuCore/GS" "AspectRatio" "16:9"
}

#WideScreenOff
ARMSX2_wideScreenOff() {
	iniFieldUpdate "$ARMSX2_configFile" "EmuCore" "EnableWideScreenPatches" "false"
	iniFieldUpdate "$ARMSX2_configFile" "EmuCore/GS" "AspectRatio" "Auto 4:3/3:2"
}

#BezelOn
ARMSX2_bezelOn() {
	echo "NYI"
}

#BezelOff
ARMSX2_bezelOff() {
	echo "NYI"
}

#finalExec - Extra stuff
ARMSX2_finalize() {
	echo "NYI"
}

ARMSX2_IsInstalled() {
	if [ -e "$ARMSX2_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

ARMSX2_resetConfig() {
	ARMSX2_init &>/dev/null && echo "true" || echo "false"
}

ARMSX2_addSteamInputProfile() {
	echo "NYI"
}

ARMSX2_retroAchievementsOn() {
	iniFieldUpdate "$ARMSX2_configFile" "Achievements" "Enabled" "true"
}
ARMSX2_retroAchievementsOff() {
	iniFieldUpdate "$ARMSX2_configFile" "Achievements" "Enabled" "false"
}

ARMSX2_retroAchievementsHardCoreOn() {
	iniFieldUpdate "$ARMSX2_configFile" "Achievements" "ChallengeMode" "true"

}
ARMSX2_retroAchievementsHardCoreOff() {
	iniFieldUpdate "$ARMSX2_configFile" "Achievements" "ChallengeMode" "false"
}

ARMSX2_retroAchievementsSetLogin() {
	ra_get_credentials
	rau="$achievementsUser"
	rat="$achievementsUserToken"
	echo "Evaluate RetroAchievements Login."
	if [ ${#rat} -lt 1 ]; then
		echo "--No token."
	elif [ ${#rau} -lt 1 ]; then
		echo "--No username."
	else
		echo "Valid Retroachievements Username and Password length"
		iniFieldUpdate "$ARMSX2_configFile" "Achievements" "Username" "$rau"
		iniFieldUpdate "$ARMSX2_configFile" "Achievements" "Token" "$rat"
		iniFieldUpdate "$ARMSX2_configFile" "Achievements" "LoginTimestamp" "$(date +%s)"
		ARMSX2_retroAchievementsOn
	fi
}

ARMSX2_setRetroAchievements(){
	ARMSX2_retroAchievementsSetLogin
	if [ "$achievementsHardcore" == "true" ]; then
		ARMSX2_retroAchievementsHardCoreOn
	else
		ARMSX2_retroAchievementsHardCoreOff
	fi
}

ARMSX2_setCustomizations(){
	echo "NYI"
}


ARMSX2_setResolution(){

	case $pcsx2Resolution in
		"720P") multiplier=2;;
		"1080P") multiplier=3;;
		"1440P") multiplier=4;;
		"4K") multiplier=6;;
		*) multiplier=2;;
	esac
	
	#Steam Machine 4K > 1080P fallback
	if [ "$pcsx2Resolution" = "4K" ]; then
		getScreenInfoOnlyTV	
		if [ "${screenWidth:-0}" -lt 3840 ]; then 
			multiplier=3
		fi
	fi

	RetroArch_setConfigOverride "upscale_multiplier" $multiplier "$ARMSX2_configFile"
}

ARMSX2_flushEmulatorLauncher(){


	flushEmulatorLaunchers "pcsx2-qt"

}
