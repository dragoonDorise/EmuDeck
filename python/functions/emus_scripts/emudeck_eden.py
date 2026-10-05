from core.all import *


def eden_install():
    set_msg(f"Installing eden")
    return False

def eden_uninstall():
    return False

def eden_is_installed():
    if system == "linux":
        return (emus_folder / "eden.AppImage").exists()
    if system.startswith("win"):
      return (emus_folder / "eden-windows-msvc" /"eden.exe").exists()
    if system == "darwin":
      return False


def eden_init():
    set_msg(f"Setting up eden")
    flush_emulator_launchers("eden")
    if system == "linux":
        copy_setting_dir("linux/eden/config/", f"{home}/.config/eden")
        copy_setting_dir("linux/eden/data/", f"{home}/.local/share/eden")
        copy_and_set_settings_file("linux/eden/config/qt-config.ini", f"{home}/.config/eden")
    elif system.startswith("win"):
        destination = str(emus_folder / "eden-windows-msvc" / "user" / "config")
        copy_setting_dir("common/eden/", destination)
        copy_and_set_settings_file("common/eden/qt-config.ini",destination)
    if system == "darwin":
       return False
    plugins_install_steamdeck_gyro_dsu()


    eden_set_emulation_folder()
    eden_setup_saves()
    eden_setup_storage()
    eden_set_resolution()
    eden_set_controller_style()

    if esde_is_installed():
        esde_set_emu("Eden (Standalone)","switch")
    eden_add_custom_parser()
    create_app_shortcut("eden", "Eden (AppImage)", False)
    if esde_is_installed():
        eden_add_es_config()

def eden_add_custom_parser():
    if eden_is_installed() and srm_is_installed():
        add_parser("nintendo_switch_eden")


def eden_setup_saves():
    if system == "linux":
        nand=f"{storage_path}/eden/nand"
    elif system.startswith("win"):
        nand=f"{emus_folder}/eden-windows-msvc/user/nand"
    else:
        return False
    origin_saves=f"{nand}/user/save"
    origin_profiles=f"{nand}/system/save/8000000000000010/su/avators"

    link_to_saves_folder(origin_saves, "eden/saves")
    link_to_saves_folder(origin_profiles, "eden/profiles")
    return True


def eden_setup_storage():
    set_msg("Setting up eden storage")
    for folder in ("dump", "load", "sdmc", "nand", "screenshots", "tas"):
        Path(f"{storage_path}/eden/{folder}").mkdir(parents=True, exist_ok=True)
    return True


def eden_set_resolution():
    if system == "linux":
        config_path = f"{home}/.config/eden/qt-config.ini"
    elif system.startswith("win"):
        config_path = emus_folder / "eden-windows-msvc" / "user" / "config" / "qt-config.ini"
    elif system == "darwin":
        config_path = f"{home}/Library/Application Support/eden/config/qt-config.ini"
    else:
        return False

    resolution_map = {
        "720P": (3, 0),
        "1080P": (3, 1),
        "1440P": (6, 0),
        "4K": (6, 1),
    }

    resolution = settings.resolutions.yuzu
    multiplier, docked = resolution_map.get(resolution, (3, 0))

    if resolution == "4K" and system == "linux" and get_screen_width() < 3840:
        multiplier, docked = 2, 1

    set_ini_value(config_path, "Renderer", "resolution_setup", str(multiplier))
    set_ini_value(config_path, "Renderer", r"resolution_setup\default", "false")
    set_ini_value(config_path, "System", "use_docked_mode", str(docked))
    set_ini_value(config_path, "System", r"use_docked_mode\default", "false")

    return True

def eden_set_abxy_style():
    print("NYI")

def eden_set_bayx_style():
    print("NYI")

def eden_set_controller_style():
    if settings.controllerLayout == "bayx":
        eden_set_bayx_style()
    else:
        eden_set_abxy_style()

def eden_add_to_steam():
    set_msg("Adding Eden to Steam")
    launcher = tools_path / "launchers" / ("eden.bat" if system.startswith("win") else "eden.sh")
    add_steam_shortcut("eden", "Eden", str(launcher), str(emus_folder), str(icons_path / "ico/eden.ico"))


def eden_add_es_config():
    return esde_add_custom_systems_file()


def eden_set_emulation_folder():
    if system == "linux":
        config_file = home / ".config" / "eden" / "qt-config.ini"
        if config_file.is_file():
            storage = f"{storage_path}/eden"
            for key, value in (
                ("Screenshots\\screenshot_path", f"{storage}/screenshots"),
                ("Paths\\gamedirs\\4\\path", f"{roms_path}/switch"),
                ("dump_directory", f"{storage}/dump"),
                ("load_directory", f"{storage}/load"),
                ("nand_directory", f"{storage}/nand"),
                ("sdmc_directory", f"{storage}/sdmc"),
                ("tas_directory", f"{storage}/tas"),
            ):
                set_config(key, value, config_file)
        origin_keys=f"{home}/.local/share/eden/keys"
        origin_firmware=f"{home}/.local/share/eden/nand/system/Contents/registered"
    elif system.startswith("win"):
        user=f"{emus_folder}/eden-windows-msvc/user"
        origin_keys=f"{user}/keys"
        origin_firmware=f"{user}/nand/system/Contents/registered"
        origin_dlc=f"{user}/nand/user/Contents/registered"
    else:
        return False

    link_to_bios_folder(origin_keys, "eden/keys")
    link_to_bios_folder(origin_firmware, "eden/firmware")
    if system.startswith("win"):
        link_to_storage_folder(origin_dlc, "eden/storage")
    return True


def eden_set_language():
    if system != "linux":
        return False
    languages = {"ja": 0, "en": 1, "fr": 2, "de": 3, "it": 4, "es": 5, "zh": 6, "ko": 7, "nl": 8, "pt": 9, "ru": 10, "tw": 11}
    regions = {"ja": 0, "en": 1, "fr": 2, "de": 2, "it": 2, "es": 2, "zh": 4, "ko": 5, "nl": 2, "pt": 2, "ru": 2, "tw": 6}
    config_file = home / ".config" / "eden" / "qt-config.ini"
    language = get_system_language()
    if not config_file.is_file() or language not in languages:
        return False
    set_config("language_index", str(languages[language]), config_file)
    set_config("language_index\\default", "false", config_file)
    set_config("region_index", str(regions[language]), config_file)
    set_config("region_index\\default", "false", config_file)
    return True
