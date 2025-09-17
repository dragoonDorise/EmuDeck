from core.all import *


def ppsspp_install():
    set_msg(f"Installing ppsspp")

    if system == "linux":
        name="PPSSPP"
        type="flatpak"
        destination = f"{emus_folder}"
        repo="org.ppsspp.PPSSPP"

    if system.startswith("win"):
        name="ppsspp"
        type="zip"
        destination = f"{emus_folder}/ppsspp"
        repo="https://www.ppsspp.org/files/1_18_1/ppsspp_win.zip"

    if system == "darwin":
        name="ppsspp"
        type="dmg"
        destination = f"{emus_folder}"
        repo="https://www.ppsspp.org/files/1_18/PPSSPP_macOS.dmg"

    try:
        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def ppsspp_uninstall():
    try:
        if system == "linux":
            uninstall_emu("org.ppsspp.PPSSPP", "flatpak")
        if system.startswith("win"):
          uninstall_emu("ppsspp", "dir")
        if system == "darwin":
          uninstall_emu("PPSSPPDL", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def ppsspp_is_installed():
    if system == "linux":
        return is_flatpak_installed("org.ppsspp.PPSSPP")
    if system.startswith("win"):
      return (emus_folder / "ppsspp" / "PPSSPPWindows.exe").exists()
    if system == "darwin":
      return (emus_folder / "PPSSPPDL.app").exists()


def ppsspp_init():
    set_msg(f"Setting up ppsspp")
    if system == "linux":
        destination=f"{home}/.var/app/org.ppsspp.PPSSPP/config/ppsspp/"
    if system.startswith("win"):
        destination=f"{emus_folder}/ppsspp/"
        bios=""
    if system == "darwin":
        destination=f"{home}/Library/Application Support/ppsspp"
        bios=""

    copy_setting_dir(f"{system}/ppsspp/",destination)
    copy_and_set_settings_file(f"{system}/ppsspp/memstick/PSP/SYSTEM/ppsspp.ini", destination)

   # move_contents_and_link(bios,f"{bios_path}/ppsspp")

    ppsspp_setup_saves()
    ppsspp_set_resolution()

def ppsspp_install_init():
    ppsspp_install()
    ppsspp_init()


def ppsspp_setup_saves():
    if system == "linux":
        origin_saves=f"{home}/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/SAVEDATA"
        origin_states=f"{home}/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/PPSSPP_STATE"
    if system.startswith("win"):
        origin_saves=f"{emus_folder}/ppsspp/memstick/SAVEDATA"
        origin_states=f"{emus_folder}/ppsspp/memstick/PPSSPP_STATE"
    if system == "darwin":
        origin_saves=f"{home}/.config/ppsspp/PSP/SAVEDATA"
        origin_states=f"{home}/.config/ppsspp/PSP/PPSSPP_STATE"

    move_contents_and_link(origin_saves,f"{saves_path}/ppsspp/saves")
    move_contents_and_link(origin_states,f"{saves_path}/ppsspp/states")


def ppsspp_set_resolution():
    print("NYI")