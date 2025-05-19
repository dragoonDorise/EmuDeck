from core.all import *

def shadps4_install():
    set_msg(f"Installing shadps4")

    if system == "linux":
        type="zip"
        look_for="linux-qt"
        path=emus_folder

    if system.startswith("win"):
        type="zip"
        look_for="win64-qt"
        path=f"{emus_folder}/shadps4"

    if system == "darwin":
        type="zip"
        look_for="macos-qt"
        path=emus_folder

    try:
        repo=get_latest_release_gh("shadps4-emu/shadPS4",type,look_for)
        install_emu("shadps4", repo, type, path)
        if system == "darwin":
            extract_to = emus_folder
            tars = list(extract_to.rglob("*.tar.gz"))
            if not tars:
                print(f"No .tar.gz found inside {extract_to}")
                return False

            tar_path = tars[0]
            print(f"Found AppImage: {tar_path}")
            extract_to = emus_folder
            extract_to.mkdir(parents=True, exist_ok=True)
            extract_tar_gz(tar_path, extract_to)

    except Exception as e:
        print(f"Error during install: {e}")
        return False


def shadps4_uninstall():
    try:
        if system == "linux":
            uninstall_emu("shadps4", "AppImage")
        if system.startswith("win"):
          uninstall_emu("shadps4", "dir")
        if system == "darwin":
          uninstall_emu("shadps4", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def shadps4_is_installed():
    if system == "linux":
        return (emus_folder / "shadps4.AppImage").exists()
    if system.startswith("win"):
      return (emus_folder / "shadps4" / "shadps4.exe").exists()
    if system == "darwin":
      return (emus_folder / "shadps4.app").exists()


def shadps4_init():
    set_msg(f"Setting up shadps4")
    if system == "linux":
        destination=f"{home}/.local/share/shadPS4"
    if system.startswith("win"):
        destination=f"{emus_folder}/shadps4"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/shadPS4"

    copy_and_set_settings_file(f"{system}/shadps4/config.toml", destination)

    shadps4_setup_saves()
    esde_set_emu("ShadPS4 (Standalone)","ps4")

def shadps4_install_init():
    shadps4_install()
    shadps4_init()


def shadps4_setup_saves():
    if system == "linux":
        origin_saves=f"{home}/.local/share/shadps4/savedata"
        bios=f"{home}/.local/share/shadps4/sys_modules"

    if system.startswith("win"):
        origin_saves=f"{emus_folder}/shadps4/savedata"
        bios=f"{emus_folder}/shadps4/sys_modules"

    if system == "darwin":
        origin_saves=f"{home}/Library/Application Support/shadPS4/savedata"
        bios=f"{home}/Library/Application Support/shadPS4/sys_modules"

    move_contents_and_link(origin_saves,f"{saves_path}/shadps4/saves")
    move_contents_and_link(bios,f"{bios_path}/shadps4/sys_modules")