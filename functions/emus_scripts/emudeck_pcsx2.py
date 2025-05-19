from core.all import *

def pcsx2_rename_versions(dir_path: Path) -> None:
    for f in Path(dir_path).glob("PCSX2-*"):
        if f.is_file():
            continue
        stem = f.stem
        base = stem.split("-", 1)[0]
        new_name = f"{base}{f.suffix}"  # e.g. 'PCSX2.exe'
        new_path = f.with_name(new_name)
        print(f"Renaming {f.name} → {new_name}")
        f.rename(new_path)

def pcsx2_install():
    set_msg(f"Installing pcsx2")

    if system == "linux":
        type="AppImage"
        look_for="Qt.AppImage"
        path=emus_folder

    if system.startswith("win"):
        type="7z"
        look_for="windows-x64-Qt.7z"
        path=f"{emus_folder}/pcsx2"

    if system == "darwin":
        type="tar.xz"
        look_for="macos"
        path=emus_folder

    try:
        repo=get_latest_prerelease_gh("PCSX2/pcsx2",type,look_for)
        install_emu("pcsx2", repo, type, path)
        if system == "darwin":
            pcsx2_rename_versions(emus_folder)

    except Exception as e:
        print(f"Error during install: {e}")
        return False


def pcsx2_uninstall():
    try:
        if system == "linux":
            uninstall_emu("pcsx2", "AppImage")
        if system.startswith("win"):
          uninstall_emu("pcsx2", "dir")
        if system == "darwin":
          uninstall_emu("PCSX2", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def pcsx2_is_installed():
    if system == "linux":
        return (emus_folder / "PCSX2.AppImage").exists()
    if system.startswith("win"):
      return (emus_folder / "pcsx2" / "pcsx2-qt.exe").exists()
    if system == "darwin":
      return (emus_folder / "PCSX2.app").exists()


def pcsx2_init():
    set_msg(f"Setting up pcsx2")
    if system == "linux":
        destination=f"{home}/.config/PCSX2/inis"
    if system.startswith("win"):
        destination=f"{emus_folder}/pcsx2/inis"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/PCSX2/inis"

    copy_and_set_settings_file(f"common/pcsx2/PCSX2.ini", destination)

    pcsx2_set_resolution()

def pcsx2_install_init():
    pcsx2_install()
    pcsx2_init()


def pcsx2_set_resolution() -> bool:
    if system == "linux":
        pcsx2_config_file=f"{home}/.config/PCSX2/inis/PCSX2.ini"
    if system.startswith("win"):
        pcsx2_config_file=f"{emus_folder}/pcsx2/inis/PCSX2.ini"
    if system == "darwin":
        pcsx2_config_file=f"{home}/Library/Application Support/PCSX2/inis/PCSX2.ini"

    resolution_map = {
        "720P": 2,
        "1080P": 3,
        "1440P": 4,
        "4K": 6,
    }

    # Normalize config file path
    config_path = Path(pcsx2_config_file)

    # Find the multiplier
    multiplier = resolution_map.get(settings.resolutions.pcsx2)
    if multiplier is None:
        print(f"Error: unsupported resolution '{settings.resolutions.pcsx2}'")
        return False

    set_config("upscale_multiplier", multiplier, config_path)

    return True