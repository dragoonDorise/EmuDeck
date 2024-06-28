#!/bin/bash
function jsonToBashVars(){
    local json=$1
    echo "#!/bin/bash" > "$emuDecksettingsFile"
    #Install Emus
    setSetting system "$(jq .system $json)"
    setSetting doInstallRA "$(jq .installEmus.ra.status $json)"
    setSetting doInstallDolphin "$(jq .installEmus.dolphin.status $json)"
    setSetting doInstallPCSX2QT "$(jq .installEmus.pcsx2.status $json)"
    setSetting doInstallRPCS3 "$(jq .installEmus.rpcs3.status $json)"
    setSetting doInstallYuzu "$(jq .installEmus.yuzu.status $json)"
    setSetting doInstallSuyu "$(jq .installEmus.suyu.status $json)"
    setSetting doInstallCitra "$(jq .installEmus.citra.status $json)"
    setSetting doInstallLime3DS "$(jq .installEmus.lime3ds.status $json)"
    setSetting doInstallDuck "$(jq .installEmus.duckstation.status $json)"
    setSetting doInstallCemu "$(jq .installEmus.cemu.status $json)"
    setSetting doInstallXenia "$(jq .installEmus.xenia.status $json)"
    setSetting doInstallRyujinx "$(jq .installEmus.ryujinx.status $json)"
    setSetting doInstallMAME "$(jq .installEmus.mame.status $json)"
    setSetting doInstallPrimeHack "$(jq .installEmus.primehack.status $json)"
    setSetting doInstallPPSSPP "$(jq .installEmus.ppsspp.status $json)"
    setSetting doInstallXemu "$(jq .installEmus.xemu.status $json)"
    setSetting doInstallSRM "$(jq .installEmus.srm.status $json)"
    setSetting doInstallmelonDS "$(jq .installEmus.melonds.status $json)"
    setSetting doInstallScummVM "$(jq .installEmus.scummvm.status $json)"
    setSetting doInstallFlycast "$(jq .installEmus.flycast.status $json)"
    setSetting doInstallVita3K "$(jq .installEmus.vita3k.status $json)"
    setSetting doInstallMGBA "$(jq .installEmus.mgba.status $json)"
    setSetting doInstallPrimehack "$(jq .installEmus.primehack.status $json)"
    setSetting doInstallRMG "$(jq .installEmus.rmg.status $json)"
    setSetting doInstallares "$(jq .installEmus.ares.status $json)"
    setSetting doInstallSupermodel "$(jq .installEmus.supermodel.status $json)"
    setSetting doInstallModel2  "$(jq .installEmus.model2.status $json)"
    setSetting doInstallBigPEmu  "$(jq .installEmus.bigpemu.status $json)"


    #Setup Emus
    setSetting doSetupRA $(jq .overwriteConfigEmus.ra.status "$json")
    setSetting doSetupDolphin "$(jq .overwriteConfigEmus.dolphin.status $json)"
    setSetting doSetupPCSX2QT "$(jq .overwriteConfigEmus.pcsx2.status $json)"
    setSetting doSetupRPCS3 "$(jq .overwriteConfigEmus.rpcs3.status $json)"
    setSetting doSetupYuzu "$(jq .overwriteConfigEmus.yuzu.status $json)"
    setSetting doSetupSuyu "$(jq .overwriteConfigEmus.suyu.status $json)"
    setSetting doSetupCitra "$(jq .overwriteConfigEmus.citra.status $json)"
    setSetting doSetupLime3DS "$(jq .overwriteConfigEmus.lime3ds.status $json)"
    setSetting doSetupDuck "$(jq .overwriteConfigEmus.duckstation.status $json)"
    setSetting doSetupCemu "$(jq .overwriteConfigEmus.cemu.status $json)"
    setSetting doSetupXenia "$(jq .overwriteConfigEmus.xenia.status $json)"
    setSetting doSetupRyujinx "$(jq .overwriteConfigEmus.ryujinx.status $json)"
    setSetting doSetupMAME "$(jq .overwriteConfigEmus.mame.status $json)"
    setSetting doSetupPrimeHack "$(jq .overwriteConfigEmus.primehack.status $json)"
    setSetting doSetupPPSSPP "$(jq .overwriteConfigEmus.ppsspp.status $json)"
    setSetting doSetupXemu "$(jq .overwriteConfigEmus.xemu.status $json)"
    setSetting doSetupSRM "$(jq .overwriteConfigEmus.srm.status $json)"
    setSetting doSetupmelonDS "$(jq .overwriteConfigEmus.melonds.status $json)"
    setSetting doSetupScummVM "$(jq .overwriteConfigEmus.scummvm.status $json)"
    setSetting doSetupFlycast "$(jq .overwriteConfigEmus.flycast.status $json)"
    setSetting doSetupVita3K "$(jq .overwriteConfigEmus.vita3k.status $json)"
    setSetting doSetupMGBA "$(jq .overwriteConfigEmus.mgba.status $json)"
    setSetting doSetupPrimehack "$(jq .overwriteConfigEmus.primehack.status $json)"
    setSetting doSetupRMG "$(jq .overwriteConfigEmus.rmg.status $json)"
    setSetting doSetupares "$(jq .overwriteConfigEmus.ares.status $json)"
    setSetting doSetupSupermodel "$(jq .overwriteConfigEmus.supermodel.status $json)"
    setSetting doSetupModel2 "$(jq .overwriteConfigEmus.model2.status $json)"
    setSetting doSetupBigPEmu  "$(jq .overwriteConfigEmus.bigpemu.status $json)"

    #Frontends
    setSetting doSetupSRM "$(jq .overwriteConfigEmus.srm.status $json)"
    setSetting doSetupESDE "$(jq .overwriteConfigEmus.esde.status $json)"
    setSetting doInstallESDE "$(jq .installFrontends.esde.status $json)"
    setSetting doInstallPegasus "$(jq .installFrontends.pegasus.status $json)"
    setSetting steamAsFrontend "$(jq .installFrontends.steam.status $json)"


    #Customizations
    setSetting RABezels "$(jq .bezels $json)"
    setSetting RAautoSave "$(jq .autosave $json)"
    setSetting arClassic3D "$(jq .ar.classic3d $json)"
    setSetting arDolphin "$(jq .ar.dolphin $json)"
    setSetting arSega "$(jq .ar.sega $json)"
    setSetting arSnes "$(jq .ar.snes $json)"
    setSetting RAHandClassic2D "$(jq .shaders.classic $json)"
    setSetting RAHandClassic3D "$(jq .shaders.classic3d $json)"
    setSetting RAHandHeldShader "$(jq .shaders.handhelds $json)"
    setSetting controllerLayout "$(jq .controllerLayout $json)"

    #CloudSync
    setSetting cloud_sync_provider "$(jq .cloudSync $json)"
    setSetting cloud_sync_status "$(jq .cloudSyncStatus $json)"

    #Resolutions
    setSetting dolphinResolution  "$(jq .resolutions.dolphin $json)"
    setSetting duckstationResolution  "$(jq .resolutions.duckstation $json)"
    setSetting pcsx2Resolution  "$(jq .resolutions.pcsx2 $json)"
    setSetting yuzuResolution  "$(jq .resolutions.yuzu $json)"
    setSetting ppssppResolution  "$(jq .resolutions.ppsspp $json)"
    setSetting rpcs3Resolution  "$(jq .resolutions.rpcs3 $json)"
    setSetting citraResolution  "$(jq .resolutions.citra $json)"
    setSetting xemuResolution  "$(jq .resolutions.xemu $json)"
    setSetting xeniaResolution  "$(jq .resolutions.xenia $json)"
    setSetting melondsResolution  "$(jq .resolutions.melonds $json)"

    #MultiEmu Parsers
    setSetting emuGBA  "$(jq .emulatorAlternative.gba $json)"
    setSetting emuMAME  "$(jq .emulatorAlternative.mame $json)"
    setSetting emuMULTI  "$(jq .emulatorAlternative.multiemulator $json)"
    setSetting emuN64  "$(jq .emulatorAlternative.n64 $json)"
    setSetting emuNDS  "$(jq .emulatorAlternative.nds $json)"
    setSetting emuPSP  "$(jq .emulatorAlternative.psp $json)"
    setSetting emuPSX  "$(jq .emulatorAlternative.psx $json)"
    setSetting emuDreamcast  "$(jq .emulatorAlternative.dreamcast $json)"
    setSetting emuSCUMMVM "$(jq .emulatorAlternative.scummvm $json)"

    #Paths
    globPath=$(jq .storagePath $json)
    setSetting emulationPath "$globPath/Emulation"
    setSetting romsPath "$globPath/Emulation/roms"
    setSetting toolsPath "$globPath/Emulation/tools"
    setSetting biosPath "$globPath/Emulation/bios"
    setSetting savesPath "$globPath/Emulation/saves"
    setSetting storagePath "$globPath/Emulation/storage"
    setSetting ESDEscrapData "$globPath/Emulation/tools/downloaded_media"

    #Default ESDE Theme
    setSetting esdeThemeUrl "$(jq .themeESDE[0] $json)"
    setSetting esdeThemeName "$(jq .themeESDE[1] $json)"

    #Default Pegasus Theme
    setSetting pegasusThemeUrl "$(jq .themePegasus[0] $json)"
    setSetting pegasusThemeName "$(jq .themePegasus[1] $json)"

    #RetroAchiviements
    setSetting achievementsUser "$(jq .achievements.user $json)"
    setSetting achievementsUserToken "$(jq .achievements.token $json)"
    setSetting achievementsHardcore "$(jq .achievements.hardcore $json)"

    #Android
    setSetting androidStorage "$(jq .android.storage $json)"
    setSetting androidStoragePath "$(jq .android.storagePath $json)"
    setSetting androidInstallRA "$(jq .android.installEmus.ra.status $json)"
    setSetting androidInstallDolphin "$(jq .android.installEmus.dolphin.status $json)"
    setSetting androidInstallPPSSPP "$(jq .android.installEmus.ppsspp.status $json)"
    setSetting androidInstallCitraMMJ "$(jq .android.installEmus.citrammj.status $json)"
    setSetting androidInstallLime3DS "$(jq .android.installEmus.lime3ds.status $json)"
    setSetting androidInstallNetherSX2 "$(jq .android.installEmus.nethersx2.status $json)"
    setSetting androidInstallScummVM "$(jq .android.installEmus.scummvm.status $json)"

    setSetting androidSetupRA "$(jq .android.overwriteConfigEmus.ra.status $json)"
    setSetting androidSetupDolphin "$(jq .android.overwriteConfigEmus.dolphin.status $json)"
    setSetting androidSetupPPSSPP "$(jq .android.overwriteConfigEmus.ppsspp.status $json)"
    setSetting androidSetupCitraMMJ "$(jq .android.overwriteConfigEmus.citrammj.status $json)"
    setSetting androidSetupLime3DS "$(jq .android.overwriteConfigEmus.lime3ds.status $json)"
    setSetting androidSetupNetherSX2 "$(jq .android.overwriteConfigEmus.nethersx2.status $json)"
    setSetting androidSetupScummVM "$(jq .android.overwriteConfigEmus.scummvm.status $json)"

    setSetting androidInstallESDE "$(jq .android.installFrontends.esde.status $json)"
    setSetting androidInstallPegasus "$(jq .android.installFrontends.pegasus.status $json)"
    setSetting androidRABezels "$(jq .android.bezels $json)"


    #We store the patreon token on install so we can create it for the first time
    storePatreonToken "$(jq .patreonToken $json)"
}