from core.all import *

armsx2_config_file = Path(f"{home}/.config/ARMSX2/inis/PCSX2.ini")


def armsx2_supported():
    return system == "linux" and cpu_arch == "arm"


def armsx2_install():
    if not armsx2_supported():
        return False
    set_msg("Installing ARMSX2")
    try:
        repo = get_latest_prerelease_gh("ARMSX2/ARMSX2", "AppImage", "4K-pages")
        if not repo:
            print("No ARMSX2 AppImage found")
            return False
        install_emu("armsx2", repo, "AppImage", emus_folder)
        return armsx2_is_installed()
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def armsx2_uninstall():
    if not armsx2_supported():
        return False
    try:
        uninstall_emu("armsx2", "AppImage")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False


def armsx2_is_installed():
    if not armsx2_supported():
        return False
    return (emus_folder / "armsx2.AppImage").exists()


def armsx2_init():
    if not armsx2_supported():
        return False
    set_msg("Setting up ARMSX2")

    if armsx2_config_file.exists():
        armsx2_config_file.replace(armsx2_config_file.with_suffix(".ini.bak"))

    generated = False
    try:
        generated = subprocess.run([str(emus_folder / "armsx2.AppImage"), "-testconfig"], check=False).returncode == 0
    except Exception:
        generated = False
    if not generated or not armsx2_config_file.exists():
        copy_and_set_settings_file("common/armsx2/.config/ARMSX2/inis/PCSX2.ini", armsx2_config_file.parent)

    armsx2_set_emulation_folder()
    armsx2_setup_storage()
    armsx2_setup_controllers()
    armsx2_retro_achievements()
    armsx2_set_resolution()
    armsx2_widescreen()
    flush_emulator_launchers("armsx2")
    armsx2_add_custom_parser()
    armsx2_add_es_config()
    move_contents_and_link(f"{home}/.config/ARMSX2/cheats", f"{storage_path}/pcsx2/cheats")
    return True


def armsx2_install_init():
    if not armsx2_install():
        return False
    return armsx2_init()


def armsx2_set_emulation_folder():
    set_ini_value(armsx2_config_file, "UI", "ConfirmShutdown", "false")
    set_ini_value(armsx2_config_file, "UI", "SetupWizardIncomplete", "false")
    set_ini_value(armsx2_config_file, "UI", "StartFullscreen", "true")
    set_ini_value(armsx2_config_file, "Folders", "Bios", f"{bios_path}")
    set_ini_value(armsx2_config_file, "Folders", "Snapshots", f"{storage_path}/armsx2/snaps")
    set_ini_value(armsx2_config_file, "Folders", "SaveStates", f"{saves_path}/pcsx2/states")
    set_ini_value(armsx2_config_file, "Folders", "MemoryCards", f"{saves_path}/pcsx2/saves")
    set_ini_value(armsx2_config_file, "Folders", "Cache", f"{storage_path}/armsx2/cache")
    set_ini_value(armsx2_config_file, "Folders", "Covers", f"{storage_path}/armsx2/covers")
    set_ini_value(armsx2_config_file, "Folders", "Textures", f"{storage_path}/armsx2/textures")
    set_ini_value(armsx2_config_file, "GameList", "RecursivePaths", f"{roms_path}/ps2")


def armsx2_setup_storage():
    for folder in ("snaps", "cache", "textures", "covers"):
        Path(f"{storage_path}/armsx2/{folder}").mkdir(parents=True, exist_ok=True)


