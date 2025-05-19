from core.all import *

def vita3k_install():
    set_msg(f"Installing Vita3k")

    if system == "linux":
        type="zip"
        look_for="ubuntu-latest.zip"
        path=f"{emus_folder}/vita3k"

    if system.startswith("win"):
        type="zip"
        look_for="windows-latest"
        path=f"{emus_folder}/vita3k"

    if system == "darwin":
        type="dmg"
        look_for="macos-latest"
        path=emus_folder

    try:
        repo=get_latest_release_gh("Vita3K/Vita3K",type,look_for)
        install_emu("vita3k", repo, type, path)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def vita3k_uninstall():
    try:
        if system == "linux":
            uninstall_emu("vita3k", "dir")
        if system.startswith("win"):
          uninstall_emu("vita3k", "dir")
        if system == "darwin":
          uninstall_emu("Vita3K", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def vita3k_is_installed():
    if system == "linux":
        return (emus_folder / "Vita3K").exists()
    if system.startswith("win"):
      return (emus_folder / "vita3k" / "vita3k.exe").exists()
    if system == "darwin":
      return (emus_folder / "Vita3K.app").exists()


def vita3k_init():
    set_msg(f"Setting up Vita3k")
    if system == "linux":
        destination=f"{home}/.config/vita3k/config"
    if system.startswith("win"):
        destination=f"{emus_folder}/vita3k/"
    if system == "darwin":
        destination=f"{home}/.config/vita3k/"

    copy_and_set_settings_file(f"common/vita3k/config.yml", destination)
    vita3k_setup_saves()

def vita3k_install_init():
    vita3k_install()
    vita3k_init()


def vita3k_setup_saves():
    origin_saves=f"{storage_path}/Vita3K/ux0/user/00/savedata"
    move_contents_and_link(origin_saves,f"{saves_path}/Vita3K/saves")
