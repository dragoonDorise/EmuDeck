from core.all import *

def azahar_install():
    set_msg(f"Installing azahar")

    if system == "linux":
        type="tar.gz"
        look_for="appimage"
        path=emus_folder

    if system.startswith("win"):
        type="zip"
        look_for="msvc"
        path=f"{emus_folder}/azahar"

    if system == "darwin":
        type="zip"
        look_for="macos"
        path=emus_folder

    try:
        repo=get_latest_release_gh("azahar-emu/azahar",type,look_for)
        install_emu("Azahar", repo, type, path)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def azahar_uninstall():
    try:
        if system == "linux":
            uninstall_emu("azahar", "AppImage")
        if system.startswith("win"):
          uninstall_emu("Azahar", "dir")
        if system == "darwin":
          uninstall_emu("Azahar", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def azahar_is_installed():
    if system == "linux":
        return (emus_folder / "azahar.AppImage").exists()
    if system.startswith("win"):
      return (emus_folder / "azahar" / "azahar.exe").exists()
    if system == "darwin":
      return (emus_folder / "azahar.app").exists()


def azahar_init():
    set_msg(f"Setting up Azahar")
    if system == "linux":
        destination=f"{home}/.config/azahar/config"
    if system.startswith("win"):
        destination=f"{emus_folder}/azahar/"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/azahar/"

    copy_and_set_settings_file(f"{system}/azahar/qt-config.ini", destination)

    azahar_setup_saves()
    azahar_set_resolution()
    azahar_set_controller_style()
    esde_set_emu("Azahar (Standalone)","n3ds")
    azahar_add_custom_parser()

def azahar_install_init():
    azahar_install()
    azahar_init()

def azahar_add_custom_parser():
    if azahar_is_installed():
        add_parser("nintendo_3ds_azahar")


def azahar_setup_saves():
    if system == "linux":
        origin_saves=f"{home}/.share/azahar/sdmc"
        origin_states=f"{home}/.local/share/azahar-emu/states"
    if system.startswith("win"):
        origin_saves=f"{emus_folder}/azahar/sdmc"
        origin_states=f"{emus_folder}/azahar/states"
    if system == "darwin":
        origin_saves=f"{home}/.share/azahar/sdmc"
        origin_states=f"{home}/.local/share/azahar-emu/states"

    move_contents_and_link(origin_saves,f"{saves_path}/azahar/saves")
    move_contents_and_link(origin_states,f"{saves_path}/azahar/states")


def azahar_set_resolution() -> bool:
    return True
    if system == "linux":
        azahar_config_file="~/.config/azahar/config/qt-config.ini"
    if system.startswith("win"):
        azahar_config_file=f"{emus_folder}/azahar/qt-config.ini"
    if system == "darwin":
        azahar_config_file="~/.config/azahar/qt-config.ini"

    resolution_map = {
        "720P": 3,
        "1080P": 5,
        "1440P": 6,
        "4K": 9,
    }

    # Normalize config file path
    config_path = Path(azahar_config_file)

    # Find the multiplier
    multiplier = resolution_map.get(settings.resolutions.citra)
    if multiplier is None:
        print(f"Error: unsupported resolution '{settings.resolutions.citra}'")
        return False

    set_config("resolution_factor", multiplier, config_path)

    return True

def azahar_set_abxy_style():
    print("NYI")

def azahar_set_bayx_style():
    print("NYI")

def azahar_set_controller_style():
    if settings.controllerLayout == "bayx":
        azahar_set_bayx_style()
    else:
        azahar_set_bayx_style()
