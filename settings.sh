#!/bin/bash

#Expert mode off by default
expert=false

#Default settings for all systems
doSetupRA=true
doSetupDolphin=true
doSetupPCSX2=false
doSetupRPCS3=true
doSetupYuzu=true
doSetupCitra=true
doSetupDuck=true
doSetupCemu=true
doSetupXenia=false
doSetupRyujinx=true
doSetupMAME=true
doSetupPrimehack=true
doSetupPPSSPP=true
doSetupRMG=true
doSetupares=true
doSetupXemu=true
doSetupESDE=true
doSetupSRM=true
doSetupPCSX2QT=true
#doSetupMelon=true
doSetupMGBA=true
doSetupFlycast=true

#Install all systems by default
doInstallSRM=true
doInstallESDE=true
doInstallRA=false
doInstallDolphin=false
doInstallPCSX2=false
doInstallRPCS3=false
doInstallYuzu=false
doInstallCitra=false
doInstallDuck=false
doInstallCemu=false
doInstallXenia=false
doInstallRyujinx=false
doInstallPrimeHack=false
doInstallPPSSPP=false
doInstallRMG=false
doInstallares=false
doInstallXemu=false
doInstallPCSX2QT=false
doInstallMAME=true
#doInstallMelon=false
doInstallMGBA=false
doInstallFlycast=true
doInstallCHD=false
doInstallPowertools=false
doInstallGyro=false
doInstallHomeBrewGames=false

installString='Installing'

#Default RetroArch configuration 
RABezels=true
RAautoSave=false

#Default widescreen
duckWide=false
DolphinWide=false
DreamcastWide=false
BeetleWide=false
pcsx2QTWide=false

#Default installation folders
emulationPath=~/Emulation
romsPath=~/Emulation/roms
toolsPath=~/Emulation/tools
biosPath=~/Emulation/bios
savesPath=~/Emulation/saves
storagePath=~/Emulation/storage
ESDEscrapData=~/Emulation/tools/downloaded_media

#Default ESDE Theme
esdeTheme="EPICNOIR"

#Advanced settings
doSelectWideScreen=false
doRASignIn=false
doRAEnable=false
doESDEThemePicker=false
doSelectEmulators=false
doResetEmulators=false
XemuWide=false

#New UI settings
achievementsPass=false
achievementsUser=false
arClassic3D=43
arDolphin=43
arSega=43
arSnes=43
RAHandClassic2D=false
RAHandClassic3D=false
RAHandHeldShader=true
doSetupSaveSync=false
