from core.all import *

def azahar_install():
    set_msg(f"Installing azahar")

    if system == "linux":
        type="AppImage"
        look_for="AppImage"
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
        install_emu("azahar", repo, type, path)
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
    flush_emulator_launchers("azahar")
    if system == "linux":
        destination=f"{home}/.config/azahar-emu"
    if system.startswith("win"):
        destination = f"{emus_folder}/azahar/user/config"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/azahar/"

    copy_and_set_settings_file(f"{system}/azahar/qt-config.ini", destination)

    azahar_set_emulation_folder()
    azahar_setup_saves()
    azahar_set_resolution()
    azahar_set_controller_style()
    esde_set_emu("Azahar (Standalone)","n3ds")
    azahar_add_custom_parser()

def azahar_install_init():
    azahar_install()
    azahar_init()

def azahar_add_custom_parser():
    if azahar_is_installed() and srm_is_installed():
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


def azahar_config_file():
    if system == "linux":
        return Path(f"{home}/.config/azahar-emu/qt-config.ini")
    if system.startswith("win"):
        return Path(f"{emus_folder}/azahar/qt-config.ini")
    if system == "darwin":
        return Path(f"{home}/Library/Application Support/azahar/qt-config.ini")


def azahar_set_emulation_folder() -> bool:
    config_file = azahar_config_file()

    if not config_file.is_file():
        return False

    Path(f"{storage_path}/azahar/screenshots").mkdir(parents=True, exist_ok=True)

    set_config("Paths\\gamedirs\\3\\path", f"{roms_path}/n3ds", config_file)
    set_config("nand_directory", f"{storage_path}/azahar/nand/", config_file)
    set_config("sdmc_directory", f"{storage_path}/azahar/sdmc/", config_file)
    set_config("Paths\\screenshotPath", f"{storage_path}/azahar/screenshots/", config_file)

    set_config("nand_directory\\default", "false", config_file)
    set_config("sdmc_directory\\default", "false", config_file)
    set_config("use_custom_storage", "true", config_file)
    set_config("use_custom_storage\\default", "false", config_file)

    return True


def azahar_set_resolution() -> bool:
    if system == "linux":
        config_path = f"{home}/.config/azahar-emu/qt-config.ini"
    elif system.startswith("win"):
        config_path = f"{emus_folder}/azahar/user/config/qt-config.ini"
    else:
        return False

    resolution_map = {
        "720P": 3,
        "1080P": 5,
        "1440P": 6,
        "4K": 9,
    }

    resolution = settings.resolutions.azahar
    multiplier = resolution_map.get(resolution, 3)

    if resolution == "4K" and system == "linux" and get_screen_width() < 3840:
        multiplier = 5

    set_ini_value(config_path, "Renderer", "resolution_factor", str(multiplier))
    set_ini_value(config_path, "Renderer", r"resolution_factor\default", "false")

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
