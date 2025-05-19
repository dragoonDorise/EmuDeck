from core.all import *

def xenia_install():
    set_msg(f"Installing xenia")

    if system == "linux":
        type="tar.gz"
        look_for="linux"
        path=emus_folder

    if system.startswith("win"):
        type="zip"
        look_for="windows"
        path=f"{emus_folder}/xenia"

    if system == "darwin":
        return False

    try:
        repo=get_latest_release_gh("xenia-canary/xenia-canary-releases",type,look_for)
        install_emu("xenia", repo, type, path)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def xenia_uninstall():
    try:
        if system == "linux":
            uninstall_emu("xenia_canary_linux", "dir")
        if system.startswith("win"):
          uninstall_emu("xenia", "dir")
        if system == "darwin":
          uninstall_emu("xenia", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def xenia_is_installed():
    if system == "linux":
        return (emus_folder / "xenia_canary_linux").exists()
    if system.startswith("win"):
      return (emus_folder / "xenia" / "xenia_canary.exe").exists()
    if system == "darwin":
      return (emus_folder / "xenia.app").exists()


def xenia_init():
    set_msg(f"Setting up xenia")
    if system == "linux":
        destination=f"{home}/.config/xenia/config"
    if system.startswith("win"):
        destination=f"{emus_folder}/xenia/"
    if system == "darwin":
        destination=f"{home}/.config/xenia/"

    copy_and_set_settings_file(f"common/xenia/xenia-canary.config.toml", destination)
    copy_and_set_settings_file(f"common/xenia/xenia.config.toml", destination)

    xenia_setup_saves()

def xenia_install_init():
    xenia_install()
    xenia_init()


def xenia_setup_saves():
    if system == "linux":
        origin_saves=f"{home}/.share/xenia/sdmc"
    if system.startswith("win"):
        origin_saves=f"{emus_folder}/xenia/content"
    if system == "darwin":
        origin_saves=f"{home}/.share/xenia/sdmc"

    move_contents_and_link(origin_saves,f"{saves_path}/xenia/saves")