#!/bin/bash
. $HOME/.config/EmuDeck/backend/functions/all.sh
. ./api.sh

YELLOW='\033[01;33m'
CYAN='\033[01;36m'
NONE='\033[00m'

#Red STDERR

exec 9>&2
exec 8> >(
	while IFS='' read -r line || [ -n "$line" ]; do
	   echo -e "\033[31m${line}\033[0m"
	done
)
function undirect(){ exec 2>&9; }
function redirect(){ exec 2>&8; }
trap "redirect;" DEBUG
PROMPT_COMMAND='undirect;'

# Git Pull
echo "" && echo -e "${YELLOW}Testing Git Pull...${NONE}"
API_pull 1> /dev/null dev

#
## Quick Settings
#

function QuickSettings(){

	# AutoSave
	echo "" && echo -ne "${CYAN}Testing AutoSave...${NONE}"
	API_autoSave

	# Bezels
	echo "" && echo -ne "${CYAN}Testing Bezels...${NONE}"
	API_bezels

	# Sega AR
	echo "" && echo -ne "${CYAN}Testing Sega AR...${NONE}"
	API_ar_sega

	# Nintendo AR
	echo "" && echo -ne "${CYAN}Testing Nintendo AR...${NONE}"
	API_ar_snes

	# 3D AR
	echo "" && echo -ne "${CYAN}Testing 3D AR...${NONE}"
	API_setAR

	# GameCube AR
	echo "" && echo -ne "${CYAN}Testing GameCube AR...${NONE}"
	API_ar_gamecube


	# LCD Shader
	echo "" && echo -ne "${CYAN}Testing LCD Shader...${NONE}"
	API_shaders_LCD

	# CRT Shader
	echo "" && echo -ne "${CYAN}Testing CRT Shader...${NONE}"
	API_shaders_CRT

	# 3D CRT Shader
	echo "" && echo -ne "${CYAN}Testing 3D CRT Shader...${NONE}"
	API_shaders_3D

}

echo "" && echo -ne "${YELLOW}Testing QuickSettings ON...${NONE}"
echo ""

RABezels=true
RAautoSave=true
arClassic3D=169
arDolphin=169
arSega=32
arSnes=87
RAHandClassic2D=true
RAHandClassic3D=true
RAHandHeldShader=true
doSetupSaveSync=true

QuickSettings

echo ""
echo "" && echo -ne "${YELLOW}Testing QuickSettings OFF...${NONE}"
echo ""

RABezels=false
RAautoSave=false
arClassic3D=43
arDolphin=43
arSega=43
arSnes=43
RAHandClassic2D=false
RAHandClassic3D=false
RAHandHeldShader=false
doSetupSaveSync=false

QuickSettings

#
# # Emulators
#

# RA

echo "" && echo -ne "${YELLOW}Testing RA...${NONE}"

	#Install
	echo "" && echo -ne "${CYAN}Installation...${NONE}"
	RetroArch_isInstalled

	#Launcher
	echo "" && echo -ne "${CYAN}Launcher...${NONE}"


	#Game
	echo "" && echo -ne "${CYAN}Game...${NONE}"


	#Uninstall
	echo "" && echo -ne "${CYAN}Uninstall...${NONE}"


	#Resolution
	echo "" && echo -ne "${CYAN}Resolution...${NONE}"



# Dolphin

echo "" && echo -ne "${YELLOW}Testing Dolphin...${NONE}"


# PrimeHack

echo "" && echo -ne "${YELLOW}Testing PrimeHack...${NONE}"


# PPSSPP

echo "" && echo -ne "${YELLOW}Testing PPSSPP...${NONE}"


# Duckstation

echo "" && echo -ne "${YELLOW}Testing Duckstation...${NONE}"


# melonDS

echo "" && echo -ne "${YELLOW}Testing melonDS...${NONE}"


# Citra

echo "" && echo -ne "${YELLOW}Testing Citra...${NONE}"


# PCSX2

echo "" && echo -ne "${YELLOW}Testing PCSX2...${NONE}"


# RPCS3

echo "" && echo -ne "${YELLOW}Testing RPCS3...${NONE}"


# Yuzu

echo "" && echo -ne "${YELLOW}Testing Yuzu...${NONE}"


# Ryujinx

echo "" && echo -ne "${YELLOW}Testing Ryujinx...${NONE}"


# Xemu

echo "" && echo -ne "${YELLOW}Testing Xemu...${NONE}"


# Cemu

echo "" && echo -ne "${YELLOW}Testing Cemu...${NONE}"


# SRM

echo "" && echo -ne "${YELLOW}Testing SRM...${NONE}"


# RMG

echo "" && echo -ne "${YELLOW}Testing RMG...${NONE}"


# MAME

echo "" && echo -ne "${YELLOW}Testing MAME...${NONE}"


# Vita3K

echo "" && echo -ne "${YELLOW}Testing Vita3K...${NONE}"


# Flycast

echo "" && echo -ne "${YELLOW}Testing Flycast...${NONE}"


# ScummVM

echo "" && echo -ne "${YELLOW}Testing ScummVM...${NONE}"


# Xenia

echo "" && echo -ne "${YELLOW}Testing Xenia...${NONE}"


# mGBA

echo "" && echo -ne "${YELLOW}Testing mGBA...${NONE}"


# ESDE

echo "" && echo -ne "${YELLOW}Testing ESDE...${NONE}"


# Pegasus

echo "" && echo -ne "${YELLOW}Testing Pegasus...${NONE}"



#
# Others

echo "" && echo -ne "${YELLOW}Testing Others...${NONE}"
#


# CloudSaves

echo "" && echo -ne "${YELLOW}Testing CloudSaves...${NONE}"


# RetroAchievements

echo "" && echo -ne "${YELLOW}Testing RetroAchievements...${NONE}"


# EmuDecky

echo "" && echo -ne "${YELLOW}Testing EmuDecky...${NONE}"


# GyroDSU

echo "" && echo -ne "${YELLOW}Testing GyroDSU...${NONE}"


