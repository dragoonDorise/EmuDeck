from core.all import *


def rmg_install():
    set_msg(f"Installing rmg")

    if system == "linux":
        name="RMG"
        type="flatpak"
        look_for=""
        destination = f"{emus_folder}"
        repo="com.github.Rosalie241.RMG"

    if system.startswith("win"):
        return False;

    if system == "darwin":
        return False;

    try:
        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def rmg_uninstall():
    try:
        if system == "linux":
            uninstall_emu("com.github.Rosalie241.RMG", "flatpak")
        if system.startswith("win"):
          uninstall_emu("rmg", "dir")
        if system == "darwin":
          uninstall_emu("rmg", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def rmg_is_installed():
    if system == "linux":
        return is_flatpak_installed("com.github.Rosalie241.RMG")
    if system.startswith("win"):
      return (emus_folder / "rmg" / "rmg.exe").exists()
    if system == "darwin":
      return (emus_folder / "rmg.app").exists()


def rmg_init():
    set_msg(f"Setting up RMG")
    if system == "linux":
        destination=f"{home}/.var/app/com.github.Rosalie241.RMG/config/RMG/"
    if system.startswith("win"):
        destination=f"{emus_folder}/rmg/"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/rmg"

    copy_setting_dir(f"common/rmg/",destination)
    copy_and_set_settings_file(f"common/rmg/mupen64plus.cfg", destination)

    rmg_set_resolution()
    rmg_set_controller_style()
    esde_set_emu("RMG (Standalone)","n64")
    rmg_add_custom_parser()

def rmg_install_init():
    rmg_install()
    rmg_init()


def rmg_add_custom_parser():
    if rmg_is_installed():
       add_parser("nintendo_64_rmg")

def rmg_set_resolution():
    print("NYI")

def rmg_set_abxy_style():
    print("NYI")

def rmg_set_bayx_style():
    print("NYI")

def rmg_set_controller_style():
    if settings.controllerLayout == "bayx":
        rmg_set_bayx_style()
    else:
        rmg_set_bayx_style()