def armsx2_setup_controllers():
    pad1 = {
        "Type": "DualShock2", "InvertL": "0", "InvertR": "0", "Deadzone": "0.000000", "AxisScale": "1.330000",
        "TriggerDeadzone": "0", "TriggerScale": "1", "LargeMotorScale": "1.000000", "SmallMotorScale": "1.000000",
        "ButtonDeadzone": "0", "PressureModifier": "0.300000",
        "Up": "SDL-0/DPadUp", "Right": "SDL-0/DPadRight", "Down": "SDL-0/DPadDown", "Left": "SDL-0/DPadLeft",
        "Triangle": "SDL-0/Y", "Circle": "SDL-0/B", "Cross": "SDL-0/A", "Square": "SDL-0/X",
        "Select": "SDL-0/Back", "Start": "SDL-0/Start", "L1": "SDL-0/LeftShoulder", "L2": "SDL-0/+LeftTrigger",
        "R1": "SDL-0/RightShoulder", "R2": "SDL-0/+RightTrigger", "L3": "SDL-0/LeftStick", "R3": "SDL-0/RightStick",
        "LUp": "SDL-0/-LeftY", "LRight": "SDL-0/+LeftX", "LDown": "SDL-0/+LeftY", "LLeft": "SDL-0/-LeftX",
        "RUp": "SDL-0/-RightY", "RRight": "SDL-0/+RightX", "RDown": "SDL-0/+RightY", "RLeft": "SDL-0/-RightX",
        "SmallMotor": "SDL-0/SmallMotor", "LargeMotor": "SDL-0/LargeMotor", "Analog": "Keyboard/F6", "Pressure": "Keyboard/S",
    }
    pad2 = {
        "Type": "DualShock2", "Deadzone": "0.000000", "AxisScale": "1.330000", "LargeMotorScale": "1.000000",
        "SmallMotorScale": "1.000000", "PressureModifier": "0.300000",
        "Up": "SDL-1/DPadUp", "Right": "SDL-1/DPadRight", "Down": "SDL-1/DPadDown", "Left": "SDL-1/DPadLeft",
        "Triangle": "SDL-1/Y", "Circle": "SDL-1/B", "Cross": "SDL-1/A", "Square": "SDL-1/X",
        "Select": "SDL-1/Back", "Start": "SDL-1/Start", "L1": "SDL-1/LeftShoulder", "L2": "SDL-1/+LeftTrigger",
        "R1": "SDL-1/RightShoulder", "R2": "SDL-1/+RightTrigger", "L3": "SDL-1/LeftStick", "R3": "SDL-1/RightStick",
        "Analog": "SDL-1/Guide", "LUp": "SDL-1/-LeftY", "LRight": "SDL-1/+LeftX", "LDown": "SDL-1/+LeftY", "LLeft": "SDL-1/-LeftX",
        "RUp": "SDL-1/-RightY", "RRight": "SDL-1/+RightX", "RDown": "SDL-1/+RightY", "RLeft": "SDL-1/-RightX",
        "LargeMotor": "SDL-1/LargeMotor", "SmallMotor": "SDL-1/SmallMotor",
    }
    hotkeys = {
        "ToggleFullscreen": "SDL-0/Start & SDL-0/LeftStick", "CycleInterlaceMode": "Keyboard/F5", "CycleMipmapMode": "Keyboard/Insert",
        "GSDumpMultiFrame": "Keyboard/Control & Keyboard/Shift & Keyboard/F8", "Screenshot": "Keyboard/F8",
        "GSDumpSingleFrame": "Keyboard/Shift & Keyboard/F8", "ZoomIn": "Keyboard/Control & Keyboard/Plus",
        "ZoomOut": "Keyboard/Control & Keyboard/Minus", "InputRecToggleMode": "Keyboard/Shift & Keyboard/R",
        "LoadStateFromSlot": "SDL-0/Back & SDL-0/LeftShoulder", "SaveStateToSlot": "SDL-0/Back & SDL-0/RightShoulder",
        "ShutdownVM": "SDL-0/Back & SDL-0/Start", "ToggleFrameLimit": "Keyboard/F4", "TogglePause": "SDL-0/Back & SDL-0/A",
        "ToggleSlowMotion": "SDL-0/Back & SDL-0/+LeftTrigger", "ToggleTurbo": "SDL-0/Back & SDL-0/+RightTrigger",
        "HoldTurbo": "Keyboard/Period", "ResetVM": "SDL-0/Back & SDL-0/LeftStick", "OpenPauseMenu": "SDL-0/Back & SDL-0/RightStick",
        "IncreaseUpscaleMultiplier": "SDL-0/Start & SDL-0/DPadUp", "DecreaseUpscaleMultiplier": "SDL-0/Start & SDL-0/DPadDown",
        "CycleAspectRatio": "SDL-0/Start & SDL-0/DPadRight", "ToggleSoftwareRendering": "SDL-0/Start & SDL-0/DPadLeft",
        "NextSaveStateSlot": "SDL-0/Start & SDL-0/RightShoulder", "PreviousSaveStateSlot": "SDL-0/Start & SDL-0/LeftShoulder",
    }
    for section, values in (("Hotkeys", hotkeys), ("Pad1", pad1), ("Pad2", pad2)):
        for key, value in values.items():
            set_ini_value(armsx2_config_file, section, key, value)


