from core.all import *


def mame_install():
    set_msg(f"Installing mame")

    if system == "linux":
        name="org.mamedev.MAME"
        type="flatpak"
        look_for=""
        destination = f"{emus_folder}"

    if system.startswith("win"):
        name="mame"
        type="zip"
        look_for="64bit"
        destination = f"{emus_folder}/mame"

    if system == "darwin":
        return False

    try:
        repo=get_latest_release_gh("mamedev/mame",type,look_for)
        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def mame_uninstall():
    try:
        if system == "linux":
            uninstall_emu("org.mamedev.MAME", "flatpak")
        if system.startswith("win"):
          uninstall_emu("mame", "dir")
        if system == "darwin":
          uninstall_emu("mame", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def mame_is_installed():
    if system == "linux":
        return is_flatpak_installed("org.mamedev.MAME")
    if system.startswith("win"):
      return (emus_folder / "mame" / "mame.exe").exists()
    if system == "darwin":
      return (emus_folder / "mame.app").exists()


def mame_init():
    set_msg(f"Setting up mame")
    if system == "linux":
        destination=f"{home}/.mame/"
    if system.startswith("win"):
        destination=f"{emus_folder}/mame/"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/mame"

    copy_setting_dir(f"{system}/mame/",destination)
    copy_and_set_settings_file(f"{system}/mame/mame.ini", destination)



   # move_contents_and_link(bios,f"{bios_path}/mame")

    mame_setup_saves()
    #mame_setup_storage()
    mame_set_resolution()
    mame_set_controller_style()
    mame_widescreen()
    esde_set_emu("MAME (Standalone)","arcade")
    mame_add_custom_parser()

def mame_install_init():
    mame_install()
    mame_init()


def mame_add_custom_parser():
    if mame_is_installed():
        add_parser("arcade_mame")


def mame_setup_saves():
    print("NYI")

def mame_set_resolution():
    print("NYI")

def mame_set_abxy_style():
    print("NYI")

def mame_set_bayx_style():
    print("NYI")

def mame_set_controller_style():
    if settings.controllerLayout == "bayx":
        mame_set_bayx_style()
    else:
        mame_set_bayx_style()

def mame_widescreen():
    print("NYI")

def mame_widescreen_on():
    print("NYI")

def mame_widescreen_off():
    print("NYI")
