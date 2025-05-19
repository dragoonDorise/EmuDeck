from core.all import *


def supermodel_install():
    set_msg(f"Installing Supermodel")

    if system == "linux":
        name="com.supermodel3.Supermodel"
        type="flatpak"
        look_for=""
        destination = f"{emus_folder}"

    if system.startswith("win"):
        name="supermodel"
        type="zip"
        look_for="win64"
        destination = f"{emus_folder}/supermodel"

    if system == "darwin":
        name="supermodel"
        type="zip"
        look_for="macOS"
        destination = f"{emus_folder}"

    try:
        repo="https://www.supermodel3.com/Files/Git_Snapshots/Supermodel_0.3a-git-d043dc0_Win64.zip"
        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def supermodel_uninstall():
    try:
        if system == "linux":
            uninstall_emu("com.supermodel3.Supermodel", "flatpak")
        if system.startswith("win"):
          uninstall_emu("supermodel", "dir")
        if system == "darwin":
          uninstall_emu("supermodel", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def supermodel_is_installed():
    if system == "linux":
        return is_flatpak_installed("com.supermodel3.Supermodel")
    if system.startswith("win"):
      return (emus_folder / "supermodel" / "supermodel.exe").exists()
    if system == "darwin":
      return (emus_folder / "supermodel.app").exists()


def supermodel_init():
    set_msg(f"Setting up Supermodel")
    if system == "linux":
        destination=f"{home}/.supermodel/"
    if system.startswith("win"):
        destination=f"{emus_folder}/supermodel/"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/supermodel"

    copy_setting_dir(f"common/supermodel/",destination)
    copy_and_set_settings_file(f"common/supermodel/Config/Supermodel.ini", destination)

def supermodel_install_init():
    supermodel_install()
    supermodel_init()
