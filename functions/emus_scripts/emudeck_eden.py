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
        destination = f"{home}/.config/eden"
    elif system.startswith("win"):
        destination = str(emus_folder / "eden-windows-msvc" / "user" / "config")
    if system == "darwin":
       return False
    plugins_install_steamdeck_gyro_dsu()
    copy_setting_dir("common/eden/", destination)
    copy_and_set_settings_file("common/eden/qt-config.ini",destination)


    eden_setup_saves()
    eden_setup_storage()
    eden_set_resolution()
    eden_set_controller_style()

    esde_set_emu("Eden (Standalone)","switch")
    eden_add_custom_parser()
    create_app_shortcut("eden")

def eden_add_custom_parser():
    if eden_is_installed() and srm_is_installed():
        add_parser("nintendo_switch_eden")


def eden_setup_saves():
    if system == "linux":
        origin_saves=f"{home}/.share/eden/sdmc"
        origin_states=f"{home}/.local/share/eden-emu/states"
    if system.startswith("win"):
        origin_saves = str(emus_folder / "eden-windows-msvc" / "user" / "sdmc")
        origin_states = str(emus_folder / "eden-windows-msvc" / "user" / "states")
    if system == "darwin":
        origin_saves=f"{home}/.share/eden/sdmc"
        origin_states=f"{home}/.local/share/eden-emu/states"

    for origin, destination in ((origin_saves, f"{saves_path}/eden/saves"), (origin_states, f"{saves_path}/eden/states")):
        origin_path = Path(origin)

        if origin_path.is_symlink():
            continue

        origin_path.mkdir(parents=True, exist_ok=True)
        move_contents_and_link(str(origin_path), destination)
        
def eden_setup_storage():
    set_msg("Setting up Eden storage")
    eden_storage = Path(storage_path) / "eden"

    for directory in ("dump", "load", "sdmc", "nand", "screenshots", "tas"):
        (eden_storage / directory).mkdir(parents=True, exist_ok=True)

    if system == "linux":
        origin_profiles = eden_storage / "nand" / "system" / "save" / "8000000000000010" / "su" / "avators"
        origin_profiles.mkdir(parents=True, exist_ok=True)
        move_contents_and_link(str(origin_profiles), f"{saves_path}/eden/profiles")

    return True

def eden_set_resolution():
    if system == "linux":
        config_path = f"{home}/.config/eden/qt-config.ini"
    if system.startswith("win"):
        config_path = emus_folder / "eden-windows-msvc" / "user" / "config" / "qt-config.ini"
    if system == "darwin":
        config_path = f"{home}/Library/Application Support/eden/config/qt-config.ini"
    else:
        return False

    resolution_map = {
        "720P": (3, 0),
        "1080P": (3, 1),
        "1440P": (6, 0),
        "4K": (6, 1),
    }

    resolution = settings.resolutions.eden
    multiplier, docked = resolution_map.get(resolution, (3, 0))

    if resolution == "4K" and system == "linux" and get_screen_width() < 3840:
        multiplier, docked = 3, 1

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