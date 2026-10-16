#!/usr/bin/env bash
Cemu_install(){ py_run cemu_install; }
Cemu_init(){ py_run cemu_init; }
Cemu_resetConfig(){ py_run cemu_init; }
Cemu_uninstall(){ py_run cemu_uninstall; }
Cemu_IsInstalled(){ py_run cemu_is_installed; }
Cemu_setEmulationFolder(){ py_run cemu_set_emulation_folder; }
Cemu_setupSaves(){ py_run cemu_setup_saves; }
Cemu_setupStorage(){ py_run cemu_setup_storage; }
Cemu_setLanguage(){ py_run cemu_set_language; }
Cemu_setResolution(){ py_run cemu_set_resolution; }
Cemu_setABXYstyle(){ py_run cemu_set_abxy_style; }
Cemu_setBAYXstyle(){ py_run cemu_set_bayx_style; }
Cemu_setControllers(){ py_run cemu_set_controllers; }
Cemu_launch_fixes(){ py_run cemu_launch_fixes; }
Cemu_flushEmulatorLauncher(){ py_run flush_emulator_launchers cemu; }
Cemu_addSteamInputProfile(){ py_run cemu_add_steam_input_profile; }
Cemu_addToSteam(){ py_run cemu_add_to_steam; }
