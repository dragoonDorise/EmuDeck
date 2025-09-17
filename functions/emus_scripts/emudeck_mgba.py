from core.all import *

def mgba_install():
    set_msg(f"Installing mgba")

    if system == "linux":
        type="tar.gz"
        look_for="x64.AppImage"
        path=emus_folder

    if system.startswith("win"):
        type="7z"
        look_for="win64.7z"
        path=f"{emus_folder}/mgba"

    if system == "darwin":
        type="dmg"
        look_for="macos"
        path=emus_folder

    try:
        repo=get_latest_release_gh("mgba-emu/mgba",type,look_for)
        install_emu("mGBA", repo, type, path)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def mgba_uninstall():
    try:
        if system == "linux":
            uninstall_emu("mGBA", "AppImage")
        if system.startswith("win"):
          uninstall_emu("mgba", "dir")
        if system == "darwin":
          uninstall_emu("mgba", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def mgba_is_installed():
    if system == "linux":
        return (emus_folder / "mGBA.AppImage").exists()
    if system.startswith("win"):
      return (emus_folder / "mgba" / "mgba.exe").exists()
    if system == "darwin":
      return (emus_folder / "mgba.app").exists()


def mgba_init():
    set_msg(f"Setting up mgba")
    if system == "linux":
        destination=f"{home}/.config/mgba"
    if system.startswith("win"):
        destination=f"{emus_folder}/mgba"
    if system == "darwin":
        destination=f"{home}/.config/mgba"

    copy_and_set_settings_file(f"common/mgba/config.ini", destination)

    mgba_set_controller_style()
    esde_set_emu("mGBA (Standalone)","gba")
    mgba_add_custom_parser()

def mgba_install_init():
    mgba_install()
    mgba_init()

def mgba_add_custom_parser():
    if mgba_is_installed():
        add_parser("nintendo_gba_mgba")


def mgba_set_abxy_style():
    print("NYI")

def mgba_set_bayx_style():
    print("NYI")

def mgba_set_controller_style():
    if settings.controllerLayout == "bayx":
        mgba_set_bayx_style()
    else:
        mgba_set_bayx_style()
