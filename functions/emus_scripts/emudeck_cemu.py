from core.all import *


def cemu_install():
    set_msg(f"Installing Cemu")

    if system == "linux":
        type="AppImage"
        look_for=""
        destination = emus_folder
        name="Cemu"

    if system.startswith("win"):
        type="zip"
        look_for="windows-x64"
        destination = f"{emus_folder}/cemu"
        name="cemu"

    if system == "darwin":
        type="dmg"
        look_for="macos"
        destination = emus_folder
        name="Cemu"

    try:
        repo=get_latest_release_gh("cemu-project/Cemu",type,look_for)
        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def cemu_uninstall():
    try:
        if system == "linux":
            uninstall_emu("Cemu", "AppImage")
        if system.startswith("win"):
          uninstall_emu("cemu", "dir")
        if system == "darwin":
          uninstall_emu("Cemu", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def cemu_is_installed():
    if system == "linux":
        return (emus_folder / "Cemu.AppImage").exists()
    if system.startswith("win"):
      return (emus_folder / "cemu" / "cemu.exe").exists()
    if system == "darwin":
      return (emus_folder / "Cemu.app").exists()


def cemu_init():
    set_msg(f"Setting up cemu")
    if system == "linux":
        destination=f"{home}/.config/Cemu"
        settings_file_src=f"{system}/cemu/settings.xml"
    if system.startswith("win"):
        destination=f"{emus_folder}/cemu"
        settings_file_src=f"{system}/cemu/settings.xml"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/Cemu/"
        settings_file_src=f"{system}/Cemu/settings.xml"

    copy_setting_dir(f"{system}/cemu/",destination)

    copy_and_set_settings_file(settings_file_src, destination)

    plugins_install_steamdeck_gyro_dsu()
    cemu_setup_saves()
    cemu_setup_storage()
    cemu_set_resolution()
    cemu_set_controller_style()

def cemu_install_init():
    cemu_install()
    cemu_init()


def cemu_setup_saves():
    if system == "linux":
        origin_saves=f"{roms_path}/wiiu/mlc01/usr/save"
    if system.startswith("win"):
        origin_saves=f"{emus_folder}/cemu/mlc01/usr/save"
    if system == "darwin":
        origin_saves=f"{home}/Library/Application Support/Cemu/mlc01/usr/save"

    move_contents_and_link(origin_saves,f"{saves_path}/Cemu/saves")

def cemu_setup_storage():
    print("NYI")

def cemu_set_resolution():
    print("NYI")

def cemu_set_abxy_style():
    print("NYI")

def cemu_set_bayx_style():
    print("NYI")

def cemu_set_controller_style():
    if settings.controllerLayout == "bayx":
        cemu_set_bayx_style()
    else:
        cemu_set_bayx_style()