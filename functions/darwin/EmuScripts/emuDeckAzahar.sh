#!/usr/bin/env bash
Azahar_install(){ py_run azahar_install; }
Azahar_init(){ py_run azahar_init; }
Azahar_resetConfig(){ py_run azahar_init; }
Azahar_uninstall(){ py_run azahar_uninstall; }
Azahar_IsInstalled(){ py_run azahar_is_installed; }
Azahar_setEmulationFolder(){ py_run azahar_set_emulation_folder; }
Azahar_setupSaves(){ py_run azahar_setup_saves; }
Azahar_setResolution(){ py_run azahar_set_resolution; }
Azahar_setABXYstyle(){ py_run azahar_set_abxy_style; }
Azahar_setBAYXstyle(){ py_run azahar_set_bayx_style; }
Azahar_addParser(){ py_run azahar_add_custom_parser; }
Azahar_addESConfig(){ py_run azahar_add_es_config; }
Azahar_addSteamInputProfile(){ py_run azahar_add_steam_input_profile; }
Azahar_flushEmulatorLauncher(){ py_run flush_emulator_launchers azahar; }
Azahar_addToSteam(){ py_run azahar_add_to_steam; }
