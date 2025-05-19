from core.all import *


def citron_install():
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
    if system == "linux":
        destination=f"{home}/.config/citron/config"
    if system.startswith("win"):
        destination=f"{emus_folder}/citron/"
    if system == "darwin":
       return False

    copy_setting_dir(f"{system}/citron/",destination)
    copy_and_set_settings_file(f"{system}/citron/config/citron/qt-config.ini", destination)


    citron_setup_saves()
    citron_setup_storage()
    citron_set_resolution()
    citron_set_controller_style()

    esde_set_emu("Citron (Standalon)","switch")
    citron_add_custom_parser()

def citron_add_custom_parser():
    if citron_is_installed():
        add_parser("nintendo_switch_citron")


def citron_setup_saves():
    if system == "linux":
        origin_saves=f"{home}/.share/citron/sdmc"
        origin_states=f"{home}/.local/share/citron-emu/states"
    if system.startswith("win"):
        origin_saves=f"{emus_folder}/citron/sdmc"
        origin_states=f"{emus_folder}/citron/states"
    if system == "darwin":
        origin_saves=f"{home}/.share/citron/sdmc"
        origin_states=f"{home}/.local/share/citron-emu/states"

    move_contents_and_link(origin_saves,f"{saves_path}/citron/saves")
    move_contents_and_link(origin_states,f"{saves_path}/citron/states")


def citron_set_resolution():
    print("NYI")

def citron_set_abxy_style():
    print("NYI")

def citron_set_bayx_style():
    print("NYI")

def citron_set_controller_style():
    if settings.controllerLayout == "bayx":
        citron_set_bayx_style()
    else:
        citron_set_bayx_style()