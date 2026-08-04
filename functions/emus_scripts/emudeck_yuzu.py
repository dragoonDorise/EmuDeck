from core.all import *


def yuzu_install():
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
    if system == "linux":
        destination=f"{home}/.config/yuzu/config"
    if system.startswith("win"):
        destination=f"{emus_folder}/yuzu/"
    if system == "darwin":
       return False

    copy_setting_dir(f"{system}/yuzu/",destination)
    copy_and_set_settings_file(f"{system}/yuzu/config/yuzu/qt-config.ini", destination)
    plugins_install_steamdeck_gyro_dsu()
    yuzu_setup_saves()
    yuzu_setup_storage()
    yuzu_set_resolution()
    yuzu_set_controller_style()
    esde_set_emu("Yuzu (Standalone)","switch")
    yuzu_add_custom_parser()

def yuzu_add_custom_parser():
    if yuzu_is_installed():
        add_parser("nintendo_switch_yuzu")



def yuzu_setup_saves():
    if system == "linux":
        origin_saves=f"{home}/.share/yuzu/sdmc"
        origin_states=f"{home}/.local/share/yuzu-emu/states"
    if system.startswith("win"):
        origin_saves=f"{emus_folder}/yuzu/sdmc"
        origin_states=f"{emus_folder}/yuzu/states"
    if system == "darwin":
        origin_saves=f"{home}/.share/yuzu/sdmc"
        origin_states=f"{home}/.local/share/yuzu-emu/states"

    move_contents_and_link(origin_saves,f"{saves_path}/yuzu/saves")
    move_contents_and_link(origin_states,f"{saves_path}/yuzu/states")


def yuzu_set_resolution():
    if system == "linux":
        config_path = f"{home}/.config/yuzu/config/qt-config.ini"
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