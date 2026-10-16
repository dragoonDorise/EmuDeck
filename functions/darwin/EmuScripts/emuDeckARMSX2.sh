#!/usr/bin/env bash
ARMSX2_install(){ py_run armsx2_install; }
ARMSX2_init(){ py_run armsx2_init; }
ARMSX2_resetConfig(){ py_run armsx2_init; }
ARMSX2_uninstall(){ py_run armsx2_uninstall; }
ARMSX2_IsInstalled(){ py_run armsx2_is_installed; }
ARMSX2_setEmulationFolder(){ py_run armsx2_set_emulation_folder; }
ARMSX2_setupSaves(){ py_run armsx2_setup_saves; }
ARMSX2_setupStorage(){ py_run armsx2_setup_storage; }
ARMSX2_setupControllers(){ py_run armsx2_setup_controllers; }
ARMSX2_setResolution(){ py_run armsx2_set_resolution; }
ARMSX2_wideScreenOn(){ py_run armsx2_widescreen_on; }
ARMSX2_wideScreenOff(){ py_run armsx2_widescreen_off; }
ARMSX2_retroAchievementsOn(){ py_run armsx2_retro_achievements_on; }
ARMSX2_retroAchievementsOff(){ py_run armsx2_retro_achievements_off; }
ARMSX2_setRetroAchievements(){ py_run armsx2_retro_achievements; }
ARMSX2_addParser(){ py_run armsx2_add_custom_parser; }
ARMSX2_flushEmulatorLauncher(){ py_run flush_emulator_launchers armsx2; }
ARMSX2_addToSteam(){ py_run armsx2_add_to_steam; }