def armsx2_set_resolution():
    if not armsx2_supported():
        return False
    resolution_map = {"720P": 2, "1080P": 3, "1440P": 4, "4K": 6}
    resolution = settings.resolutions.pcsx2
    multiplier = resolution_map.get(resolution, 2)
    if resolution == "4K" and get_screen_width() < 3840:
        multiplier = 3
    set_config("upscale_multiplier", multiplier, armsx2_config_file, separator=" = ")
    return True


def armsx2_widescreen_on():
    set_ini_value(armsx2_config_file, "EmuCore", "EnableWideScreenPatches", "true")
    set_ini_value(armsx2_config_file, "EmuCore/GS", "AspectRatio", "16:9")


def armsx2_widescreen_off():
    set_ini_value(armsx2_config_file, "EmuCore", "EnableWideScreenPatches", "false")
    set_ini_value(armsx2_config_file, "EmuCore/GS", "AspectRatio", "Auto 4:3/3:2")


def armsx2_widescreen():
    if settings.ar.classic3d == "169":
        armsx2_widescreen_on()
    else:
        armsx2_widescreen_off()


def armsx2_retro_achievements():
    if settings.achievements.user == "":
        armsx2_retro_achievements_off()
    else:
        armsx2_retro_achievements_on()


def armsx2_retro_achievements_on():
    set_ini_value(armsx2_config_file, "Achievements", "Enabled", "true")
    set_ini_value(armsx2_config_file, "Achievements", "Username", f"{achievements_user}")
    set_ini_value(armsx2_config_file, "Achievements", "Token", f"{achievements_token}")
    set_ini_value(armsx2_config_file, "Achievements", "LoginTimestamp", f"{int(time.time())}")
    set_ini_value(armsx2_config_file, "Achievements", "ChallengeMode", "true" if achievements_hardcore else "false")


def armsx2_retro_achievements_off():
    set_ini_value(armsx2_config_file, "Achievements", "Enabled", "false")
    set_ini_value(armsx2_config_file, "Achievements", "ChallengeMode", "false")


def armsx2_add_custom_parser():
    if armsx2_is_installed() and srm_is_installed():
        add_parser("sony_ps2_armsx2")


def armsx2_add_es_config():
    if not armsx2_is_installed():
        return
    for xml in (esde_rules_file, esde_systems_file):
        if Path(xml).is_file():
            sed("<!--armsx2", "", str(xml))
            sed("armsx2-->", "", str(xml))
    gamelist = esde_settings_folder / "gamelists" / "ps2" / "gamelist.xml"
    if gamelist.is_file():
        sed("PCSX2", "ARMSX2", str(gamelist))


def armsx2_add_to_steam():
    if not armsx2_supported():
        return
    set_msg("Adding ARMSX2 to Steam")
    launcher = tools_path / "launchers" / "armsx2.sh"
    add_steam_shortcut("armsx2", "ARMSX2", str(launcher), str(emus_folder), str(emudeck_backend / "icons/armsx2.png"))
