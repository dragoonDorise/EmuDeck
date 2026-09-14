from core.all import *


def scummvm_install():
    set_msg(f"Installing ScummVM")

    if system == "linux":
        name="scummvm"
        type="flatpak"
        look_for=""
        destination = f"{emus_folder}"
        repo="org.scummvm.ScummVM"

    if system.startswith("win"):
        name="scummvm"
        type="zip"
        look_for="win64"
        destination = f"{emus_folder}/scummvm"
        repo="https://downloads.scummvm.org/frs/scummvm/2.7.1/scummvm-2.7.1-win32-x86_64.zip"

    if system == "darwin":
        name="scummvm"
        type="dmg"
        look_for="macOS"
        destination = f"{emus_folder}"
        repo="https://downloads.scummvm.org/frs/scummvm/2.9.0/scummvm-2.9.0-macosx.dmg"

    try:
        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def scummvm_uninstall():
    try:
        if system == "linux":
            uninstall_emu("org.scummvm.ScummVM", "flatpak")
        if system.startswith("win"):
          uninstall_emu("scummvm", "dir")
        if system == "darwin":
          uninstall_emu("ScummVM", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def scummvm_is_installed():
    if system == "linux":
        return is_flatpak_installed("org.scummvm.ScummVM")
    if system.startswith("win"):
      return (emus_folder / "scummvm" / "scummvm.exe").exists()
    if system == "darwin":
      return (emus_folder / "ScummVM.app").exists()


def scummvm_init():
    set_msg(f"Setting up ScummVM")
    flush_emulator_launchers("scummvm")
    if system == "linux":
        destination=f"{home}/.var/app/org.scummvm.scummvm/config/scummvm/"
        bios=f"{home}/.var/app/org.scummvm.scummvm/data/scummvm/"
    if system.startswith("win"):
        destination=f"{emus_folder}/scummvm/"
        bios=""
    if system == "darwin":
        destination=f"{home}/Library/Application Support/ScummVM"
        bios=""

    copy_setting_dir(f"common/scummvm/",destination)
    copy_and_set_settings_file(f"common/scummvm/scummvm.ini", destination)
   # move_contents_and_link(bios,f"{bios_path}/scummvm")
    scummvm_set_language()
    scummvm_set_resolution()

def scummvm_install_init():
    scummvm_install()
    scummvm_init()


def scummvm_set_language() -> bool:
    if system == "linux":
        config_file = f"{home}/.var/app/org.scummvm.scummvm/config/scummvm/scummvm.ini"
    if system.startswith("win"):
        config_file = f"{emus_folder}/scummvm/scummvm.ini"
    if system == "darwin":
        config_file = f"{home}/Library/Application Support/ScummVM/scummvm.ini"

    config_path = Path(config_file)

    if not config_path.is_file():
        return False

    set_config("gui_language", get_system_locale(), config_path)

    return True


def scummvm_set_resolution():
    print("NYI")