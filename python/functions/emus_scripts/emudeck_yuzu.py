from core.all import *


def yuzu_install():
    stat_install("yuzu")
    set_msg(f"Installing yuzu")
    return False

def yuzu_uninstall():
    return False

def yuzu_is_installed():
    if system == "linux":
        return (emus_folder / "yuzu.AppImage").exists()
    if system.startswith("win"):
      return (emus_folder / "yuzu"/ "yuzu.exe").exists()
    if system == "darwin":
      return False


def yuzu_init():
    set_msg(f"Setting up yuzu")
    flush_emulator_launchers("yuzu")
    if system == "linux":
        copy_setting_dir("linux/yuzu/config/yuzu/", f"{home}/.config/yuzu")
        copy_setting_dir("linux/yuzu/data/yuzu/", f"{home}/.local/share/yuzu")
        copy_and_set_settings_file("linux/yuzu/config/yuzu/qt-config.ini", f"{home}/.config/yuzu")
    if system.startswith("win"):
        destination=f"{emus_folder}/yuzu/"
        copy_setting_dir(f"{system}/yuzu/",destination)
        copy_and_set_settings_file(f"{system}/yuzu/config/yuzu/qt-config.ini", destination)
    if system == "darwin":
       return False
    plugins_install_steamdeck_gyro_dsu()
    yuzu_set_emulation_folder()
    yuzu_setup_saves()
    yuzu_setup_storage()
    yuzu_set_resolution()
    yuzu_set_controller_style()
    if esde_is_installed():
        esde_set_emu("Yuzu (Standalone)","switch")
    create_app_shortcut("yuzu", "yuzu (AppImage)", False)
    yuzu_add_custom_parser()
    if esde_is_installed():
        yuzu_add_es_config()
    yuzu_set_language()

def yuzu_add_custom_parser():
    if yuzu_is_installed() and srm_is_installed():
        add_parser("nintendo_switch_yuzu")



def yuzu_setup_saves():
    if system == "linux":
        nand=f"{storage_path}/yuzu/nand"
    elif system.startswith("win"):
        nand=f"{emus_folder}/yuzu/user/nand"
    else:
        return False
    origin_saves=f"{nand}/user/save"
    origin_profiles=f"{nand}/system/save/8000000000000010/su/avators"

    link_to_saves_folder(origin_saves, "yuzu/saves")
    link_to_saves_folder(origin_profiles, "yuzu/profiles")
    return True


def yuzu_set_resolution():
    if system == "linux":
        config_path = f"{home}/.config/yuzu/qt-config.ini"
    if system.startswith("win"):
        config_path = f"{emus_folder}/yuzu/qt-config.ini"
    if system == "darwin":
        config_path = f"{home}/Library/Application Support/yuzu/config/qt-config.ini"

    resolution_map = {
        "720P": (2, "false"),
        "1080P": (2, "true"),
        "1440P": (3, "false"),
        "4K": (3, "true"),
    }

    multiplier, docked = resolution_map.get(settings.resolutions.yuzu, (2, "false"))

    if settings.resolutions.yuzu == "4K" and system == "linux" and get_screen_width() < 3840:
        multiplier = 2
        docked = "true"

    set_config("resolution_setup", multiplier, Path(config_path))
    set_config("use_docked_mode", docked, Path(config_path))

    return True

def yuzu_set_abxy_style():
    print("NYI")

def yuzu_set_bayx_style():
    print("NYI")

def yuzu_set_controller_style():
    if settings.controllerLayout == "bayx":
        yuzu_set_bayx_style()
    else:
        yuzu_set_bayx_style()

def yuzu_add_to_steam():
    set_msg("Adding yuzu to Steam")
    launcher = tools_path / "launchers" / ("yuzu.bat" if system.startswith("win") else "yuzu.sh")
    add_steam_shortcut("yuzu", "yuzu", str(launcher), str(emus_folder), str(icons_path / "ico/yuzu.ico"))


def yuzu_add_es_config():
    return esde_add_custom_systems_file()


def yuzu_set_emulation_folder():
    if system == "linux":
        config_file = home / ".config" / "yuzu" / "qt-config.ini"
        if config_file.is_file():
            storage = f"{storage_path}/yuzu"
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
        origin_keys=f"{home}/.local/share/yuzu/keys"
        origin_firmware=f"{storage_path}/yuzu/nand/system/Contents/registered"
    elif system.startswith("win"):
        user=f"{emus_folder}/yuzu/user"
        origin_keys=f"{user}/keys"
        origin_firmware=f"{user}/nand/system/Contents/registered"
        origin_dlc=f"{user}/nand/user/Contents/registered"
    else:
        return False

    link_to_bios_folder(origin_keys, "yuzu/keys")
    link_to_bios_folder(origin_firmware, "yuzu/firmware")
    if system.startswith("win"):
        link_to_storage_folder(origin_dlc, "yuzu/storage")
    return True


def yuzu_set_language():
    if system != "linux":
        return False
    languages = {"ja": 0, "en": 1, "fr": 2, "de": 3, "it": 4, "es": 5, "zh": 6, "ko": 7, "nl": 8, "pt": 9, "ru": 10, "tw": 11}
    regions = {"ja": 0, "en": 1, "fr": 2, "de": 2, "it": 2, "es": 2, "zh": 4, "ko": 5, "nl": 2, "pt": 2, "ru": 2, "tw": 6}
    config_file = home / ".config" / "yuzu" / "qt-config.ini"
    language = get_system_language()
    if not config_file.is_file() or language not in languages:
        return False
    set_config("language_index", str(languages[language]), config_file)
    set_config("language_index\\default", "false", config_file)
    set_config("region_index", str(regions[language]), config_file)
    set_config("region_index\\default", "false", config_file)
    return True


def yuzu_setup_storage():
    set_msg("Setting up yuzu storage")
    for folder in ("dump", "load", "sdmc", "nand", "screenshots", "tas"):
        Path(f"{storage_path}/yuzu/{folder}").mkdir(parents=True, exist_ok=True)
    return True


