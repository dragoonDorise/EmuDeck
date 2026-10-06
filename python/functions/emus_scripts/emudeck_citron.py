from core.all import *


def citron_install():
    stat_install("citron")
    set_msg(f"Installing citron")
    return False

def citron_uninstall():
    return False

def citron_is_installed():
    if system == "linux":
        return (emus_folder / "citron.AppImage").exists()
    if system.startswith("win"):
      return (emus_folder / "citron" /"citron.exe").exists()
    if system == "darwin":
      return False


def citron_init():
    set_msg(f"Setting up citron")
    flush_emulator_launchers("citron")
    if system == "linux":
        copy_setting_dir("linux/citron/config/", f"{home}/.config/citron")
        copy_setting_dir("linux/citron/data/", f"{home}/.local/share/citron")
        copy_and_set_settings_file("linux/citron/config/qt-config.ini", f"{home}/.config/citron")
    if system.startswith("win"):
        destination=f"{emus_folder}/citron/"
        copy_setting_dir(f"{system}/citron/",destination)
        copy_and_set_settings_file(f"{system}/citron/config/citron/qt-config.ini", destination)
    if system == "darwin":
       return False
    plugins_install_steamdeck_gyro_dsu()


    citron_set_emulation_folder()
    citron_setup_saves()
    citron_setup_storage()
    citron_set_resolution()
    citron_set_controller_style()

    if esde_is_installed():
        esde_set_emu("Citron (Standalone)","switch")
    create_app_shortcut("citron", "Citron (AppImage)", False)
    citron_add_custom_parser()

def citron_add_custom_parser():
    if citron_is_installed() and srm_is_installed():
        add_parser("nintendo_switch_citron")


def citron_set_emulation_folder():
    if system == "linux":
        config_file = home / ".config" / "citron" / "qt-config.ini"
        if config_file.is_file():
            storage = f"{storage_path}/citron"
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
        origin_keys=f"{home}/.local/share/citron/keys"
        origin_firmware=f"{home}/.local/share/citron/nand/system/Contents/registered"
    elif system.startswith("win"):
        user=f"{emus_folder}/citron/user"
        origin_keys=f"{user}/keys"
        origin_firmware=f"{user}/nand/system/Contents/registered"
        origin_dlc=f"{user}/nand/user/Contents/registered"
    else:
        return False

    link_to_bios_folder(origin_keys, "citron/keys")
    link_to_bios_folder(origin_firmware, "citron/firmware")
    if system.startswith("win"):
        link_to_storage_folder(origin_dlc, "citron/storage")
    return True


def citron_setup_saves():
    if system == "linux":
        nand=f"{storage_path}/citron/nand"
    elif system.startswith("win"):
        nand=f"{emus_folder}/citron/user/nand"
    else:
        return False
    origin_saves=f"{nand}/user/save"
    origin_profiles=f"{nand}/system/save/8000000000000010/su/avators"

    link_to_saves_folder(origin_saves, "citron/saves")
    link_to_saves_folder(origin_profiles, "citron/profiles")
    return True


def citron_setup_storage():
    set_msg("Setting up citron storage")
    for folder in ("dump", "load", "sdmc", "nand", "screenshots", "tas"):
        Path(f"{storage_path}/citron/{folder}").mkdir(parents=True, exist_ok=True)
    return True


def citron_set_resolution():
    if system == "linux":
        config_path = f"{home}/.config/citron/qt-config.ini"
    if system.startswith("win"):
        config_path = f"{emus_folder}/citron/qt-config.ini"
    if system == "darwin":
        config_path = f"{home}/Library/Application Support/citron/config/qt-config.ini"

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

def citron_set_abxy_style():
    print("NYI")

def citron_set_bayx_style():
    print("NYI")

def citron_set_controller_style():
    if settings.controllerLayout == "bayx":
        citron_set_bayx_style()
    else:
        citron_set_bayx_style()

def citron_add_to_steam():
    set_msg("Adding Citron to Steam")
    launcher = tools_path / "launchers" / ("citron.bat" if system.startswith("win") else "citron.sh")
    add_steam_shortcut("citron", "Citron", str(launcher), str(emus_folder), str(icons_path / "ico/citron.ico"))
